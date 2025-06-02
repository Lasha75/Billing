with dz as (select customer_number,
                   davalianebaamount
            from prx_debtor_balance_report r /*prx_currentbalancenew1_vw*/
            where r.period_ = ${Period}
              and r.customer_number not in ('6016601', '7160190', '5015501')), --სუბსიდიები
     charge_met as (select counter_serial_number
                from (select tr.counter_serial_number,
                             count(tr.customer_number) cnt
                      from prx_transaction tr
                      where tr.created_date::date between '04-oct-2023' and '03-apr-2024' /*report server -> application -> debtors report*/
                        and tr.deleted_by is null
                        and tr.cycle_type = 'CIRCULAR'
                        and tr.trans_type_combination_id in
                            ('de579ca8-118d-0f99-1012-c2e6b3a02307', '92064740-2471-1450-a569-ac4b7efe9a0c')
                        and (coalesce(tr.amount, 0) = 0 and coalesce(tr.kilowatt_hour, 0) = 0)
                      group by  tr.counter_serial_number) zc
                where zc.cnt = 6),
    met_qua as (select cu.customer_number,
                       count(met.id)
                from prx_counter met
                inner join prx_customer cu on cu.cust_key=met.cust_key
                group by cu.customer_number),
     cutHist as (select c.customer_number,
                        operationtype,
                     /*discrecstatname,*/
                        reason
                 from (select ch.customer_number,
                              ch.mark_date,
                              ch.operationtype,
                           /*ch.discrecstatname,*/
                              case
                                  when ch.water then 'GWP'
                                  when ch.supply then 'Telmico'
                                  when ch.trash then 'Trash'
                                  end                                                                        reason,
                              row_number() over (partition by ch.customer_number order by ch.mark_date desc) rn
                       from "prx_cut_history_v_vw" /*"TelasiCutHistory_V_status"*/ ch
                     /*where ch.supply*/ ) c
                 where rn = 1),
     cutQua as (select cu.customer_number,
                       cut.cut_qua
                from (select customer_id,
                             sum(cut_qua) cut_qua
                      from (select ccut.customer_id,
                                   count(ccut.customer_id) cut_qua
                            from prx_customer_cutoff ccut
                            where ccut.created_date between DATE_TRUNC('MONTH', now() - INTERVAL '6 MONTH')
                                and (DATE_TRUNC('MONTH', now()) + INTERVAL '1 MONTH' - INTERVAL '1 DAY')
                              and ccut.deleted_by is null
                            group by ccut.customer_id
                            union
                            select icut.customer_id,
                                   count(icut.customer_id)
                            from prx_Individual_Cutoff icut
                            where icut.created_date between DATE_TRUNC('MONTH', now() - INTERVAL '6 MONTH')
                                and (DATE_TRUNC('MONTH', now()) + INTERVAL '1 MONTH' - INTERVAL '1 DAY')
                              and icut.deleted_by is null
                            group by icut.customer_id) cq
                      group by customer_id) cut
                join prx_customer cu on cu.id = cut.customer_id
                where cu.deleted_by is null),
     reconQua as (select cu.customer_number,
                         rec.recon_qua
                  from (select customer_id,
                               sum(cut_qua) recon_qua
                        from (select crec.customer_id,
                                     count(crec.customer_id) cut_qua
                              from prx_Customer_Reconnection crec
                              where crec.created_date between DATE_TRUNC('MONTH', now() - INTERVAL '6 MONTH')
                                  and (DATE_TRUNC('MONTH', now()) + INTERVAL '1 MONTH' - INTERVAL '1 DAY')
                                and crec.deleted_by is null
                              group by crec.customer_id
                              union
                              select irec.customer_id,
                                     count(irec.customer_id)
                              from prx_Individual_Reconnection irec
                              where irec.created_date between DATE_TRUNC('MONTH', now() - INTERVAL '6 MONTH')
                                  and (DATE_TRUNC('MONTH', now()) + INTERVAL '1 MONTH' - INTERVAL '1 DAY')
                                and irec.deleted_by is null
                              group by irec.customer_id) cq
                        group by customer_id) rec
                  join prx_customer cu on cu.id = rec.customer_id
                  where cu.deleted_by is null),
     cust as (select cc.customer_number as customer_number,
                     cc.name            as customerName,
                     cat.name           as category,
                     act.name              act,
                     bc.name            as business_center,
                     st.name               status,
                     cc.id,
                     regexp_replace(COALESCE(cc.address_text, ''),'[\x00-\x1F\x7F]', '', 'g') adr,
                     cc.create_date
              from prx_customer cc
              left join prx_status st on st.id = cc.status_id
              left outer join prx_business_center bc on bc.id = cc.business_center_id
              left outer join prx_customer_category cat on cat.id = cc.category_id
/*              left join (select *
                         from (select regexp_replace(COALESCE(a.street::text, ''),  ||
                                      ' ' || regexp_replace(COALESCE(a.house::text, ''), '[\x00-\x1F\x7F]', '', 'g') ||
                                      ' ' || regexp_replace(COALESCE(a.building, ''::character varying), '[\x00-\x1F\x7F]', '', 'g') ||
                                      ' ' || regexp_replace(COALESCE(a.porch, ''::character varying), '[\x00-\x1F\x7F]', '','g') ||
                                      ' ' || regexp_replace(COALESCE(a.flate, ''::character varying), '[\x00-\x1F\x7F]', '', 'g') adr,
                                      row_number()
                                      over (partition by a.customer_id order by a.last_modified_date desc) rn,
                                      a.customer_id
                               from prx_customer_address a
                               where a.deleted_by is null) ad
                         where rn = 1) adr on cc.id = adr.customer_id*/
              left join prx_activity act on act.id = cc.activity_id
              where cc.deleted_by is null
                and bc.deleted_by is null
                and cat.deleted_by is null
                and st.deleted_by is null
                and cc.create_date <= date_trunc('day', now()) - interval '6 months')
/*    charge as (select tr.customer_number,
                      sum(coalesce(tr.kilowatt_hour, 0)),
                      sum(coalesce(tr.amount, 0))
               from prx_transaction tr
               where tr.deleted_by is null and tr.customer_number in ('0566024', '1640978', '6257855')
                 and tr.::date between ${startDate} and ${endDate}
                 /*--and (coalesce(tr.kilowatt_hour, 0) = 0  and coalesce(tr.amount, 0) = 0) and
                       tr.cycle_type = 'CIRCULAR' and t.trans_type_combination_id != 'dac93a92-41eb-8905-7021-53f1f8d559b5'*/--დარიცხვა ჯამური დარიცხვა
               group by tr.customer_number),*/


select c.customer_number                                          as cust,
       regexp_replace(c.customerName, '[\x00-\x1F\x7F]', '', 'g') as custName,
       c.category                                                 as cat,
       c.adr,
       c.business_center                                          as bc,
       st.qua_met,
       ch.operationtype,
       ch.reason,
       cq.cut_qua,
       rq.recon_qua,
       dz.davalianebaamount
from cust c
left join dz on dz.customer_number = c.customer_number
left join cutHist ch on ch.customer_number = c.customer_number
left join cutQua cq on cq.customer_number = c.customer_number
left join reconQua rq on rq.customer_number = c.customer_number
--left join charge cg on cg.numb = c.customer_number
/*left outer join (select cu.customer_number,
                        count(met.id) qua_met
                 from prx_counter met
                 join prx_customer_contract cuco on cuco.id = met.contract_id
                 join prx_customer cu on cu.id = cuco.customer_id
                 where met.deleted_by is null
                   and cuco.deleted_by is null
                 and cu.deleted_by is null
                 group by cu.customer_number) as st on c.customer_number = st.customer_number*/

-- where c.customer_number in ('0025109', '0025582')





/*considering customer's all metters charge*/
with charge_met as (select cust_numb,
                        met_numb
                    from (select tr.customer_number cust_numb,
                                tr.counter_serial_number met_numb,
                                 count(tr.customer_number) cnt
                          from prx_transaction tr
                          where tr.created_date::date between '04-oct-2023' and '03-apr-2024' /*report server -> application -> debtors report*/
                            and tr.deleted_by is null
                            and tr.cycle_type = 'CIRCULAR'
                            and tr.trans_type_combination_id in
                                ('de579ca8-118d-0f99-1012-c2e6b3a02307', '92064740-2471-1450-a569-ac4b7efe9a0c')
                            and (coalesce(tr.amount, 0) = 0 and coalesce(tr.kilowatt_hour, 0) = 0)
                          group by cust_numb,
                                   tr.counter_serial_number) zc
                    where zc.cnt = 6),
     /*met_qua as (select cu.customer_number,
                        count(met.id)
                 from prx_counter met
                 inner join prx_customer cu on cu.cust_key = met.cust_key
                 where met.deleted_by is null
                 group by cu.customer_number),*/
     cust_met as (select cu.customer_number,
                         met.serial_number,
                         count(cu.customer_number) over (partition by cu.customer_number ) cnt
                  from prx_counter met
                  inner join prx_customer cu on cu.cust_key = met.cust_key)

select distinct customer_number,
       met_numb
from (select chm.met_numb,
             chm.cust_numb,
             cum.customer_number,
             cum.serial_number,
             cum.cnt,
             count(cum.customer_number) over (partition by cum.customer_number ) rnc
      from charge_met chm
      right join cust_met cum on cum.customer_number = chm.cust_numb and cum.serial_number = chm.met_numb
      where /*cum.customer_number in ('3235528', '5464151') and*/ chm.met_numb is not null) cumet
where cumet.cnt = cumet.rnc
order by cumet.customer_number




