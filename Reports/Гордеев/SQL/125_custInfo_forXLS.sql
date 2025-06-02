with cust as (select cu.id,
                     cu.customer_number,
                     regexp_replace(COALESCE(cu.name, ''), '[\x00-\x1F\x7F]', '', 'g') Name,
                     st.name                                                           Status,
                     cat.name                                                          Category,
                     act.name                                                          Activity,
                     cu.needs_el_bill                                                  printed_bill,
                     cu.email_bill,
                     cu.sms_bill,
                     case cu.delayer_status
                         when 'PERMANENT' then 'Yes'
                         else 'No'
                         end                                                           Permanent_Delay,
                     cu1.customer_number                                               Parent_Customer,
                     cu.create_date,
                     bal.bln,
                     bc.name                                                           bc
              from prx_customer cu
              left join (select r.customer_number,
                                r.davalianebaamount bln
                         from prx_debtor_balance_report r /*prx_currentbalancenew1_vw*/
                         where r.period_ = ${Period}
                           and coalesce(r.davalianebaamount, 0) != 0
                           and r.customer_number not in ('6016601', '7160190', '5015501')) bal
                        on bal.customer_number = cu.customer_number
              join prx_status st on cu.status_id = st.id
              join prx_customer_category cat on cu.category_id = cat.id
              left join prx_activity act on cu.activity_id = act.id
              left join prx_business_center bc on cu.business_center_id = bc.id
              left join prx_customer cu1 on cu1.id = cu.parent_customer_id and cu1.is_centralized = 'true'
                  and cu1.deleted_by is null
              /*where cu.customer_number='8280175'*/),
     mail as (select c.customer_number,
                     Email
              from (select case cn.contact_type
                               when 'EMAIL' then cn.contact_info
                               else 'No'
                               end Email,
                           cu.customer_number
                    from prx_customer_contact cn
                    join prx_customer cu on cn.customer_id = cu.id
                    where cu.deleted_by is null
                      and cn.deleted_by is null) c
              where Email != 'No'),
     mob as (select distinct cu.customer_number,
--                              'Yes' Mobile
                             CASE when lower(cn.contact_info) not like '%off%' then 'Yes' end Mobile,
                             CASE when lower(cn.contact_info) like '%off%' then 'Yes' end Mobile_off
             from prx_customer_contact cn
             join prx_customer cu on cn.customer_id = cu.id and cn.contact_type = 'MOBILE_PHONE'
             where cu.deleted_by is null
               and cn.deleted_by is null
         and (lower(cn.contact_info) not like '%off%' or lower(cn.contact_info) like '%off%'))/*,
     mob_off as (select distinct cu.customer_number,
                                 'Yes' Mobile
                 from prx_customer_contact cn
                 join prx_customer cu on cn.customer_id = cu.id and cn.contact_type = 'MOBILE_PHONE'
                 where cu.deleted_by is null
                   and cn.deleted_by is null
                   and lower(cn.contact_info) like '%off%'
                 and cu.customer_number='0013755')*//*,
     bal AS (select r.customer_number,
                    r.davalianebaamount
             from prx_debtor_balance_report r /*prx_currentbalancenew1_vw*/
             where r.period_ = ${Period}
               and coalesce(r.davalianebaamount, 0) != 0
               and r.customer_number not in ('6016601', '7160190', '5015501'))*/


select distinct c.customer_number num,
                c.Name            name,
                c.Category        cat,
                c.activity        act,
                c.Status          stat,
                c.sms_bill        s_bill,
                c.email_bill      e_bill,
                c.printed_bill    p_bill,
                c.Permanent_Delay perm_delay,
                c.Parent_Customer par,
                ml.Email          email,
                mb.Mobile         mob,
                mb.Mobile_off     m_off,
--                 mbo.Mobile m_off,
                c.bln,
                c.create_date     cr_dt,
                c.bc
from cust c
left join mail ml on ml.customer_number = c.customer_number
left join mob mb on mb.customer_number = c.customer_number
-- left join mob_off mbo on mbo.customer_number = c.customer_number
--  where c.customer_number='8461906'
-- left join bal b on b.customer_number = c.customer_number


