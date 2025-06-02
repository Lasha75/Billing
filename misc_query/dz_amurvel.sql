select gen_random_uuid(),
       t.customer_id,
       sum(o.amount) as amount,
       'open' --გადახდების გარდა ყველა ტრანზაქციის ჯამი ღია ტრანზაქციებიდან
from prx_open_transaction o
inner join prx_transaction t on t.id = o.transaction_id and t.deleted_by is null
where o.deleted_by is null
  and (((o.account_type_id = 'c425684a-1695-fca4-b245-73192da9a52e' or
         o.account_type_id is null) and o.trans_type_combination_id not in (select id
                                                                            from prx_transaction_type_combinati_vw
                                                                            where subtypecode in ('036', '037', '038', '056', '017', '031')) -- ოპერაციები კონტრაქტების მიხედვიდ არის დაფილტრული რომელი გამოიყენება ნაშთის დასაათვლელად
    or (o.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9' and o.trans_type_combination_id in (select id
                                                                                                       from prx_transaction_type_combinati_vw
                                                                                                       where subtypecode in ('062', '018', '200', '203', '063', '064', '119')))))
  and t.created_date::date < ${create_date_less_than}
  and t.customer_number = ${customerNumber}
group by t.customer_id;


select gen_random_uuid(),
       t.customer_id,
       sum(ss.amount) as amount,
       'settle' --გადახდების გარდა ყველა ტრანზაქციის ჯამი შეთავსებული ტრანზაქციებიდან
From prx_settle_transaction ss
inner join prx_transaction t on t.id = ss.transaction_id and t.deleted_by is null
where ss.deleted_by is null
  and ((ss.account_type_id = 'c425684a-1695-fca4-b245-73192da9a52e' and ss.trans_type_combination_id not in (select id
                                                                                                             from prx_transaction_type_combinati_vw
                                                                                                             where subtypecode in ('036', '037', '038', '056', '017', '031'))) -- ოპერაციები კონტრაქტების მიხედვიდ არის დაფილტრული რომელი გამოიყენება ნაშთის დასაათვლელად
    or (ss.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9') and
       ss.trans_type_combination_id in (select id
                                        from prx_transaction_type_combinati_vw
                                        where subtypecode in ('062', '018', '200', '203', '063', '064', '119')))
  and t.created_date::date < ${create_date_less_than}
  and t.customer_number = ${customerNumber}
group by t.customer_id;
-- 462.98

select gen_random_uuid(),
       t.customer_id,
       sum(ss.amount) as amount,
       'settlePayment' --გადახდების  ტრანზაქციის ჯამი შეთავსებული ტრანზაქციებიდან
from prx_settle_transaction ss
inner join prx_transaction t on t.id = ss.transaction_id and t.deleted_by is null
where ss.deleted_by is null
  and (ss.account_type_id = 'c425684a-1695-fca4-b245-73192da9a52e' or
       ss.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9')
  and (ss.trans_type_combination_id = '4a431bec-24cd-c871-b54d-3ef9ffe1eecb' or
       ss.trans_type_combination_id = 'df95642d-0f4c-cd63-7689-8b7d4fb80d41')
  and (t.reporting_date < ${payment_reporting_date_less_than} or
       (t.reporting_date is null and t.created_date < ${create_date_less_than}))
  and t.customer_number = ${customerNumber}
group by t.customer_id;
-- -681.15

select gen_random_uuid(),
       t.customer_id,
       sum(o.amount) as amount,
       'openPayment' --გადახდების ტრანზაქციის ჯამი ღია ტრანზაქციებიდან
from prx_open_transaction o
inner join prx_transaction t on t.id = o.transaction_id and t.deleted_by is null
where o.deleted_by is null
  and o.amount != 0
  and (o.account_type_id = 'c425684a-1695-fca4-b245-73192da9a52e' or o.account_type_id is null or
       o.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9')
  and (o.trans_type_combination_id = '4a431bec-24cd-c871-b54d-3ef9ffe1eecb' or
       o.trans_type_combination_id = 'df95642d-0f4c-cd63-7689-8b7d4fb80d41')
  and (t.reporting_date < ${payment_reporting_date_less_than} or
       (t.reporting_date is null and t.created_date < ${create_date_less_than}))
  and t.customer_number = ${customerNumber}
group by t.customer_id;
