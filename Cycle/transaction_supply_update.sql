create temp table upd on commit drop as
    (select tr.id,
            cu.customer_number,
            case tr.category_id
                when '47609485-6652-4379-1965-551d27b138f5'
                    then '5231d021-b1ff-aa0e-68a0-7a1fd91d32b6'
                when '38eb611e-d83c-ca0c-6db9-d5f8f3185da4'
                    then '5231d021-b1ff-aa0e-68a0-7a1fd91d32b6'
                when '9bd618ef-0f63-c9a1-8c15-9b2bae6995b3'
                    then '5231d021-b1ff-aa0e-68a0-7a1fd91d32b6'
                when '6fe64bef-2fdd-c3b4-f0f9-e49729743f7c'
                    then '5231d021-b1ff-aa0e-68a0-7a1fd91d32b6'
                when '4851036f-dc24-8799-cdd6-de8cc5774469'
                    then '5231d021-b1ff-aa0e-68a0-7a1fd91d32b6'
                when '57c9a51a-f176-a0a0-6353-b2d9c02ca87b'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when '1c89179a-2e10-5aa0-4482-424a893f75a6'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when '2d410c69-e73e-50e3-40a1-6acf0f00d967'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when '1ed3f96d-14a4-331d-04e4-aaa109150bfc'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when '97ff849c-3f7a-b8d8-ef0b-ad3b392c72b6'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when '0b72463a-3d9c-d317-fe2f-c347a139c752'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when '2084a1d9-f5d1-d387-ef9a-d8ff698ec893'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when 'cfcfd9d8-498e-41bd-0b26-3efd6ac1f503'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when 'fb6f5644-3ead-b9db-c517-8233625b958f'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when '863ee488-5380-2ac6-2a6a-6d91b03877c2'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when 'fc465699-5a59-5d97-f5d7-eb03e3c10b2f'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when 'd4dc4f41-41e0-8e1e-8803-dcb0562a1ea5'--კომერციული
                    then cu.give_type_id
                when 'c6f7b736-9872-62a9-7249-6af5a08e77aa'
                    then cu.give_type_id
                when 'cb5acfb0-f4ee-b48b-16df-165fada8ac65'
                    then cu.give_type_id
                when 'b4dbeabe-44f0-d282-c0d4-311b6f201901'
                    then cu.give_type_id
                when 'be570c25-53eb-96c5-4321-c87aedfd9c75'
                    then cu.give_type_id
                end supl
     from prx_transaction tr
     join prx_customer cu on cu.id = tr.customer_id
     --join "LK".tmp_lk t on t.cust_id = tr.customer_id
     where tr.category_id is not null
       and (tr.trans_date between '2025-06-04' and current_date or
            tr.created_date between '2025-06-04' and current_date)
       and tr.give_type_id is null
       and tr.deleted_by is null
       and cu.deleted_by is null
--         and cu.customer_number='5194924'
/*       and (tr.account_type_id = 'c425684a-1695-fca4-b245-73192da9a52e'--თელმიკო
        or tr.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9'--დეპოზიტი
         or tr.account_type_id = '74a4b43c-2bb1-1321-b7f2-ba06dadc72ae') --თელასი*/
--   and tr.created_by = 'mppower'
    );

update prx_transaction tr --prx_settle_transaction
set give_type_id = supl
from upd
where upd.id = tr.id
  and supl is not null;

---------------------------------
select op.give_type_id,
       tr.give_type_id
From prx_open_transaction op
join prx_transaction tr on tr.id = op.transaction_id
where op.give_type_id is null
  and tr.give_type_id is not null
  and tr.created_date between '2023-08-16' and '2023-08-30';


update prx_open_transaction otr
set give_type_id = tr.give_type_id
from prx_transaction tr
-- join "LK".tmp_lk t on t.cust_id = tr.customer_id
where tr.id = otr.transaction_id
  and (tr.trans_date between '2025-06-04' and current_date or
       tr.created_date between '2025-06-04' and current_date)
  and otr.give_type_id is null
  and tr.give_type_id is not null
and otr.deleted_by is null;

----------------------------------

select str.give_type_id,
       tr.give_type_id,
       tr.created_date,
       str.created_date, *
from  public.prx_settle_transaction str
join prx_transaction tr on  tr.id = str.transaction_id
where  str.created_date between '2023-08-16' and '2023-08-30'
  and str.give_type_id is null
  and tr.give_type_id is not null
  and str.deleted_by is null
  and str.amount > 0;

update public.prx_settle_transaction str
set give_type_id = tr.give_type_id
-- from prx_customer tr
from prx_transaction tr
-- join "LK".tmp_lk t on t.cust_id = tr.customer_id
where tr.id = str.transaction_id
--     tr.customer_id = str.customer_id
--   and tr.created_date between  '2025-04-04' and '2025-05-01'
  and (str.trans_date between '2025-06-04' and current_date or
     str.created_date between '2025-06-04' and current_date)
  and str.give_type_id is null
  and tr.give_type_id is not null
  and str.deleted_by is null
  and tr.deleted_by is null
  and str.amount > 0;


select offs.give_type_id,
       st.give_type_id
from prx_settle_transaction st
join prx_settle_transaction offs on offs.connection_uuid = st.connection_uuid and offs.amount < 0
join prx_transaction tr on st.transaction_id = tr.id
where st.deleted_by is null
  and st.amount > 0
  and st.give_type_id is not null
  and offs.give_type_id is null
-- and st.customer_number='4861616'
   and tr.created_date between '2024-11-04' and '2025-01-08';

update public.prx_settle_transaction offs
set give_type_id = st.give_type_id
from prx_settle_transaction st
join prx_transaction tr on st.transaction_id = tr.id
-- join "LK".tmp_lk t on t.cust_id = st.customer_id
where st.deleted_by is null
  and st.amount > 0
  and st.give_type_id is not null
  and offs.give_type_id is null
  and offs.deleted_by is null
  and st.deleted_by is null
and (st.trans_date between '2025-06-04' and current_date or
     st.created_date between '2025-06-04' and current_date or
     tr.trans_date between '2025-06-04' and current_date or
     tr.created_date between '2025-06-04' and current_date )
  and offs.connection_uuid = st.connection_uuid
  and offs.amount < 0;



--------------------Settle-------------------------------------
create temp table upd on commit drop as
    (select tr.id,
            cu.customer_number,
            case tr.category_id
                when '47609485-6652-4379-1965-551d27b138f5'
                    then '5231d021-b1ff-aa0e-68a0-7a1fd91d32b6'
                when '38eb611e-d83c-ca0c-6db9-d5f8f3185da4'
                    then '5231d021-b1ff-aa0e-68a0-7a1fd91d32b6'
                when '9bd618ef-0f63-c9a1-8c15-9b2bae6995b3'
                    then '5231d021-b1ff-aa0e-68a0-7a1fd91d32b6'
                when '6fe64bef-2fdd-c3b4-f0f9-e49729743f7c'
                    then '5231d021-b1ff-aa0e-68a0-7a1fd91d32b6'
                when '4851036f-dc24-8799-cdd6-de8cc5774469'
                    then '5231d021-b1ff-aa0e-68a0-7a1fd91d32b6'
                when '57c9a51a-f176-a0a0-6353-b2d9c02ca87b'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when '1c89179a-2e10-5aa0-4482-424a893f75a6'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when '2d410c69-e73e-50e3-40a1-6acf0f00d967'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when '1ed3f96d-14a4-331d-04e4-aaa109150bfc'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when '97ff849c-3f7a-b8d8-ef0b-ad3b392c72b6'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when '0b72463a-3d9c-d317-fe2f-c347a139c752'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when '2084a1d9-f5d1-d387-ef9a-d8ff698ec893'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when 'cfcfd9d8-498e-41bd-0b26-3efd6ac1f503'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when 'fb6f5644-3ead-b9db-c517-8233625b958f'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when '863ee488-5380-2ac6-2a6a-6d91b03877c2'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when 'fc465699-5a59-5d97-f5d7-eb03e3c10b2f'
                    then '235e8e49-6440-6489-9ce6-f2c35230cd9c'
                when 'd4dc4f41-41e0-8e1e-8803-dcb0562a1ea5'--კომერციული
                    then cu.give_type_id
                when 'c6f7b736-9872-62a9-7249-6af5a08e77aa'
                    then cu.give_type_id
                when 'cb5acfb0-f4ee-b48b-16df-165fada8ac65'
                    then cu.give_type_id
                when 'b4dbeabe-44f0-d282-c0d4-311b6f201901'
                    then cu.give_type_id
                when 'be570c25-53eb-96c5-4321-c87aedfd9c75'
                    then cu.give_type_id
                end supl
     from prx_settle_transaction tr
     join prx_customer cu on cu.id = tr.customer_id
     --join "LK".tmp_lk t on t.cust_id = tr.customer_id
     where tr.category_id is not null
and (tr.trans_date between '2025-06-04' and current_date or
    tr.created_date between '2025-06-04' and current_date)
       and tr.give_type_id is null
       and tr.deleted_by is null
       and cu.deleted_by is null
       and cu.give_type_id is not null
--        and tr.created_by = 'mppower'
--   and tr.customer_number='2446419'
    and tr.amount < 0 );


update prx_settle_transaction tr
set give_type_id = supl
from upd
where upd.id = tr.id
  and supl is not null;

------------------------------------------------------------
/*update public.prx_settle_transaction str
set give_type_id = tr.give_type_id
-- from prx_customer tr
from prx_transaction tr
-- join "LK".tmp_lk t on t.cust_id = tr.customer_id
where tr.id = str.transaction_id
--     tr.customer_id = str.customer_id
  and tr.created_date between '2024-01-01' and '2024-01-31'
  and str.give_type_id is null
  and tr.give_type_id is not null
  and str.deleted_by is null
  and tr.deleted_by is null
  and str.amount > 0;*/

update public.prx_settle_transaction offs
set give_type_id = st.give_type_id
from prx_settle_transaction st
-- join prx_transaction tr on st.transaction_id = tr.id
-- join "LK".tmp_lk t on t.cust_id = st.customer_id
where st.deleted_by is null
  and st.amount < 0
  and st.give_type_id is not null
  and offs.give_type_id is null
  and offs.deleted_by is null
  and st.deleted_by is null
  and (st.created_date between '2025-06-04' and current_date or
       st.trans_date between  '2025-06-04' and current_date)
  and offs.connection_uuid = st.connection_uuid
--     and offs.customer_number='2446419'
  and offs.amount > 0;