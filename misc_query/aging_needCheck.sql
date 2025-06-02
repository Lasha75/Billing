SELECT c.customer_number,
       o.customer_id,
       o.amount,
       CURRENT_DATE - o.due_date AS diff
FROM prx_open_transaction o
JOIN prx_customer c ON c.id = o.customer_id
JOIN prx_status st ON st.id = c.status_id
WHERE o.deleted_by IS NULL
  AND (o.used_in_bill = TRUE AND o.account_type_id = ((SELECT prx_parameters.telmiko_contract_id
                                                       FROM prx_parameters))
    OR (o.used_in_bill IS NULL
        OR o.used_in_bill = FALSE)
           AND (o.account_type_id = ((SELECT prx_parameters.telmiko_contract_id
                                      FROM prx_parameters))
            OR o.account_type_id IS NULL)
           AND o.amount < 0::NUMERIC)
  AND c.deleted_by IS NULL
  AND st.code::TEXT <> 'C3'::TEXT;