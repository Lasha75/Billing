with cust (cu_numb) as (values ('8159636'))

SELECT  distinct cu.customer_number,
        bl."name" block
FROM prx_counter met
JOIN prx_customer_contract cuc ON met.contract_id = cuc.id AND cuc.deleted_date IS NULL
JOIN prx_block bl ON met.block_id = bl.id
join prx_customer  cu on cuc.customer_id = cu.id and cu.deleted_by is null
-- join cust c on cu.customer_number = c.cu_numb
        WHERE met.deleted_date IS NULL
                  AND met.block_id IS NOT NULL;

---------------------------------------------------------------------

update "LK".social_unprotected su
set block = bl.block_index
FROM prx_counter met
JOIN prx_customer_contract cuc ON met.contract_id = cuc.id AND cuc.deleted_date IS NULL
JOIN prx_block bl ON met.block_id = bl.id
join prx_customer cu on cuc.customer_id = cu.id and cu.deleted_by is null
WHERE met.deleted_date IS NULL
  AND met.block_id IS NOT NULL
  and su.cust_num = cu.customer_number;

select cust_num,
       block
from "LK".social_unprotected
where mayor and length(block::text)=1;

