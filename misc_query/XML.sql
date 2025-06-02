select * from public.prx_customerbalancelog
   where lower(user_name) like '%bog%'   and cast(start_date as date) > '2024-07-01'

select min(start_date) from public.prx_customerbalancelog
   where lower(user_name) like '%bog%'   and cast(start_date as date) > '2024-07-01'
-- {"request":{"customerNumber":"6057054","amount":"5.57","paymentDate":"2024-07-02T14:45:07","bankId":"BOG","channelId":"MBANK","paymentId":"12328014670"}}