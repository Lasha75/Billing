SELECT cu.customer_number cust_num,
	cu.full_name cust_name,
	bc."name" bc,
	tr.amount,
	tr.created_date
FROM prx_customer cu
JOIN prx_business_center bc ON bc.id = cu.business_center_id
left join prx_transaction tr on tr.customer_id = cu.id and tr.deleted_by is null
where bc.id ='365336cf-6b24-cf5f-98d9-5a991dbc685d'
  and tr.trans_type_combination_id='df95642d-0f4c-cd63-7689-8b7d4fb80d41' --გადახდა ნაღდი









 

