select c.customer_number,
       c.cust_key                                          as custkey,
       st.telasi_acc_key,
       t.read_date new_readdate,
       sum(t.kilowatt_hour) new_kwt,
       combi.operation_key NEW_RDTYPE
from prx_transaction t
join (select cc.customer_number as customer_number,
            /*cc.name            as customerName,
            gt.name            as give_Type,
            bc.name            as business_center,
            cat.name           as category,
            ac.name            as activity,*/
            cc.id,
            cc.cust_key
       from prx_customer cc
       /*left outer join prx_give_type gt on gt.id = cc.give_type_id
       left outer join prx_business_center bc on bc.id = cc.business_center_id
       left outer join prx_customer_category cat on cat.id = cc.category_id
       left outer join prx_activity ac on ac.id = cc.activity_id*/
       where cc.deleted_by is null /*and gt.deleted_by is null and bc.deleted_by is null and cat.deleted_by is null*/) c on t.customer_id = c.id
left outer join (select met.code,
                        tl.start_killowat,
                        tl.end_killowat,
                        met.voltage,
                        tl.step_number as Step,
                        met.telasi_acc_key
                 from prx_counter met
                 join prx_tariff tr on tr.id = met.tariff_id
                 join prx_tariff_line tl on tl.tariff_id = tr.id
                 where met.deleted_by is null and tr.deleted_by is null and tl.deleted_by is null
                 /*order by met.code, tl.start_killowat*/) as st on t.counter_number = st.code
                            and abs(case when coalesce(t.kilowatt_hour, 0) = 0 then 1
                                        else coalesce(t.kilowatt_hour, 0) end) > st.start_killowat
                             and abs(case when coalesce(t.kilowatt_hour, 0) = 0 then 1
                                         else coalesce(t.kilowatt_hour, 0) end) <= st.end_killowat
left outer join (select rc.combination_id,
                        rc.group_code as name,
                        v.subtypename,
                        v.operation_key
                 from PRX_REP_CON_TURN_OVER_BY_MONTH rc
                 join prx_transaction_type_combinati_vw v on v.id = rc.combination_id
                 where rc.use_main_report = true) as combi on t.trans_type_combination_id = combi.combination_id
where t.deleted_by is null
  and t.created_date::date between ${startDate} and ${endDate}
  and (((t.kilowatt_hour = 0 or t.kilowatt_hour is null) and (t.amount = 0 or t.amount is null) and
         t.cycle_type = 'CIRCULAR' and t.trans_type_combination_id != 'dac93a92-41eb-8905-7021-53f1f8d559b5'/*ჯამური დარიცხვა*/)
        or
        (t.kilowatt_hour != 0 and t.kilowatt_hour is not null and t.amount != 0 and t.amount is not null))
-- and c.customer_number in ('4309956', '3526697', '3427198')
--and st.voltage!='0' and st.voltage is not null
group by c.cust_key                                          ,
       st.telasi_acc_key,
       t.read_date ,
       combi.operation_key,
       c.customer_number

