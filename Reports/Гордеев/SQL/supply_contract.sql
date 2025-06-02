with att as (select psc.customer_id,
                    count(customer_id) attch
             from prx_supply_contract psc
             join prx_entity_attachment pea on psc.id = pea.entity_id
             where lower(pea.entity_name) = 'supplycontract'
             group by psc.customer_id)

select sc.created_date::date                                     as created_date,
       ss.name::text                                              as statusname,
       p.customer_number,
       regexp_replace(p.name, '[\x00-\x1F\x7F]', '', 'g')         as customer_name,
       regexp_replace(p.address_text, '[\x00-\x1F\x7F]', '', 'g') as address_text,
       kk.fullcategory,
       contact_info                                               as tel,
       email,
       giv.name                                                   as suppl,
       sc.from_date,
       sc.to_date,
       supply_ownership,
       coalesce(cur.amount, 0)                                    as dz,
       sc.doc_num,
       sc.notification_date                                         not_date,
       sc.lease_term                                                rent_per,
       case coalesce(attch, 0) when 0 then 'No attachment'
                                else 'Attachment exists'
        end attch
from prx_supply_contract sc
join prx_customer p on sc.customer_id = p.id and sc.deleted_by is null and p.deleted_by is null
left join prx_customer_vw v on p.id = v.id
left join prx_give_type giv on giv.id = p.give_type_id and giv.deleted_by is null
left join prx_status ss on ss.deleted_by is null and ss.id = sc.status_id and ss.type_='SUPPLYCONTRACT'
left join att on att.customer_id = sc.customer_id    
left join (select c.name as fullcategory,
                  c.id   as fullcategoryid,
                  d.name as category,
                  d.id   as categoryid
           from prx_customer_category c
           left join prx_drs_category_item cc on c.id = cc.category_id
           left join prx_drs_category d on d.id = cc.drs_category_id
           where c.deleted_by is null) kk on kk.fullcategoryid = p.category_id
left join (select customer_id,
                  string_agg(contact_info::text, ',') as contact_info
           from prx_customer_contact
           where deleted_by is null
             and contact_type = 'MOBILE_PHONE'
           group by customer_id) tel on tel.customer_id = p.id
left join prx_currentbalance_vw cur on cur.customer_id = sc.customer_id
where sc.created_date::date between ${startdate} and ${enddate}



