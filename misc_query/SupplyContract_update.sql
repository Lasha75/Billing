--ვახო
select cu.id, cu.customer_number, cu.name, st.name, * from prx_supply_contract psc
join prx_customer cu on cu.id = psc.customer_id
join "LK".ttt t on t.pid = cu.customer_number
join prx_status st on psc.status_id = st.id
where  st.id in ('c772a0f9-4a1f-3e9c-b873-a5cde622b70d','3f831a00-dbb9-77d0-022f-ac86d56f150f')
  and psc.to_date='2025-01-01'
--   and cu.id='8dee2b65-050e-193c-be09-c03aa54851e2'
and psc.deleted_by is null
--cu.customer_number='1223465';

update prx_supply_contract sc
set to_date='2026-07-01',
    notification_date='2026-05-01',
    last_modified_by='vmaisuradze',
    last_modified_date = now()
from prx_customer cu
join "LK".ttt t on cu.customer_number = t.pid
where sc.customer_id = cu.id
and sc.status_id in ('c772a0f9-4a1f-3e9c-b873-a5cde622b70d','3f831a00-dbb9-77d0-022f-ac86d56f150f')
  and sc.to_date='2025-01-01'; --'95bad254-8393-d94b-5ac8-dbf19f81d99a';


select distinct sc.to_date
from prx_customer cu
join "LK".ttt t on t.pid = cu.customer_number
join prx_supply_contract sc on sc.customer_id = cu.id
left join prx_status st on sc.status_id = st.id
where  st.type_='SUPPLYCONTRACT' and st.code in ('3', 'SC5')


