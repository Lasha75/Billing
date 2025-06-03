with pay (pid) as (values('3010422'), ('6384637'), ('4655830'), ('3401143'), ('1150854'), ('3738254'), ('7232130'), ('1498686'), '6314847', '4797090',
'6760463', '4385374', '1133311', '2858946', '1173802', '0950652', '0806257', '0047014', '2654764', '4174422', '0790451', '3341645', '0728797',
'6243237', '2628847', '4638672', '6457568', '0330662', '0019875', '3025103', '6396526', '0643138', '4736227', '6297535', '3057701', '2089180',
'6161654', '1650109', '5576673', '2695701', '6968588', '2836836', '0911516', '1705079', '5710705', '6765253', '9200376', '1807192', '0756649',
'2524673'*/)

SELECT pm.customer_number,
       sum(pm.amount) amount,
       pm.aviso_date,
       pm.reporting_date,
       pm.create_date,
	pm.bank_id,
	pm.bank_account,
	pm.payment_id
FROM prx_payment pm
join pay p on p.pid = pm.customer_number
/*WHERE pm.customer_number in ('3010422', '6384637', '4655830', '3401143', '1150854', '3738254', '7232130', '1498686', '6314847', '4797090',
'6760463', '4385374', '1133311', '2858946', '1173802', '0950652', '0806257', '0047014', '2654764', '4174422', '0790451', '3341645', '0728797',
'6243237', '2628847', '4638672', '6457568', '0330662', '0019875', '3025103', '6396526', '0643138', '4736227', '6297535', '3057701', '2089180',
'6161654', '1650109', '5576673', '2695701', '6968588', '2836836', '0911516', '1705079', '5710705', '6765253', '9200376', '1807192', '0756649',
'2524673')*/
GROUP BY pm.customer_number,
        pm.aviso_date,
        pm.reporting_date,
        pm.create_date,
	    pm.bank_id,
	    pm.bank_account,
	pm.payment_id;


SELECT pay.customer_number,
       sum(pay.amount) amount,
       pay.aviso_date,
       pay.reporting_date,
       pay.created_date,
       pay.trans_date,
       pay.bank_code,
       pay.bank_account,
       ptt."name" || ' ' || ptst."name" oper_comb
from prx_transaction pay
jOIN prx_transaction_type_combinati pttc ON pttc.id = pay.trans_type_combination_id AND pttc.deleted_by IS NULL
JOIN prx_transaction_type ptt ON ptt.id = pttc.transaction_type_id AND ptt.deleted_by IS NULL
JOIN prx_transaction_sub_type ptst ON ptst.id = pttc.transaction_sub_type_id AND ptst.deleted_by IS NULL
WHERE pay.customer_number in
      ('3010422', '6384637', '4655830', '3401143', '1150854', '3738254', '7232130', '1498686', '6314847', '4797090',
       '6760463', '4385374', '1133311', '2858946', '1173802', '0950652', '0806257', '0047014', '2654764', '4174422',
       '0790451', '3341645', '0728797', '6243237', '2628847', '4638672', '6457568', '0330662', '0019875', '3025103', '6396526', '0643138', '4736227',
       '6297535', '3057701', '2089180', '6161654', '1650109', '5576673', '2695701', '6968588', '2836836', '0911516', '1705079', '5710705', '6765253',
       '9200376', '1807192', '0756649', '2524673')
  and pay.trans_type_combination_id in ('432e1ddf-a1a2-5554-5875-af6ce0290de5', '4a431bec-24cd-c871-b54d-3ef9ffe1eecb',
                                        'df95642d-0f4c-cd63-7689-8b7d4fb80d41', '2b323c70-6f1c-e79f-3e2e-2828e9dc343b')
GROUP BY pay.customer_number,
       pay.aviso_date,
       pay.reporting_date,
       pay.created_date,
       pay.trans_date,
       pay.bank_code,
       pay.bank_account,
       ptt."name",
       ptst."name"