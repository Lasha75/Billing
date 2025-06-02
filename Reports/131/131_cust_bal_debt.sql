WITH filt_met AS (SELECT cust_key,
                         contract_id,
                         block_id,
                         ROW_NUMBER() OVER (PARTITION BY cust_key ORDER BY created_date DESC) AS rn
                  FROM prx_counter met
                  /*join prx_customer_contract cuc on met.contract_id = cuc.id*/
                  where met.deleted_by is null /*and cuc.deleted_by is null*/ ),
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

select cu.customer_number                                                num,
       regexp_replace(COALESCE(cu.name, ''), '[\x00-\x1F\x7F]', '', 'g') nam,
       cat.name                                                          cat,
       act.name                                                          act,
       st.name                                                           stat,
       bal.cur_bal,
       bal.old_am,
       dp.dep_am,
       dp.dep_lia,
       dp.bank_guar_am,
       bl.name                                                           bl,
       regexp_replace(COALESCE(NULLIF(cu.identification_number, ''), NULLIF(o.ow_id, ''), b.personal_id), '[\x00-\x1F\x7F]', '', 'g') AS id,
       sup.name sup
from prx_customer cu
join prx_customer_category cat on cu.category_id = cat.id
left join public.prx_status st on cu.status_id = st.id
left join prx_activity act on cu.activity_id = act.id
left join "LK".fn_current_balance_tlmc() bal on bal.cust_num = cu.customer_number
left join "LK".fn_deposit_info_tlmc() dp on dp.cust_num = cu.customer_number
left join filt_met met on met.cust_key = cu.cust_key AND met.rn = 1
left JOIN prx_block bl ON met.block_id = bl.id
left join own_id o on o.customer_id = cu.id
left join ben_id b on b.customer_id = cu.id
left join prx_give_type sup on cu.give_type_id = sup.id
where cu.deleted_by is null
  and cat.deleted_by is null
