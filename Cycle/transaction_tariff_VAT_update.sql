-------------------Tariff-------------------
select tr.id,
       tr.counter_number,
       tr.tariff_id,
       met.tariff_id,
       met.code,
       tr.counter_number
from prx_transaction tr
join prx_counter met on met.code = tr.counter_number and met.deleted_by is null
    where/* tr.category_id is not null
      and*/
        tr.deleted_by is null
--       and tr.counter_number is not null
   and   tr.trans_type_combination_id not in ('6587ae05-7344-1e95-191c-baf721abcd53', 'c5c3ac7d-8f2e-3f2e-5bf4-0a0e9b362b79','ce5ae29e-cf2a-1053-e58e-c16bf1063670')
;
      /*        and (tr.account_type_id = 'c425684a-1695-fca4-b245-73192da9a52e'--თელმიკო
--         and tr.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9'--დეპოზიტი
         or tr.account_type_id = '74a4b43c-2bb1-1321-b7f2-ba06dadc72ae') --თელასი
         and tr.created_by = 'mppower';*/

update prx_transaction tr
set tariff_id = met.tariff_id
from prx_counter met
where met.code = tr.counter_number
  and met.deleted_by is null
  and tr.category_id is not null
  and (tr.created_date between '2025-05-04' and '2025-06-05' or
       tr.trans_date between '2025-05-04' and '2025-06-05')
  and tr.tariff_id is null
  and tr.deleted_by is null
  and tr.counter_number is not null
/*        and (tr.account_type_id = 'c425684a-1695-fca4-b245-73192da9a52e'--თელმიკო
--         and tr.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9'--დეპოზიტი
   or tr.account_type_id = '74a4b43c-2bb1-1321-b7f2-ba06dadc72ae') --თელასი
and tr.created_by = 'mppower'*/;




----------------------------VAT type------------------
 create temp table upd on commit drop as
    (     select tr.id,
             tr.counter_number,
             tr.tariff_id,
             tr.customer_number,
             tar.vat_type,
             tr.amount,
             tr.created_date
      from prx_transaction tr
      join prx_tariff tar on tar.id = tr.tariff_id and tar.deleted_by is null
      where tr.category_id is not null
        and (tr.created_date between  '2025-05-04' and '2025-06-05' or
             tr.trans_date between  '2025-05-04' and '2025-06-05')
        and tr.vat_type is null
        and tr.deleted_by is null
/*        and (tr.account_type_id = 'c425684a-1695-fca4-b245-73192da9a52e'--თელმიკო
        and tr.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9'--დეპოზიტი
         or tr.account_type_id = '74a4b43c-2bb1-1321-b7f2-ba06dadc72ae') --თელასი*/
--          and tr.created_by = 'mppower'
--         and tr.customer_number='3515173'
         );

update prx_transaction tr
set vat_type = upd.vat_type
from upd
where upd.id = tr.id;
----------
select *
from prx_open_transaction otr
join prx_transaction tr on tr.id = otr.transaction_id
where tr.category_id is not null
  and tr.created_date between  '2025-02-04' and '2025-03-03'
  and otr.vat_type is null
    and tr.vat_type is not null
  and tr.deleted_by is null
  and otr.deleted_by is null
--   and tr.created_by = 'mppower'
;


update prx_open_transaction otr
set vat_type = tr.vat_type
from prx_transaction tr
where tr.id = otr.transaction_id
  and tr.category_id is not null
  and (tr.created_date between  '2025-05-04' and '2025-06-05' or
       tr.trans_date between  '2025-05-04' and '2025-06-05')
  and otr.vat_type is null
  and tr.vat_type is not null
  and tr.deleted_by is null
  and otr.deleted_by is null
-- and tr.created_by = 'mppower'
;
-----
/*update public.prx_settle_transaction str
set vat_type = tr.vat_type
from prx_transaction tr
where tr.id = str.transaction_id
  and tr.category_id is not null
  and tr.created_date between '2024-12-04' and '2025-01-08'
  and str.vat_type is null
  and tr.deleted_by is null
  and str.deleted_by is null
and tr.customer_number='5058331'*/

update public.prx_settle_transaction str
set vat_type = tr.vat_type
from prx_transaction tr
where tr.id = str.transaction_id
  and tr.category_id is not null
  --and tr.created_date between  '2025-02-04' and '2025-03-06'
  and (tr.created_date between  '2025-05-04' and '2025-06-05' or
       tr.trans_date between  '2025-05-04' and '2025-06-05')
  and str.vat_type is null
  and tr.vat_type is not null
  and str.deleted_by is null
--   and tr.created_by = 'mppower'
  and str.amount > 0;

update public.prx_settle_transaction offs
set vat_type = st.vat_type
from prx_settle_transaction st
join prx_transaction tr on st.transaction_id = tr.id
where st.deleted_by is null
  and st.amount > 0
  and st.vat_type is not null
  and offs.vat_type is null
  and offs.deleted_by is null
  and st.deleted_by is null
  and (tr.created_date between  '2025-05-04' and '2025-06-05' or
       tr.trans_date between  '2025-05-04' and '2025-06-05')
  and offs.connection_uuid = st.connection_uuid
  and offs.amount < 0;
