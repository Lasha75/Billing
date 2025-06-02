CREATE TABLE "LK_test"."Transaction" (
	id int8 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE),
	cust_num varchar NOT NULL,
	amount money NULL,
	create_date date NULL,
	category_id uuid NULL,
	read_date date NULL,
	oper_combination uuid NULL
)
PARTITION BY RANGE (create_date);

CREATE TABLE aa_2023_whole PARTITION OF "LK_test"."Transaction"
   FOR VALUES FROM ('2023-01-01'::date) TO ('2024-01-01'::date);
  
CREATE TABLE CreateDate_default PARTITION OF "LK_test"."Transaction" DEFAULT;

INSERT INTO  (cust_num, amount, create_date, category_id, read_date, oper_combination) 
SELECT cu.customer_number, 
	tr.amount, 
	tr.created_date,
	tr.category_id ,
	tr.read_date ,
	tr.trans_type_combination_id 
FROM "Billing_TestDB".public.prx_transaction tr 
JOIN prx_customer cu ON cu.id = tr.customer_id;


EXPLAIN ANALYZE SELECT * FROM "LK_test"."Transaction" WHERE create_date >'2022-12-01'::date;
SELECT * FROM aa_2022_whole;
SELECT * FROM CreateDate_default

-- Drop table

-- truncate TABLE "LK_test"."Transaction";




   
