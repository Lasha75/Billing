create temp table upd on commit drop as
    (select tr.id,
            cu.customer_number,
            met.voltage
     from prx_transaction tr
     join prx_customer cu on cu.customer_number = tr.customer_number
     join prx_counter met on met.cust_key = cu.cust_key and tr.counter_number = met.code
--      join "LK".tmp_lk t on t.cust_id = tr.customer_id
     where (tr.created_date between  '2025-04-04' and '2025-06-05' or
           tr.trans_date between  '2025-04-04' and '2025-06-05')
       and tr.deleted_by is null
       and coalesce(tr.voltage, '0')='0'
       and coalesce(tr.kilowatt_hour, 0) !=0
       and coalesce(tr.amount,0) >0
/*       and (tr.account_type_id = 'c425684a-1695-fca4-b245-73192da9a52e'--თელმიკო
        and tr.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9'--დეპოზიტი
         or tr.account_type_id = '74a4b43c-2bb1-1321-b7f2-ba06dadc72ae') --თელასი
         and tr.created_by = 'mppower'*/
    );

update prx_transaction tr
set voltage = upd.voltage
from upd
where upd.id = tr.id;

---------------------------------
select tr.id,
       otr.transaction_id,
       otr.id
from prx_open_transaction otr
join prx_transaction tr on  tr.id = otr.transaction_id
  and tr.created_date between '2024-02-01' and '2024-12-31'
  and coalesce(otr.voltage, '0')='0'
  and coalesce(tr.kilowatt_hour, 0) !=0
  and coalesce(tr.amount,0) >0;

update prx_open_transaction otr
set voltage = tr.voltage
from prx_transaction tr
-- join "LK".tmp_lk t on t.cust_id = tr.customer_id
where tr.id = otr.transaction_id
  and (tr.created_date between  '2025-04-04' and '2025-06-02' or
       tr.trans_date between  '2025-04-04' and '2025-06-02')
  and coalesce(otr.voltage, '0')='0'
  and coalesce(tr.kilowatt_hour, 0) !=0
  and coalesce(tr.amount,0) >0
  and otr.voltage is null;
--  and tr.created_by = 'mppower';
-----------------
select otr.voltage,
       tr.voltage
From prx_settle_transaction otr
join prx_transaction tr on tr.id = otr.transaction_id
join "LK".tmp_lk t on t.cust_id = tr.customer_id
where coalesce(otr.voltage, '0')='0'
  and coalesce(tr.kilowatt_hour, 0) !=0
  and coalesce(tr.amount,0) >0
and otr.amount > 0;
--   and tr.created_date between '2024-11-04' and '2024-12-03';

update public.prx_settle_transaction str
set voltage = tr.voltage
from prx_transaction tr
-- join "LK".tmp_lk t on t.cust_id = tr.customer_id
where tr.id = str.transaction_id
  and coalesce(str.voltage, '0')='0'
  and coalesce(tr.kilowatt_hour, 0) !=0
  and coalesce(tr.amount,0) > 0
    and (str.trans_date between '2025-04-04' and '2025-06-02' or
         str.created_date between '2025-04-04' and '2025-06-02')
--    and tr.created_by = 'mppower'
  and str.amount > 0;

-------------
select offs.voltage,
       st.voltage
from prx_settle_transaction st
join prx_settle_transaction offs on offs.connection_uuid = st.connection_uuid
join prx_transaction tr on st.transaction_id = tr.id
where st.deleted_by is null
  and st.amount > 0
  and coalesce(offs.voltage, '0')='0'
  and coalesce(tr.kilowatt_hour, 0) !=0
  and coalesce(tr.amount,0) > 0
--   and tr.created_date between '2024-11-04' and '2024-12-03'
  and (st.trans_date between '2024-03-04' and '2025-04-05' or
       st.created_date between '2024-03-04' and '2025-04-05')
  and offs.amount < 0;


