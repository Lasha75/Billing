select created_date,
       amount,
       kilowatt_hour,
       view_detail_connection_id,
       *
from prx_transaction
where customer_number = '7351867'
  and deleted_by is null
order by created_date desc;

select connection_id,
       *
from prx_transaction_view_detail
where connection_id = '73899ffc-9701-4245-adbf-28c1ab44ab93';

delete
from prx_transaction_view_detail
where connection_id = '73899ffc-9701-4245-adbf-28c1ab44ab93';

update prx_transaction
set view_detail_connection_id = null
where view_detail_connection_id = '73899ffc-9701-4245-adbf-28c1ab44ab93';