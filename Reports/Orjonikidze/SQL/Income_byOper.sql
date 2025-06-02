SELECT sum(tr.amount) amount,
	sum(COALESCE(tr.kilowatt_hour, 0) kwt,
	ptt."name" || ' ' || ptst."name" oper_comb
FROM prx_transaction tr
JOIN prx_transaction_type_combinati pttc ON pttc.id = tr.trans_type_combination_id AND pttc.deleted_by IS NULL
JOIN prx_transaction_type ptt ON ptt.id = pttc.transaction_type_id AND ptt.deleted_by IS NULL
JOIN prx_transaction_sub_type ptst ON ptst.id = pttc.transaction_sub_type_id AND ptst.deleted_by IS NULL
JOIN prx_customer cu ON cu.id = tr.customer_id AND cu.deleted_by IS null
JOIN prx_customer_category cat ON cat.id = cu.category_id AND cat.deleted_by IS NULL

JOIN prx_category supl ON supl.id = cu.cust_category_id AND supl.deleted_by IS NULL
LEFT JOIN public.prx_counter met ON met.code = tr.counter_number AND met.deleted_by IS null
WHERE tr.created_date BETWEEN  DATE  ${start_date} AND DATE ${end_date}  AND tr.deleted_by IS NULL
GROUP BY ptt."name",
	ptst."name",
	cat."name",
	bc.name,
	supl."name",
	met.voltage