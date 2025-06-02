select cu.customer_number cust,
       regexp_replace(coalesce(cu.name::text, ''), '[\x00-\x1F\x7F]', '', 'g')                  nam,
       cat.name cat
from prx_supply_contract sc
left join prx_customer cu on cu.id = sc.customer_id
join public.prx_customer_category cat on cu.category_id = cat.id
where info_send_by_sms
and cu.deleted_by is null
and sc.deleted_by is null;