select created_date,
       amount,
       kilowatt_hour,
       view_detail_connection_id,
       *
from prx_transaction
where customer_number = '8663001'
  and deleted_by is null
order by created_date desc;

select *
from prx_transaction_view_detail
where connection_id = '2f114dae-9f25-4b57-b9c7-7ece18f6a6bb';

delete
from prx_transaction_view_detail
where connection_id = '2f114dae-9f25-4b57-b9c7-7ece18f6a6bb';

update prx_transaction
set view_detail_connection_id = null
where view_detail_connection_id = '2f114dae-9f25-4b57-b9c7-7ece18f6a6bb';