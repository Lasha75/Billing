with bal as (select *
             from "LK".fn_current_balance_tlmc() bal
             join "LK".lk_customer_large cul on bal.cust_num = cul.customer_number),
     contr as (select cul.customer_number,
                      psc.customer_id,
                      ps.name,
                      case
                          when ps.code = '3' then 'Yes'
                          else 'No' end supply_contract,
                      psc.from_date,
                      psc.to_date
               from prx_supply_contract psc
               join prx_status ps on psc.status_id = ps.id
               left join "LK".lk_customer_large cul on cul.customer_id = psc.customer_id),
    own_id as (SELECT distinct customer_id,
                       regexp_replace(COALESCE(NULLIF(personal_id, ''), tax_id), '[\x00-\x1F\x7F]', '', 'g') AS ow_id
                      FROM prx_proprietor_information
                      WHERE deleted_by IS NULL
                        AND end_date IS NULL
                        AND COALESCE(NULLIF(personal_id, ''), tax_id) IS NOT NULL),
     ben_id as (select pbi.customer_id,
                       regexp_replace(COALESCE(pbi.personal_id, ''), '[\x00-\x1F\x7F]', '', 'g') personal_id
                from prx_beneficiary_information pbi
                where pbi.deleted_by is null
                  and end_date is null)

select distinct cu.customer_number                                                num,
                regexp_replace(COALESCE(cu.name, ''), '[\x00-\x1F\x7F]', '', 'g') name,
                cu.address_text                                                   addr,
                cua.register_code                                                 reg_code,
                regexp_replace(COALESCE(NULLIF(cu.identification_number, ''), NULLIF(o.ow_id, ''), b.personal_id), '[\x00-\x1F\x7F]', '', 'g') AS id,
                supl.name                                                         supl,
                cat.name                                                          cat,
                act.name                                                          act,
                st.name                                                           stat,
                volt.voltage                                                      vltg,
                bc.name                                                           bc,
                co.supply_contract                                                supl_co,
                co.from_date                                                      s_date,
                co.to_date                                                        e_date,
                bal.cur_bal
from public.prx_customer cu
join "LK".lk_customer_large t on t.customer_number = cu.customer_number
left join own_id o on o.customer_id = cu.id
left join ben_id b on b.customer_id = cu.id
left join contr co on co.customer_id = cu.id
left join bal  on bal.cust_num = cu.customer_number
left join prx_customer_address cua on cua.customer_id = cu.id
left join public.prx_give_type supl on supl.id = cu.give_type_id
left join public.prx_status st on cu.status_id = st.id
left join public.prx_customer_category cat on cu.category_id = cat.id
left join public.prx_business_center bc on bc.id = cu.business_center_id
left join (select cu.customer_number,
                  max(met.voltage) voltage
           from public.prx_customer cu
           left join public.prx_counter met on met.cust_key = cu.cust_key
           where met.deleted_by is null
           group by cu.customer_number) volt on volt.customer_number = cu.customer_number
left join public.prx_activity act on cu.activity_id = act.id
where cu.deleted_by is null
  and st.deleted_by is null
  and bc.deleted_by is null
  and cu.deleted_by is null
  and cua.deleted_by is null
  and supl.deleted_by is null


