with cust as (select cu.customer_number,
       cc.name category,
       cu.social_municipality,
       cu.social_category_socially_unsecured,
       cu.last_modified_by
from prx_customer cu
join prx_customer_category cc on cu.category_id = cc.id
where cc.code in ('C249','C248', 'C37', 'C256', 'C258', 'C257',
                  'C44', 'C259', 'C261', 'C260', 'C263', 'C252')
and cu.social_municipality /*or cu.social_category_socially_unsecured)*/)

update prx_customer c
set social_municipality = false,
    last_modified_by = 'lkhvichia',
    last_modified_date=now()
from cust cu
where cu.customer_number = c.customer_number