select  distinct
c.customer_number as abonentisnomeri,
regexp_replace(c.name, '[\x00-\x1F\x7F]', '', 'g') as customerName,
regexp_replace(c.address_text, '[\x00-\x1F\x7F]', '', 'g') as address_text,
cc.name as moxmarebisseqtori,
ccc.name as miwodebistipi,
s.name as status,
co.voltage as simdzlavre,
b.name as businessCenter,
coalesce(vw.amount,0) as amount,
act.name act
from prx_customer   c
left join prx_business_center  b on c.business_center_id = b.id and b.deleted_by is null
left join prx_customer_category cc on c.category_id = cc.id and cc.deleted_by is null
left join prx_status s on c.status_id = s.id and s.deleted_by is null
left join prx_give_type ccc on c.give_type_id = ccc.id and ccc.deleted_by is null
left join prx_counter co on  c.cust_key=co.cust_key and co.deleted_by is null
left join prx_currentbalancenew1_vw vw on vw.customer_id=c.id
left join prx_activity act on c.activity_id = act.id
where c.deleted_by is null
        and ccc.code !='C4'--tranz
        and act.code !='A303' --საბალანსო
        and cc.code not in ('C326', 'C40', 'C41', 'C39') --თელმიკო
        and b.code not in('B8', 'B6', 'B11', 'B3', 'B13')