with charge as (select tr.customer_id,
                       sum(tr.amount) charge_amount
                from prx_transaction tr
                where tr.read_date between '01-feb-2024' and '29-jun-2025'
                  and tr.deleted_by is null
                  and tr.trans_type_combination_id in ('de579ca8-118d-0f99-1012-c2e6b3a02307',
                                                       'ce5ae29e-cf2a-1053-e58e-c16bf1063670',
                                                       '51a53157-c480-2e09-fb94-a9625dc12e32',
                                                       '61922bb4-daa5-9696-c7b5-69609e027171',
                                                       'a4e37496-cbb1-51bb-0a94-32bc07dd3710',
                                                       '92064740-2471-1450-a569-ac4b7efe9a0c')
--                 and tr.cycle_type = 'CIRCULAR'
                group by tr.customer_id),

pay as (SELECT pm.customer_id,
               sum(pm.amount) pay_amount
               FROM prx_payment pm
               where pm.reporting_date between '01-feb-2024' and '29-feb-2024'
               GROUP BY pm.customer_id)


select cu.customer_number,
       cu.name,
       act.name activity,
       cat.name category,
       bc.name  bc,
       c.charge_amount,
       p.pay_amount
from prx_customer cu
left join prx_activity act on act.id = cu.activity_id
join prx_customer_category cat on cu.category_id = cat.id
left join charge c on c.customer_id = cu.id
left join pay p on p.customer_id = cu.id
join prx_business_center bc on cu.business_center_id = bc.id
where act.code in ('A453', 'A502')


