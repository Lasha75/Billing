SELECT stat."name" Status, 
	count(cu.id) Quantity, 
	cat."name" Category, 
	bc."name" Business_Center
FROM prx_customer cu JOIN prx_status stat ON stat.id = cu.status_id
JOIN prx_customer_category cat ON cat.id = cu.category_id 
JOIN prx_business_center bc ON bc.id = cu.business_center_id
GROUP BY stat."name", 
	cat."name", 
	bc."name";