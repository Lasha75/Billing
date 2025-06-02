SELECT tt.customer_number,
       sum(tt.amount)
FROM (SELECT prx_settle_transaction.customer_id,
             prx_settle_transaction.customer_number,
             prx_settle_transaction.amount,
             prx_settle_transaction.transaction_id
      FROM prx_settle_transaction
      WHERE prx_settle_transaction.account_type_id in ('c425684a-1695-fca4-b245-73192da9a52e'::uuid, '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9')
        AND prx_settle_transaction.deleted_by IS NULL
      UNION ALL
      SELECT prx_open_transaction.customer_id,
             prx_open_transaction.customer_number,
             prx_open_transaction.amount,
             prx_open_transaction.transaction_id
      FROM prx_open_transaction
      WHERE prx_open_transaction.account_type_id in ('c425684a-1695-fca4-b245-73192da9a52e'::uuid, '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9')
        AND prx_open_transaction.deleted_by IS NULL) tt
JOIN prx_transaction p ON tt.transaction_id = p.id AND p.deleted_by IS NULL
-- where tt.customer_number='4867442'
GROUP BY tt.customer_number
-- when o.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9' -- deposit

