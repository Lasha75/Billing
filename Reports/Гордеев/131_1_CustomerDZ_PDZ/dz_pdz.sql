/*WITH debt AS (SELECT otr.customer_number,
                           otr.customer_id,
                           sum(otr.amount) filter ( where due_date < DATE_TRUNC('month', CURRENT_DATE)) over (partition by otr.customer_id )                       pdz,
                           sum(otr.amount) filter ( where due_date >= DATE_TRUNC('month', CURRENT_DATE) or due_date is null) over (partition by otr.customer_id )  dz,
                           sum(otr.amount) over ( partition by otr.customer_id )                                                                   full_dz,
                           sum(otr.amount) filter ( where trans_date < (current_date - INTERVAL '3 year') and otr.amount > 0) over (partition by otr.customer_id ) old_debt,
                           sum(otr.amount) filter (where due_date >= DATE_TRUNC('month', CURRENT_DATE) and
                                                         coalesce(otr.amount, 0) > 0 and
                                                         otr.used_in_bill is null ) over (partition by otr.customer_id)                            chrg
                    from public.prx_open_transaction otr
                    where otr.deleted_by is null
                      and coalesce(otr.amount, 0) != 0)*/
WITH debt AS (SELECT otr.customer_id,
                     sum(case
                             when due_date < DATE_TRUNC('month', CURRENT_DATE)
                                 then otr.amount
                             else 0 end) pdz,
                     sum(case
                             when due_date >= DATE_TRUNC('month', CURRENT_DATE) or due_date is null
                                 then otr.amount
                             else 0 end) dz,
                     sum(otr.amount)     full_dz,
                     sum(case
                             when trans_date < (current_date - INTERVAL '3 year') and otr.amount > 0
                                 then otr.amount
                             else 0 end) old_debt,
                    sum(case
                             when due_date >= DATE_TRUNC('month', CURRENT_DATE) and
                                  coalesce(otr.amount, 0) > 0 and
                                   not otr.used_in_bill --= false
                                 then otr.amount
                             else 0 end) chrg
              from public.prx_open_transaction otr
              where otr.deleted_by is null
                and coalesce(otr.amount, 0) != 0
              group by otr.customer_id)                      ,
     cust as (select *
              from (SELECT cu.customer_number,
                        cu.id,
                           cu.identification_number,
                           cu.name,
                           cu.category_id,
                           cu.status_id,
                           cu.activity_id,
                           cu.give_type_id,
                           cu.disputed_debt,
                           row_number() over (partition by cu.id order by coalesce(cu.identification_number, '') desc) rn
                    from prx_customer cu
                    where cu.deleted_by is null) a
              where rn = 1),
     own_id as (select *
                from (SELECT customer_id,
                             regexp_replace(COALESCE(NULLIF(personal_id, ''), tax_id), '[\x00-\x1F\x7F]', '', 'g') AS ow_id,
                             row_number() over (partition by customer_id order by start_date desc) rn
                      FROM prx_proprietor_information
                      WHERE deleted_by IS NULL
                        AND end_date IS NULL
                        AND COALESCE(NULLIF(personal_id, ''), tax_id) IS NOT NULL) ow
                where ow.rn = 1),
     ren_id as (select *
                from (select pbi.customer_id,
                       regexp_replace(COALESCE(pbi.personal_id, ''), '[\x00-\x1F\x7F]', '', 'g') rnt_id,
                       row_number() over (partition by customer_id order by start_date desc) rn
                from prx_beneficiary_information pbi
                where pbi.deleted_by is null
                  and end_date is null) rr
                where rr.rn = 1),
     pm_dt as (select customer_id,
                      max(payment_date) pm_dt
               from prx_bill
               where deleted_by is null
               group by customer_id),
     shdw as (select -sum(pm.amount) shdw_debt,
                     pm.customer_id
              from prx_payment pm
              where pm.status = 'SHADOW'
                and pm.payment_date <= current_timestamp
              group by pm.customer_id),
     excn as (select customer_id,
                     max(end_date) excp_end
              from prx_delayer
              where status = 'ACTIVE'
                    and deleted_by is null
              group by customer_id)


select cust.customer_number                                                num,
       regexp_replace(COALESCE(cust.name, ''), '[\x00-\x1F\x7F]', '', 'g') nam,
       cat.name                                                            cat,
       act.name                                                            act,
       sup.name                                                            sup,
       pm_dt.pm_dt,
       st.name                                                             stat,
       regexp_replace(COALESCE(NULLIF(cust.identification_number, ''), NULLIF(o.ow_id, ''), r.rnt_id), '[\x00-\x1F\x7F]', '', 'g') AS                       id,
       debt.dz,
       debt.pdz,
       debt.full_dz,
       debt.old_debt,
       shdw.shdw_debt,
       cust.disputed_debt                                                  dispt_debt,
       shdw.shdw_debt,
       excn.excp_end,
       debt.chrg,
       dp.dep_am,
       dp.dep_lia
from debt
join cust on cust.id = debt.customer_id
left join pm_dt on debt.customer_id = pm_dt.customer_id
join prx_customer_category cat on cust.category_id = cat.id
left join public.prx_status st on cust.status_id = st.id
left join prx_activity act on cust.activity_id = act.id
left join own_id o on o.customer_id = debt.customer_id
left join ren_id r on r.customer_id = debt.customer_id
left join prx_give_type sup on cust.give_type_id = sup.id
left join excn on excn.customer_id = debt.customer_id
left join shdw on shdw.customer_id = debt.customer_id
left join "LK".fn_deposit_info_tlmc() dp on dp.cust_num = cust.customer_number
where cat.deleted_by is null;

