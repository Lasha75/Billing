with met(num) as(values ('4004776'))

select distinct cu.customer_number num,
       st.name            stat,
       met.serial_number  met,
       mett.name,
       met.created_date,
       met.*
from public.prx_customer cu
join met m on m.num = cu.customer_number
left join public.prx_status st on cu.status_id = st.id
left join public.prx_customer_contract cuc on cuc.customer_id = cu.id
join public.prx_counter met on met.contract_id = cuc.id
left join prx_counter_type mett on met.type_id = mett.id
where   cu.deleted_by is null
  and cuc.deleted_by is null
  and met.deleted_by is null
  and st.deleted_by is null
  /*and cu.status_id in ('bc544f2d-057e-b375-7cb4-2f5850600e39', 'e1bf6037-c89e-e0ba-3f29-fa9fc84babca') --canceled, closed
  and (coalesce(met.serial_number, '') = '' or met.type_id = 'a690be13-1341-420f-2c46-a10099ee8fb6')--type=არა*/




