--full settle
with /*prop_setl as (SELECT customer_id
                   FROM prx_open_transaction
                   WHERE deleted_by IS NULL
                     and trans_date::date > (now() - interval '3 year')::date
                   GROUP BY customer_id
                   HAVING SUM(amount) <= 0)*/,
     setld as (select str.transaction_id,
                     str.trans_date,
                     str.amount,
                     str.trans_type_combination_id,
                     str1.transaction_id,
                     str1.trans_date,
                     str1.amount,
                     str1.trans_type_combination_id
              from prx_settle_transaction str
              join prx_settle_transaction str1 on str.connection_uuid = str1.connection_uuid
              join prx_transaction tr on str.transaction_id = tr.id
              join prx_transaction_type_combinati op on str.trans_type_combination_id = op.id
              where str.deleted_by is null
                and str.customer_number ='5871568' and tr.trans_date='2025-02-25'
                and str.trans_date::date > (current_date - interval '3 year')::date
                and op.transaction_type_id in ( 'd15117f5-7d9e-e6a0-bda6-01b1f33ccb0a', --გადახდა
                                              '7902fe57-9a18-35d3-4ab3-b593c1884a13')),--დარიცხვა
     tran as (select tr.id,
                     tr.customer_number,
                     tr.customer_id,
                     tr.amount,
                     tr.trans_date,
                     tr.due_date
              from prx_transaction tr
              join prx_transaction_type_combinati op on tr.trans_type_combination_id = op.id
              where tr.deleted_by is null
                and tr.account_type_id in ('c425684a-1695-fca4-b245-73192da9a52e', '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9')--თელმიკო, დეპოზიტი
                and op.transaction_type_id = '7902fe57-9a18-35d3-4ab3-b593c1884a13'                                                      --დარიცხვა
                and tr.trans_date::date > (current_date - interval '3 year')::date
                and tr.due_date is not null
                and tr.amount > 0),
    dlr as (select customer_id,
                    start_date,
                    end_date
             from prx_delayer dr
             where deleted_by is null
               and lower(dr.status) in ('finished', 'active', 'delay_abolished')
               and lower(dr.type_) = 'short_term'
             and customer_id='00130146-b5b0-ac5f-2f4a-e9a3fe38d912')

select distinct customer_number
from (select tr.id,
             tr.customer_number,
             tr.amount,
             str.amount,
             str.trans_date,
             tr.trans_date,
             tr.due_date
      from tran tr
--       join f_setl otr on tr.customer_id = otr.customer_id
      join setl str on str.transaction_id = tr.id
      where str.trans_date <= tr.due_date/*) tt*/
        and tr.customer_number in ('5282491', '7141087', '5931281')) tt;


select * from prx_transaction where customer_number='5953248' and trans_date::date = '2025-02-25'
select * from prx_settle_transaction where transaction_id='008bcdaa-1293-4c93-872f-7b7b5d9a703e'

select * from prx_settle_transaction where connection_uuid in ('fca8c00a-1aa7-4920-b0a2-64539be2cbb7',
'cc79a833-7727-4083-872c-c70f1c132b32',
'cf544bbd-88b1-46a0-a12c-911e3abe0c4a')



select str.transaction_id,
                     str.trans_date,
                     str.amount,
                     str.trans_type_combination_id,
                     str1.transaction_id,
                     str1.trans_date,
                     str1.amount,
                     str1.trans_type_combination_id
              from prx_settle_transaction str
              join prx_settle_transaction str1 on str.connection_uuid = str1.connection_uuid
              join prx_transaction tr on str.transaction_id = tr.id
              join prx_transaction_type_combinati op on str.trans_type_combination_id = op.id
              where str.deleted_by is null
                and str.customer_number ='5871568' and tr.trans_date='2025-02-25'
                and str.trans_date::date > (current_date - interval '3 year')::date
                and op.transaction_type_id in ( 'd15117f5-7d9e-e6a0-bda6-01b1f33ccb0a', --გადახდა
                                              '7902fe57-9a18-35d3-4ab3-b593c1884a13')