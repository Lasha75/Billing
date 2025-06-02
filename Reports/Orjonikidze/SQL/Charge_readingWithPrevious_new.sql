WITH op_combination(op_comb)  as (values ('de579ca8-118d-0f99-1012-c2e6b3a02307'), ('92064740-2471-1450-a569-ac4b7efe9a0c'),
                              ('a4e37496-cbb1-51bb-0a94-32bc07dd3710'), ('56d93680-b74a-7907-b80d-0d7d82bf9928'),
                              ('1e86b9f0-d09b-bed4-40a7-31cdebaf4249'), ('c5c3ac7d-8f2e-3f2e-5bf4-0a0e9b362b79')),
    READing as (SELECT tr.read_date,
                        tr.trans_date,
                        tr.created_date,
                        tr.counter_reading_value     reading,
                        tr.amount,
                        tr.kilowatt_hour             kwt,
                        bl."name"                    bl,
                        tr.customer_id,
                        tr.counter_serial_number,
                        tr.counter_number,
                        tr.trans_type_combination_id op
                 FROM prx_transaction tr
                 JOIN prx_block bl ON bl.id = tr.block_id
                 join op_combination op on tr.trans_type_combination_id = casT(op.op_comb as uuid)
                 WHERE date_trunc('day', tr.read_date) = ${read_date}
                   AND ((COALESCE(tr.amount, 0) = 0 AND COALESCE(tr.kilowatt_hour, 0) = 0) OR
                        (COALESCE(tr.amount, 0) != 0 AND COALESCE(tr.kilowatt_hour, 0) != 0))
/*                   AND tr.trans_type_combination_id IN
                       ('de579ca8-118d-0f99-1012-c2e6b3a02307', '92064740-2471-1450-a569-ac4b7efe9a0c',
                        'a4e37496-cbb1-51bb-0a94-32bc07dd3710', '56d93680-b74a-7907-b80d-0d7d82bf9928',
                        '1e86b9f0-d09b-bed4-40a7-31cdebaf4249',
                        'c5c3ac7d-8f2e-3f2e-5bf4-0a0e9b362b79' /*დარიცხვა ჩვენება, პირობითი, უმრიცხველო, ქვეაბონენტის ხარჯი, აქტი, ვაუჩერი*/)*/
                   AND tr.deleted_by IS NULL /*AND tr.customer_id='2b8da26d-1e72-f66e-af30-ac0fae266750'*/),
     prev_date AS (SELECT max(tl.read_date) prev_read_date,
                          tl.customer_id
                   FROM prx_transaction tl
                   join op_combination op on tl.trans_type_combination_id = casT(op.op_comb as uuid)
                   WHERE date_trunc('day', tl.read_date) < ${read_date}
                     /*AND tl.trans_type_combination_id IN
                         ('de579ca8-118d-0f99-1012-c2e6b3a02307', '92064740-2471-1450-a569-ac4b7efe9a0c',
                        'a4e37496-cbb1-51bb-0a94-32bc07dd3710', '56d93680-b74a-7907-b80d-0d7d82bf9928',
                        '1e86b9f0-d09b-bed4-40a7-31cdebaf4249',
                        'c5c3ac7d-8f2e-3f2e-5bf4-0a0e9b362b79' /*დარიცხვა ჩვენება, პირობითი, უმრიცხველო, ქვეაბონენტის ხარჯი, აქტი, ვაუჩერი*/)*/
                     AND tl.deleted_by IS NULL /*AND tl.customer_id='2b8da26d-1e72-f66e-af30-ac0fae266750'*/
                   GROUP BY customer_id),
     prev_read AS (SELECT tr.read_date
         prev_read_date,
                          tr.trans_date                prev_trans_date,
                          tr.created_date              prev_create_date,
                          tr.counter_reading_value     prev_read,
                          tr.amount                    prev_amount,
                          tr.kilowatt_hour             prev_kwt,
                          bl."name"                    prev_bl,
                          tr.customer_id,
                          tr.counter_serial_number     prev_serial,
                          tr.counter_number            prev_counter,
                          tr.trans_type_combination_id prev_op,
                          rd.read_date,
                          rd.trans_date,
                          rd.created_date,
                          rd.reading,
                          rd.amount,
                          rd.kwt,
                          rd.bl,
--			rd.customer_id,
                          rd.counter_serial_number,
                          rd.counter_number,
                          rd.op
                   FROM prx_transaction tr
                    join op_combination op on tr.trans_type_combination_id = casT(op.op_comb as uuid)
                   JOIN prx_block bl ON bl.id = tr.block_id
                   JOIN reading rd ON rd.customer_id = tr.customer_id AND tr.counter_number = rd.counter_number
                   WHERE tr.read_date = (SELECT prev_read_date
                                         FROM prev_date pd
                                         WHERE pd.customer_id = tr.customer_id)
                     AND ((COALESCE(tr.amount, 0) = 0 AND COALESCE(tr.kilowatt_hour, 0) = 0) OR
                          (COALESCE(tr.amount, 0) != 0 AND COALESCE(tr.kilowatt_hour, 0) != 0))
                     AND tr.deleted_by IS NULL
                     /*AND tr.trans_type_combination_id IN
                         ('de579ca8-118d-0f99-1012-c2e6b3a02307', '92064740-2471-1450-a569-ac4b7efe9a0c',
                          'a4e37496-cbb1-51bb-0a94-32bc07dd3710', '56d93680-b74a-7907-b80d-0d7d82bf9928',
                          '1e86b9f0-d09b-bed4-40a7-31cdebaf4249',
                          'c5c3ac7d-8f2e-3f2e-5bf4-0a0e9b362b79' /*დარიცხვა ჩვენება, პირობითი, უმრიცხველო, ქვეაბონენტის ხარჯი, აქტი, ვაუჩერი*/)/*AND tr.customer_id='2b8da26d-1e72-f66e-af30-ac0fae266750'*/*/),
     oper AS (SELECT ptt."name" || ' ' || ptst."name" op,
                     pttc.id                          combId
              FROM prx_transaction_type_combinati pttc
              JOIN prx_transaction_type ptt ON ptt.id = pttc.transaction_type_id
              JOIN prx_transaction_sub_type ptst ON ptst.id = pttc.transaction_sub_type_id
              WHERE ptt.deleted_by IS NULL
                and ptst.deleted_by IS NULL)


SELECT cu.customer_number cust_num,
       cu.id,
       cu.full_name       cust_name,
       cat."name"         cat,
       bc."name"          bc,
       prd.read_date,
       prd.trans_date,
       prd.counter_serial_number,
       prd.counter_number,
       prd.reading,
       prd.amount,
       prd.kwt,
       prd.bl,
       op.op,
       prd.prev_read_date,
       prd.prev_trans_date,
       prd.prev_read,
       prd.prev_serial,
       prd.prev_counter,
       prd.prev_amount,
       prd.prev_kwt,
       prd.prev_bl,
       op1.op             prev_op
FROM prx_customer cu
JOIN prev_read prd ON prd.customer_id = cu.id
JOIN prx_customer_category cat ON cat.id = cu.category_id
JOIN prx_business_center bc ON bc.id = cu.business_center_id
JOIN oper op ON op.combId = prd.op
JOIN oper op1 ON op1.combId = prd.prev_op