with supl_contr as (select customer_id,
                           from_date,
                           st.name                                                               status,
                           row_number() over (partition by customer_id order by from_date desc ) rn
                    from prx_supply_contract contr
                    join public.prx_status st on contr.status_id = st.id
                    where contr.deleted_by is null),
     delay as (select *
               from crosstab('select customer_id,
                                status,
                               count(status)
               from prx_Delayer
               where deleted_by is null
                        and (status in (''ACTIVE'', ''DELAY_ABOLISHED'', ''FINISHED'') or (type_=''PERMANENT'' and status=''ACTIVE''))
               group by customer_id,
                        status',
                             'select distinct status
                           from prx_Delayer
                           where deleted_by is null
                  and status in (''ACTIVE'', ''DELAY_ABOLISHED'', ''FINISHED'') or (type_=''PERMANENT'' and status=''ACTIVE'')')
                   as res(cust uuid, fin smallint, abol smallint, actv smallint)),
     perm_delay as (select *
                    from crosstab('select customer_id,
                                        status,
                                        count(status)
                                from prx_Delayer
                                where deleted_by is null  and (type_=''PERMANENT'' and status=''ACTIVE'')
                                group by customer_id,
                                        status',
                                  'select distinct status
                                   from prx_Delayer
                                   where deleted_by is null and  (type_=''PERMANENT'' and status=''ACTIVE'')')
                        as res(cust uuid, perm_stat smallint)),
     cut_hist as (select customer_id,
                         SUM(cnt) cut_cnt
                  from (select customer_id,
                               count(id) cnt
                        from prx_customer_cutoff cut
                        where cut.deleted_by is null
                        group by customer_id
                        union all
                        select customer_id,
                               count(id)
                        from prx_individual_cutoff cut
                        where cut.deleted_by is null
                        GROUP BY customer_id) t
                  group by customer_id),
      no_ovd_pmnt as (select * from "LK".fn_overdue_payment()),
--     no_ovd_pmnt as (select  * from "LK".lk_overdue_payment_report),
     avg_charge as (select customer_id,
                           sum(charge_kwt) avg_kwt,
                           sum(charge_amount) avg_amt
                    from (select tr.customer_id,
                                 case
                                     when coalesce(tr.kilowatt_hour, 0) != 0
                                         then sum(coalesce(tr.kilowatt_hour, 0)) / 12 end charge_kwt,
                                 case
                                     when coalesce(tr.amount, 0) != 0 and coalesce(tr.kilowatt_hour, 0) != 0
                                         then sum(coalesce(tr.amount, 0)) / 12 end        charge_amount
                          from prx_transaction tr
                          where tr.read_date between current_date - interval '1 YEAR' and current_date
                            and tr.deleted_by is null
--                   and (coalesce(tr.kilowatt_hour, 0) != 0 or (coalesce(tr.kilowatt_hour, 0) != 0 and coalesce(tr.amount, 0) != 0))
                          group by tr.customer_id,
                                   tr.kilowatt_hour,
                                   tr.amount) t
                    group by customer_id),
     own_id as (SELECT distinct customer_id,
                                regexp_replace(COALESCE(NULLIF(personal_id, ''), tax_id), '[\x00-\x1F\x7F]', '',
                                               'g') AS ow_id
                FROM prx_proprietor_information
                WHERE deleted_by IS NULL
                  AND end_date IS NULL
                  AND COALESCE(NULLIF(personal_id, ''), tax_id) IS NOT NULL),
     ben_id as (select pbi.customer_id,
                       regexp_replace(COALESCE(pbi.personal_id, ''), '[\x00-\x1F\x7F]', '', 'g') personal_id
                from prx_beneficiary_information pbi
                where pbi.deleted_by is null
                  and end_date is null)

select distinct cu.customer_number                                                      cust,
                regexp_replace(coalesce(cu.name::text, ''), '[\x00-\x1F\x7F]', '', 'g') cust_nam,
                cat.name                                                                cat,
                act.name                                                                act,
                st.name                                                                 stat,
                cu.address_text                                                         adr,
                cu1.customer_number                                                     p_cust,
                regexp_replace(COALESCE(NULLIF(cu.identification_number, ''), NULLIF(o.ow_id, ''), b.personal_id), '[\x00-\x1F\x7F]', '', 'g') AS id,
                cu.created_date                                                         cr_dt,
                case
                    when cu.needs_el_bill then 'YES'
                    else 'NO'
                    end                                                                 p_bill,
                coalesce(ch.cut_cnt, 0)                                                 cut_qua,
                coalesce(dl.fin, 0)                                                     fin,
                coalesce(dl.abol, 0)                                                    abol,
                coalesce(dl.actv, 0)                                                    actv,
                coalesce(dl1.perm_stat, 0)                                              p_act,
                sc.from_date                                                            cntr_st_dt,
                sc.status                                                               cntr_stat,
                ac.avg_kwt,
                ac.avg_amt
from prx_customer cu
join no_ovd_pmnt nop on nop.cust_id = cu.id
--    join no_ovd_pmnt nop on nop.customer_id = cu.id
join prx_status st on cu.status_id = st.id
join prx_customer_category cat on cu.category_id = cat.id
left join own_id o on o.customer_id = cu.id
left join ben_id b on b.customer_id = cu.id
left join prx_activity act on cu.activity_id = act.id
left join supl_contr sc on sc.customer_id = cu.id and sc.rn = 1
left join prx_customer cu1 on cu1.id = cu.parent_customer_id
left join delay dl on dl.cust = cu.id
left join perm_delay dl1 on dl1.cust = cu.id
left join cut_hist ch on ch.customer_id = cu.id
left join avg_charge ac on ac.customer_id = cu.id
where cu.deleted_by is null
  and cu1.deleted_by is null
  and cat.code in ('C37', 'C44', 'C256', 'C257') --საბიუჯეტო -18% დღგ, კომერციული - ნულოვანი დღგ, კომერციული -18% დღგ, კომერციული -განთავისუფლებული დღგ გადასახადისაგან
--   and sc.rn = 1
  and st.deleted_by is null;







