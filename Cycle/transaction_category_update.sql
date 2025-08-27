create temp table tran on commit drop as (select offs.transaction_id
                                          from prx_settle_transaction str
                                          join prx_transaction tr on tr.id = str.transaction_id
                                          join prx_settle_transaction offs on str.connection_uuid = offs.connection_uuid
                                          where str.deleted_by is null
                                            and tr.deleted_by is null
                                            and tr.created_date between '2025-01-04' and '2024-12-30'
                                            and str.amount < 0
                                            and str.category_id is null
                                            and offs.amount > 0
                                            and offs.deleted_by is null
                                          group by offs.transaction_id);
select tr.category_id,
       tr.give_type_id,
       cu.category_id,
       cu.cust_category_id, --supply
       cat.name,
       tr.created_date
from prx_transaction tr -- prx_settle_transaction როდესაც კატეგორია პირდაპირ შეთავსებულებში იწერება
-- join "LK".tmp_lk t on t.cust_id = tr.customer_id
join prx_customer cu on tr.customer_id = cu.id
join prx_customer_category cat on cu.category_id = cat.id
where tr.deleted_by is null
  and tr.category_id is null
  and (tr.created_date between '2023-01-04' and current_date or
       tr.trans_date between '2025-07-04' and current_date)
--   and tr.amount < 0--for settle only როდესაც კატეგორია პირდაპირ შეთავსებულებში იწერება
  and cu.category_id is not null
  and tr.customer_number = '4716007';



update prx_transaction tr
set category_id = cu.category_id
-- from "LK".tmp_lk t
from prx_customer cu
where tr.customer_id = cu.id
  and tr.deleted_by is null
  and tr.category_id is null
  and (tr.created_date between '2025-08-04' and current_date or
       tr.trans_date between '2025-08-04' and current_date)
--   and tr.created_by = 'mppower'
  /*and cu.customer_number in (/*'3510329','6201950','7428429','2476396','5905434','3131177','7212768',
'3510329','2353964','4497075','7400822',*/'4716007'/*,'7456308','4212809','6918561','5715764','3349148',
'7215131','5137149','2443127','7000791','3886548','5928115','2818428'*/)*/
  and cu.category_id is not null;


update prx_open_transaction otr
set category_id = tr.category_id
from prx_transaction tr
-- join "LK".tmp_lk t on t.cust_id = tr.customer_id
where otr.transaction_id = tr.id
  and (tr.created_date between '2025-08-04' and current_date or--'2025-07-04' or
       tr.trans_date between '2025-08-04' and current_date)
  and otr.category_id is null
  and otr.deleted_by is null;


update public.prx_settle_transaction str
set category_id = tr.category_id
from prx_transaction tr
-- join "LK".tmp_lk t on t.cust_id = tr.customer_id
where tr.id = str.transaction_id
  and str.category_id is null
  and str.deleted_by is null
  and (str.created_date between '2025-07-04' and current_date or
       str.trans_date between '2025-07-04' and current_date or
       tr.created_date between '2025-07-04' and current_date)
  and str.amount > 0;


update public.prx_settle_transaction offs
set category_id = st.category_id
from prx_settle_transaction st
join prx_transaction tr on st.transaction_id = tr.id
-- join "LK".tmp_lk t on t.cust_id = st.customer_id
where st.deleted_by is null
  and st.amount > 0
  and st.category_id is not null
  and offs.category_id is null
  and offs.connection_uuid = st.connection_uuid
  and (offs.created_date between '2025-07-04' and current_date or
        offs.trans_date between '2025-07-04' and current_date or
        tr.created_date between '2025-07-04' and current_date or
        tr.trans_date between '2025-07-04' and current_date)
  and offs.amount < 0;



--------------------Settle-------------------------------------

update prx_settle_transaction str
set category_id = cu.category_id
-- from "LK".tmp_lk t
from prx_customer cu
where str.customer_id = cu.id
  and str.deleted_by is null
  and str.category_id is null
  and str.amount < 0
  and (str.created_date between '2025-08-04' and current_date or
        str.trans_date between '2025-08-04' and current_date)
/*and cu.customer_number in ('3510329','6201950','7428429','2476396','5905434','3131177','7212768',
'3510329','2353964','4497075','7400822','4716007','7456308','4212809','6918561','5715764','3349148',
'7215131','5137149','2443127','7000791','3886548','5928115','2818428')*/;



update public.prx_settle_transaction offs
set category_id = st.category_id
from prx_settle_transaction st
-- join prx_transaction tr on st.transaction_id = tr.id
where st.deleted_by is null
  and st.amount < 0
  and st.category_id is not null
  and offs.category_id is null
  and offs.connection_uuid = st.connection_uuid
  and (offs.created_date between '2025-08-04' and current_date or
        offs.trans_date between '2025-08-04' and current_date /*or
        tr.created_date between '2025-07-04' and current_date or
        tr.trans_date between '2025-07-04' and current_date*/)
  and offs.amount > 0
/*and offs.customer_number in ('3510329','6201950','7428429','2476396','5905434','3131177','7212768',
'3510329','2353964','4497075','7400822','4716007','7456308','4212809','6918561','5715764','3349148',
'7215131','5137149','2443127','7000791','3886548','5928115','2818428')*/;

/*
select *
from prx_settle_transaction offs
join prx_settle_transaction st on st.connection_uuid = offs.connection_uuid
where offs.customer_number='4716007' and
st.deleted_by is null
  and st.amount < 0
--   and st.category_id is not null
  and offs.category_id is null
  and offs.connection_uuid = st.connection_uuid
  and (offs.created_date between '2021-07-04' and current_date or
        offs.trans_date between '2021-07-04' and current_date /*or
        tr.created_date between '2025-07-04' and current_date or
        tr.trans_date between '2025-07-04' and current_date*/)
  and offs.amount > 0


*/