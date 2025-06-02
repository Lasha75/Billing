/*select id,
       used_in_bill,
       created_date
from public.prx_open_transaction
where (date(created_date) = '31-jul-2024' )
  and customer_number = '3382609';*/

update public.prx_transaction
set --used_in_bill = false
    created_date=''
where id in (select id/*,
                    used_in_bill,
                    last_modified_by,
                    created_date*/
             from public.prx_transaction
             where (date(created_date) = '31-jul-2024')
               and customer_number = '7326048');