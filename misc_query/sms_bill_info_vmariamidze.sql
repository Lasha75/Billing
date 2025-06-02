with cc as (select customer_id,
                   contact_info
            from prx_customer_contact
            where deleted_by is null
            and contact_type = 'MOBILE_PHONE'),
     cu as (select cu.id,
                   customer_number,
                   cat.name
            from prx_customer cu
            join public.prx_customer_category cat on cu.category_id = cat.id
            where cu.deleted_by is null
              and sms_bill)

/*select cu.customer_number,
       cu.name,
       cc.contact_info
from (select contact_info,
             count(customer_id) cn
      from prx_customer_contact cc
      where cc.contact_type = 'MOBILE_PHONE'
        and cc.deleted_by is null
--         and cc.contact_info = '500050608'
      group by contact_info) ci
join cc on cc.contact_info = ci.contact_info
join cu on cu.id = cc.customer_id
where cn > 1
order by 3;*/


/*select cu.customer_number,
       cu.name,
       cc.contact_info
from (select customer_id,
             count(contact_info) cn
      from prx_customer_contact cc
      where cc.deleted_by is null
--         and cc.customer_id = '33038a9b-af31-f810-82b6-2f0b1032393f'
      group by customer_id) ci
join cc on cc.customer_id = ci.customer_id
join cu on cu.id = cc.customer_id
where cn > 1
order by 1;*/




select distinct cu.customer_number,
       cu.name,
       ms.phone_number
      from prx_rect_message ms
      join cu on cu.id = ms.customer_id
      where sms_location = 'DELIVERED_TO_PHONE'
        and deleted_by is null;