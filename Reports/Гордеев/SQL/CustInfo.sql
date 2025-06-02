with cust as (select cu.customer_number,
                     cu.name                                                                        Name,
                     st.name                                                                         Status,
                     cat.name                                                                        Category,
                     act.name                                                                        Activity,
                     /*case cn1.contact_type
                         when 'MOBILE_PHONE' then 'Yes'
                         else 'No'
                         end                                                                         Mobile,*/
                     cu.needs_el_bill                                                                printed_bill,
                     cu.email_bill,
                     cu.sms_bill,
                     case cn1.contact_type
                         when 'EMAIL' then cn1.contact_info
                         else ''
                         end                                                                         Email,
                     case cu.delayer_status
                         when 'PERMANENT' then 'Yes'
                         else 'No'
                         end                                                                         Permanent_Delay,
                     cu1.customer_number                                                             Parent_Customer/*,
                     row_number() over (partition by cu.customer_number order by cu.customer_number) rn*/
              from prx_customer cu
               join prx_status st on cu.status_id = st.id
               join prx_customer_category cat on cu.category_id = cat.id
               left join prx_activity act on cu.activity_id = act.id
               --left join prx_customer_contact cn on cu.id = cn.customer_id and cn.contact_type='MOBILE_PHONE'
               left join prx_customer_contact cn1 on cu.id = cn1.customer_id
               left join prx_customer cu1 on cu1.id = cu.parent_customer_id
              where cu.deleted_by is null
                and cu1.deleted_by is null

--                 and cn.deleted_by is null
                /*and lower(cn1.contact_info) not like '%off%'*/),
mob as (select * from (
        select cu.customer_number,
                case cn.contact_type
                    when 'MOBILE_PHONE' then 'Yes'
                    else 'No'
                    end                                                                         Mobile,
                row_number() over (partition by cu.customer_number order by cu.customer_number) rn
        from prx_customer cu
        join prx_customer_contact cn on cu.id = cn.customer_id and cn.contact_type='MOBILE_PHONE'
        where lower(cn.contact_info) not like '%off%' and cu.deleted_by is null and cn.deleted_by is null) a
        where rn=1) --calke da mere vlookup

select * from cust c
left join mob m on  c.customer_number = m.customer_number
order by 1
-- where rn=1
