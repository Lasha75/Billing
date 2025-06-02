with tmp as (select *
             from crosstab('select customer_number,
                            regexp_replace(COALESCE(cu.name, ''''), ''[\x00-\x1F\x7F]'', '''', ''g''),
                            contact_type,
                            contact_info
                        from public.prx_customer_contact cc
                       join prx_customer cu on cu.id = cc.customer_id
                        where cc.deleted_by is null and cu.deleted_by is null
                       order by 1',
                           'select distinct contact_type
                      from public.prx_customer_contact
                      where deleted_by is null
                      order by 1')
                 as res (num text, name text, CONT_PER text, mail text, FAX text, home text, mob text, work text)
             where mail is null
               and mob is null
    /*CONT_PER is not null*/)

select num,
       t.name,
       cont_per,
       mail,
       mob,
       cat.name                                                                   cat,
       bc.name                                                                     bc,
       regexp_replace(coalesce(adr.street::text, ''), '[\x00-\x1F\x7F]', '', 'g') str,
       regexp_replace(coalesce(adr.house::text, ''), '[\x00-\x1F\x7F]', '', 'g')  hs,
       regexp_replace(coalesce(adr.building, ''), '[\x00-\x1F\x7F]', '', 'g')     bld,
       regexp_replace(coalesce(adr.porch, ''), '[\x00-\x1F\x7F]', '', 'g')        pr,
       regexp_replace(coalesce(adr.flate, ''), '[\x00-\x1F\x7F]', '', 'g')        fl
from tmp t
join prx_customer cu on cu.customer_number = t.num
left join public.prx_customer_category cat on cu.category_id = cat.id
left join public.prx_business_center bc on bc.id = cu.business_center_id
LEFT JOIN (SELECT ad.street,
                  ad.building,
                  ad.house,
                  ad.porch,
                  ad.flate,
                  ad.customer_id,
                  row_number() over (partition by ad.customer_id order by ad.last_modified_date desc) rn
           from prx_customer_address ad
           where ad.deleted_by IS null) adr ON adr.customer_id = cu.id AND adr.rn = 1;

/*No ID*/
select cu.customer_number num,
       regexp_replace(COALESCE(cu.name, ''), '[\x00-\x1F\x7F]', '', 'g') name,
       cat.name           cat,
       bc.name            bc,
       cat.name                                                                   cat,
       bc.name                                                                     bc,
       regexp_replace(coalesce(adr.street::text, ''), '[\x00-\x1F\x7F]', '', 'g') str,
       regexp_replace(coalesce(adr.house::text, ''), '[\x00-\x1F\x7F]', '', 'g')  hs,
       regexp_replace(coalesce(adr.building, ''), '[\x00-\x1F\x7F]', '', 'g')     bld,
       regexp_replace(coalesce(adr.porch, ''), '[\x00-\x1F\x7F]', '', 'g')        pr,
       regexp_replace(coalesce(adr.flate, ''), '[\x00-\x1F\x7F]', '', 'g')        fl
from prx_customer cu
join prx_customer_category cat on cu.category_id = cat.id
left join prx_business_center bc on cu.business_center_id = bc.id
LEFT JOIN (SELECT ad.street,
                  ad.building,
                  ad.house,
                  ad.porch,
                  ad.flate,
                  ad.customer_id,
                  row_number() over (partition by ad.customer_id order by ad.last_modified_date desc) rn
           from prx_customer_address ad
           where ad.deleted_by IS null) adr ON adr.customer_id = cu.id AND adr.rn = 1
where cu.deleted_by is null
and coalesce(cu.identification_number, '') ='';









select cu.customer_number,
       regexp_replace(COALESCE(cu.name, ''), '[\x00-\x1F\x7F]', '', 'g'),
       aa.contact_type,
       aa.contact_info,
       cc.contact_type,
       cc.contact_info
from (select customer_id,
             contact_type,
             contact_info
      from public.prx_customer_contact cc
      where cc.deleted_by is null
        and lower(contact_type) like '%contact_person%') aa
join prx_customer cu on cu.id = aa.customer_id
join prx_customer_contact cc on cc.customer_id = cu.id
where cu.deleted_by is null
  and cc.deleted_by is null
order by 1