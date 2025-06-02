with cont as (select * from crosstab('select customer_id,
                            contact_type,
                            contact_info
                        from public.prx_customer_contact
                        where lower(contact_info) not like ''%off%''
                            and deleted_by is null
                       order by 1',
                        'select distinct contact_type
                        from public.prx_customer_contact
                        where lower(contact_info) not like ''%off%''
                            and deleted_by is null
                        order by 1')
                       as
                       res (cust uuid, CONTACT_PERSON text, mail text, FAX text, home text,  mob text,  work text))

select distinct cu.id,
                cu.customer_number      num,
                cu.address_text addr,
                case when cu.with_contract then 'Yes' else 'No' end supply_contract,
                regexp_replace(COALESCE(cu.name, ''), '[\x00-\x1F\x7F]', '', 'g')   name,
                st.name                 stat,
                cat.name                cat,
                act.name                act,
                bc.name                 bc,
                cu.created_date         crda,
                cu.create_date          crda1,
                regexp_replace(coalesce(adr.street::text,''), '[\x00-\x1F\x7F]', '', 'g')str,
                regexp_replace(coalesce(adr.house::text, ''), '[\x00-\x1F\x7F]', '', 'g') hs,
                regexp_replace(coalesce(adr.building, ''), '[\x00-\x1F\x7F]', '', 'g') bld,
                regexp_replace(coalesce(adr.porch, ''), '[\x00-\x1F\x7F]', '', 'g') pr,
                regexp_replace(coalesce(adr.flate, ''), '[\x00-\x1F\x7F]', '', 'g') fl,
                bl.block_index          bl,
                met.serial_number       met,
                cu.identification_number,
                mob,
                home,
                work,
                mail,
                cu.needs_el_bill        p_bill,
                cu.email_bill           e_bill,
                cu.sms_bill             s_bill,
                case cu.delayer_status
                    when 'PERMANENT' then 'Yes'
                end                 perm_delay,
                cu1.customer_number     Parent_Customer,
                supl.name supl
from public.prx_customer cu
left join public.prx_give_type supl on supl.id = cu.give_type_id
left join public.prx_status st on cu.status_id = st.id
left join public.prx_customer_category cat on cu.category_id = cat.id
left join public.prx_business_center bc on bc.id = cu.business_center_id
/**/
left join public.prx_customer_contract cuc on cuc.customer_id = cu.id
left join public.prx_counter met on met.contract_id = cuc.id
left join public.prx_block bl on bl.id = met.block_id
/**/
left join public.prx_activity act on cu.activity_id = act.id
LEFT JOIN (SELECT ad.street,
               ad.building,
               ad.house,
               ad.porch,
               ad.flate,
               ad.customer_id,
               row_number() over (partition by ad.customer_id order by ad.last_modified_date desc) rn
            from  prx_customer_address ad
            where ad.deleted_by IS null) adr ON adr.customer_id = cu.id AND adr.rn = 1
left join  cont on cont.cust = cu.id
left join public.prx_customer cu1 on cu1.id = cu.parent_customer_id and cu1.status_id = '7d715a6e-079a-b999-8f0c-00bd2748562d'--active
where cu.deleted_by is null
  and cu1.deleted_by is null
  and cuc.deleted_by is null
  and met.deleted_by is null
  and bl.deleted_by is null
  and st.deleted_by is null
  and bc.deleted_by is null
  and bl.block_index =${bl}
  and st.code in ('C1', case when ${canc} = 'true' then 'C3' end , case when ${clo} = 'true' then 'C2' end);




