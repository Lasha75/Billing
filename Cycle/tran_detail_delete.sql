select created_date,
       amount,
       kilowatt_hour,
       view_detail_connection_id,
       *
from prx_transaction
where customer_number = '8519784'
  and deleted_by is null
order by created_date desc;

select *
from prx_transaction_view_detail
where connection_id = 'ade0e657-299a-41a1-93c6-7c631a03156e';

delete
from prx_transaction_view_detail
where connection_id = 'ade0e657-299a-41a1-93c6-7c631a03156e';

update prx_transaction
set view_detail_connection_id = null
where view_detail_connection_id = 'ade0e657-299a-41a1-93c6-7c631a03156e';