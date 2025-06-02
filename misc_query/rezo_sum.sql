-- Full Period Report --
SELECT cct.name             AS "section",
       ca.name              AS "activity",
       c.voltage            AS "voltage",
       t.step               AS "step",
       CASE
           WHEN cc.is_legal = true THEN 'არასაყოფაცხოვრებო'
           ELSE 'საყოფაცხოვრებო'
       END                  AS "is_legal",
       cc.name              AS "sector",
       tt.name              AS "operation",
       SUM(t.kilowatt_hour) AS "killowatt_hour",
       t.tariff_number      AS "tariff",
       SUM(t.amount)        AS "amount",
       cc.vat_type          AS "vat",
       p.bank_account       AS "bank_account"
FROM prx_transaction t
JOIN prx_customer cu ON cu.id = t.customer_id
LEFT OUTER JOIN prx_counter c ON c.code = t.counter_number
LEFT OUTER JOIN prx_customer_category cc ON cc.id = t.category_id
LEFT OUTER JOIN prx_payment p ON p.transaction_id = t.id::text
LEFT OUTER JOIN prx_category ca ON ca.id = cu.cust_category_id
JOIN prx_transaction_type_combinati ttc ON ttc.id = t.trans_type_combination_id
JOIN prx_transaction_type tt ON tt.id = ttc.transaction_type_id
JOIN prx_transaction_sub_type ts ON ts.id = ttc.transaction_sub_type_id
LEFT OUTER JOIN prx_tariff tf ON tf.id = t.tariff_id
JOIN prx_customer_contract_type cct ON cct.id = t.account_type_id
WHERE t.deleted_by IS NOT NULL
  AND t.amount IS NOT NULL
  AND ca.deleted_by IS NULL
  AND cc.deleted_by IS NULL
  AND cu.deleted_by IS NULL
  AND c.deleted_by IS NULL
  AND ca.deleted_by IS NULL
  AND ttc.deleted_by IS NULL
  AND tt.deleted_by IS NULL
  AND ts.deleted_by IS NULL
  AND tf.deleted_by IS NULL
  AND cct.deleted_by IS NULL
  AND t.created_date BETWEEN DATE '2023-09-04 00:00:00.000000' AND DATE '2023-10-03 00:00:00.000000'
  AND t.kilowatt_hour != 0 AND t.kilowatt_hour IS NOT NULL
  AND t.amount != 0 AND t.amount IS NOT NULL
GROUP BY c.voltage,
        t.step,
        cc.is_legal,
        ca.name,
        tt.name,
        t.tariff_number,
        cc.vat_type,
        cct.name,
        cc.name,
        p.bank_account

-- VAT check left and also calculation of VAT amount --

