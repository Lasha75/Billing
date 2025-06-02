with cont as (select *
              from crosstab('select customer_id,
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
                  as res (cust uuid, CONTACT_PERSON text, mail text, FAX text, home text, mob text, work text)),
     supl_contr as (select contr.id,
                           contr.customer_id
                    from prx_supply_contract contr
                    join public.prx_status st on contr.status_id = st.id
                    where st.code = '3' --active
                      and contr.deleted_by is null
                      and st.deleted_by is null),
    own_id as (SELECT distinct customer_id,
                       regexp_replace(COALESCE(NULLIF(personal_id, ''), tax_id), '[\x00-\x1F\x7F]', '', 'g') AS ow_id
                      FROM prx_proprietor_information
                      WHERE deleted_by IS NULL
                        AND end_date IS NULL
                        AND COALESCE(NULLIF(personal_id, ''), tax_id) IS NOT NULL),
     ben_id as (select pbi.customer_id,
                       pbi.personal_id
                from prx_beneficiary_information pbi
                where pbi.deleted_by is null
                  and end_date is null)



select *
from (select distinct cu.customer_number                                                                num,
                      cat.name                                                                          cat,
                      bc.name                                                                           bc,
                      act.name                                                                          act,
--                 st.name                                                                    stat,
                      case
                          when coalesce(dep.id::text, '') != '' then 'Yes'
                          else 'No'
                          end                                                                           ovd_dep,
                      case
                          when coalesce(sc.id::text, '') = '' then 'No'
                          else 'Yes' end                                                                 sup_contr,
                      case
                          when coalesce(cont.mob, '') = '' then 'No'
                          else 'Yes' end                                                                mob,
                      case
                          when coalesce(cont.mail, '') = '' then 'No'
                          else 'Yes' end                                                                mail,
                      case when cu.needs_el_bill then 'Yes' else 'No' end                               p_bill,
                      regexp_replace(COALESCE(NULLIF(cu.identification_number, ''), NULLIF(o.ow_id, ''), b.personal_id), '[\x00-\x1F\x7F]', '', 'g') AS id,
                      regexp_replace(coalesce(adr.register_code::text, ''), '[\x00-\x1F\x7F]', '', 'g') reg_cod,
                      row_number() over (partition by cu.customer_number order by adr.register_code)    rn
      from public.prx_customer cu
      left join prx_active_overdue_deposits_table dep on dep.customer_number = cu.customer_number
      left join prx_activity act on cu.activity_id = act.id
      left join supl_contr sc on sc.customer_id = cu.id
      join public.prx_customer_category cat on cu.category_id = cat.id
      left join public.prx_business_center bc on bc.id = cu.business_center_id
      left join "Billing_TestDB".public.prx_customer_address adr on cu.id = adr.customer_id
      left join cont on cont.cust = cu.id
      left join own_id o on o.customer_id = cu.id
      left join ben_id b on b.customer_id = cu.id
      where cu.deleted_by is null
        and bc.deleted_by is null
        and cu.status_id in ('7d715a6e-079a-b999-8f0c-00bd2748562d', 'e1bf6037-c89e-e0ba-3f29-fa9fc84babca')--active, closed
        and adr.deleted_by is null) c
where c.rn = 1;




