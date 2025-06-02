do $$
   <<DZ>>
    declare
        create_date_less_than date;
begin

        SELECT gen_random_uuid(),
               t.customer_id,
               sum(o.amount) AS amount,
               'open'
        FROM prx_open_transaction o
        INNER JOIN prx_transaction t ON t.id = o.transaction_id
        WHERE o.deleted_by IS NULL
          AND (((o.account_type_id = 'c425684a-1695-fca4-b245-73192da9a52e' OR o.account_type_id IS NULL) --თელმიკო
                    AND o.trans_type_combination_id NOT IN (SELECT id
                                                            FROM prx_transaction_type_combinati_vw
                                                            WHERE subtypecode IN ('036', '037', '038', '056', '017', '031'))/*გადახდა დეპოზიტი, გადახდა ნაღდი,
                                                                                                                              ვალი ვალის გადანაწილება,
                                                                                                                              ვალი ვალის პორცია,
                                                                                                                              ვალი ვალის გადანაწილების გაუქმება,
                                                                                                                              ძველი ვალის გადანაწილების გააქტიურება*/
            OR (o.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9' --დეპოზიტი
                AND o.trans_type_combination_id IN (SELECT id
                                                    FROM prx_transaction_type_combinati_vw
                                                    WHERE subtypecode IN ('062', '018', '200', '203', '063', '064')))))/*კრედიტ მემო დეპოზიტიდან ელ. ენერგიაში გადატანა,
                                                                                                                         ძველი დეპოზიტის გადახდის კორექტირება,
                                                                                                                         ძველი დეპოზიტის გადახდის მიღება,
                                                                                                                         ძველი დეპოზიტის გადახდის მიღების კორექტირება,
                                                                                                                         შესწორება დეპოზიტის მიღების კორექტირება,
                                                                                                                         ძველი დეპოზიტის მიღება*/
          AND t.created_date::date < '29-oct-2023'--create_date_less_than
        GROUP BY t.customer_id;

        SELECT gen_random_uuid(),
               t.customer_id,
               sum(ss.amount) AS amount,
               'settle'
        FROM prx_settle_transaction ss
        INNER JOIN prx_transaction t ON t.id = ss.transaction_id
        WHERE ss.deleted_by IS NULL
          AND ((ss.account_type_id = 'c425684a-1695-fca4-b245-73192da9a52e'--თელმიკო
            AND ss.trans_type_combination_id NOT IN (SELECT id
                                                     FROM prx_transaction_type_combinati_vw
                                                     WHERE subtypecode IN ('036', '037', '038', '056', '017', '031')))
        -- telmikos kontraqti an carieli
            OR (ss.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9')--დეპოზიტი
                   AND ss.trans_type_combination_id IN (SELECT id
                                                        FROM prx_transaction_type_combinati_vw
                                                        WHERE subtypecode IN ('062', '018', '200', '203', '063', '064')))
          AND t.created_date::date < create_date_less_than
        GROUP BY t.customer_id;

        SELECT gen_random_uuid(),
               t.customer_id,
               sum(ss.amount) AS amount,
               'settlePayment'
        FROM prx_settle_transaction ss
        INNER JOIN prx_transaction t ON t.id = ss.transaction_id
        WHERE ss.deleted_by IS NULL
          AND (ss.account_type_id = 'c425684a-1695-fca4-b245-73192da9a52e' OR--თელმიკო
               ss.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9')--დეპოზიტი
          AND (ss.trans_type_combination_id = '4a431bec-24cd-c871-b54d-3ef9ffe1eecb' OR --გადახდა დეპოზიტი
               ss.trans_type_combination_id = 'df95642d-0f4c-cd63-7689-8b7d4fb80d41') --გადახდა ნაღდი
          AND (t.reporting_date < payment_create_date_less_than OR t.reporting_date IS NULL)
        GROUP BY t.customer_id;

        SELECT gen_random_uuid(),
               t.customer_id,
               sum(o.amount) AS amount,
               'openPayment'
        FROM prx_open_transaction o
        INNER JOIN prx_transaction t ON t.id = o.transaction_id
        WHERE o.deleted_by IS NULL
          AND o.amount != 0 AND (o.account_type_id = 'c425684a-1695-fca4-b245-73192da9a52e'
                                    OR o.account_type_id IS NULL  OR o.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9')
                            AND (o.trans_type_combination_id = '4a431bec-24cd-c871-b54d-3ef9ffe1eecb'
                                        OR o.trans_type_combination_id = 'df95642d-0f4c-cd63-7689-8b7d4fb80d41')
                            AND (t.reporting_date < payment_create_date_less_than OR t.reporting_date IS NULL)
        GROUP BY t.customer_id;

end DZ $$;