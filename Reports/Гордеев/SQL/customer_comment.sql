select cu.customer_number num,
       cu.name nam,
       cc.comment_ comm,
       cat.name cat,
       cc.created_date cr_da,
       cc.created_by cr_by
from prx_Customer_Comment cc
join prx_customer cu on cu.id = cc.customer_id
join prx_customer_category cat on cu.category_id = cat.id  