SELECT cu.customer_number cust_num,
	cu.full_name cust_name,
	bc."name" bc,
	tr.amount,
	tr.created_date,
	cu.is_centralized,
	op.ops_comb
FROM prx_customer cu
JOIN prx_business_center bc ON bc.id = cu.business_center_id
left join prx_transaction tr on tr.customer_id = cu.id and tr.deleted_by is null
left join "LK".vw_prx_ops_comb op on op.combid = tr.trans_type_combination_id
where bc.id in('365336cf-6b24-cf5f-98d9-5a991dbc685d', 'e369f67b-755f-35a1-f95b-9b88d72e7046')--ცენტრალური რაიონი, თელასის ცენტრალური ოფისი
  and coalesce(tr.amount,0)!=0
  and tr.trans_type_combination_id='df95642d-0f4c-cd63-7689-8b7d4fb80d41' --გადახდა ნაღდი









 

