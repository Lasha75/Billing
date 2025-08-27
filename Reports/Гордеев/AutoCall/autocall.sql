WITH debt AS (select distinct customer_number,
                              customer_id,
                              name,
                              category_id,
                              give_type_id,
                              coalesce(full_dz, 0) - coalesce(disputed_debt, 0) - coalesce(shdw_debt, 0) debt
              from (SELECT otr.customer_number,
                           otr.customer_id,
                           cu.identification_number,
                           cu.name,
                           cu.category_id,
                           cu.status_id,
                           cu.activity_id,
                           cu.give_type_id,
                           sum(otr.amount) filter ( where due_date < DATE_TRUNC('month', CURRENT_DATE)) over (partition by otr.customer_id ) pdz,
                           sum(otr.amount) over ( partition by otr.customer_id ) full_dz,
                           cu.disputed_debt,
                           shdw.shdw_debt
                    from public.prx_open_transaction otr
                    left join (select sum(pm.amount) shdw_debt,
                                      pm.customer_id
                               from prx_payment pm
                               where pm.status = 'SHADOW'
                                 and pm.payment_date <= current_timestamp
                               group by pm.customer_id) shdw on shdw.customer_id = otr.customer_id
                    join prx_customer cu on otr.customer_id = cu.id
                    where otr.deleted_by is null
                      and coalesce(otr.amount, 0) != 0
                      and cu.deleted_by is null) a
              where coalesce(a.pdz, 0) = 0),
     pm_dt as (select customer_id,
                      max(payment_date) pm_dt
               from prx_bill
               group by customer_id),
     excn as (select customer_id,
                     max(end_date) excp_end
              from prx_delayer
              where status = 'ACTIVE'
              group by customer_id)


select debt.customer_number                                                num,
       regexp_replace(COALESCE(debt.name, ''), '[\x00-\x1F\x7F]', '', 'g') nam,
       cat.name                                                            cat,
       sup.name                                                            sup,
       pm_dt.pm_dt,
       excn.excp_end,
       con.contact_info                                                    mob,
       debt.debt
from debt
left join pm_dt on debt.customer_id = pm_dt.customer_id
join prx_customer_category cat on debt.category_id = cat.id
left join prx_give_type sup on debt.give_type_id = sup.id
left join excn on excn.customer_id = debt.customer_id
left join prx_customer_contact con on con.customer_id = debt.customer_id
                                          and contact_type = 'MOBILE_PHONE'
                                          and lower(con.contact_info) not like '%off%'
where cat.deleted_by is null
  and con.deleted_by is null
  and debt.debt > 0
and excn.customer_id is null;

