with upd as (
select cu.customer_number,
       bi.*
from prx_beneficiary_information bi
join prx_customer cu on cu.id = bi.customer_id
join "LK".ttt on ttt.pid = cu.customer_number
where bi.deleted_by is null
and bi.created_date::date != '2025-05-24'
and cu.deleted_by is null
/*and bi.customer_id='02278ff5-1fdd-63ea-9db8-548635fc93d0'*/)

update prx_beneficiary_information bi
set deleted_by = 'lkhvichia',
    deleted_date = current_date
from upd
where upd.id = bi.id