--tlmc vs tls
        select count(*)
        from "VWTelasiRouteStore";--

        select count(*)
        from "VWTelasiCust";--

--customer
        select rt."CUSTKEY",
               cc.customer_number
        from "VWTelasiRouteStore" rt
        left join prx_customer cc on cc.cust_key = rt."CUSTKEY" and cc.deleted_by is null
        where cc.id is null
          and rt."NEW_READDATE" = current_date - interval '1 DAY';--'2025-03-29';

--meter
        select rt."ACCKEY",
               rt."CUSTKEY",
               cu.customer_number accnumb_no_metter,
               cu1.customer_number accnumb_telmico_telasi
        from "VWTelasiRouteStore" rt
        left join prx_counter met on met.telasi_acc_key = rt."ACCKEY" and met.deleted_by is null
        left join prx_customer cu on cu.cust_key = met.cust_key
        left join prx_customer cu1 on cu1.cust_key = rt."CUSTKEY"
        where met.id is null
          and rt."NEW_READDATE" = current_date - interval '1 DAY';--'2025-03-29';


--sub meter (უნდა ემთხვევოდეს ერთმანეთს)
        update prx_counter
        set parent_counter_id = NULL
        where deleted_by is null
          and parent_counter_id is not null;

        update prx_counter c
        set parent_counter_id = prMet.id
        from public."VWTelasiAccountRel" rel,
             prx_counter prMet
        where rel."ACCKEY" = c.telasi_acc_key
          and prMet.telasi_acc_key = rel."BASE_ACCKEY"
          and c.deleted_by is null;

        select count(*)
        from prx_counter
        where deleted_by is null
          and parent_counter_id is not null;

--parent meter not exists (38)
        select rel."BASE_ACCKEY"
        from "VWTelasiAccountRel" rel
        join prx_counter met on met.telasi_acc_key = rel."ACCKEY"
        left join prx_counter par on par.telasi_acc_key = rel."BASE_ACCKEY" and par.deleted_by is null
        where met.deleted_by is null
          and par.id is null
          and rel."BASE_ACCKEY" is not null
        group by rel."BASE_ACCKEY";

--block
        select met.telasi_acc_key,
               met.code,
               bl.block_index tlmc_block,
               bl.cycle_day tlmc_cyc_day,
               tel."CYCLEDAY" tls_cyc_day,
               tel."CUSTKEY",
               cu.customer_number
        from prx_counter met
        join prx_block bl on bl.id = met.block_id
        join "VWTelasiAccount" tel on tel."ACCKEY" = met.telasi_acc_key
        left join prx_customer cu on met.cust_key = cu.cust_key
        where bl.block_index != 5
          and met.deleted_by is null
          and bl.deleted_by is null
          and cu.deleted_by is null
          and bl.cycle_day <> tel."CYCLEDAY";

--dzabva
        select cu.customer_number,
                met.telasi_acc_key,
               met.code,
               tel."VOLTAGE",
               met.voltage
        from prx_counter met
        join "VWTelasiAccount" tel on tel."ACCKEY" = met.telasi_acc_key
        join prx_customer cu on cu.cust_key = met.cust_key
        where met.deleted_by is null
          and trim(met.voltage) <> trim(tel."VOLTAGE");

--activity
/*        select tel."ACCNUMB",
               tel."ACTIVITY",
               act.name,
               act.id,
               cc.activity_id,
               act1.name
        from "VWTelasiCust" tel
        join prx_activity act on trim(act.name) = trim(tel."ACTIVITY")
        join prx_customer cc on cc.customer_number = tel."ACCNUMB"
        left join prx_activity act1 on act1.id = cc.activity_id
        where cc.deleted_by is null
          and cc.activity_id <> act.id;*/

--category
select tel."ACCNUMB",
       tel."CUSTCATNAME",
       cat.id cat_id_tls,
       cat.name cat_tls,
       cc.category_id cat_id_tlmc,
       cat1.name cat_tlmc
from "VWTelasiCust" tel
join prx_customer_category cat on trim(cat.name) = trim(tel."CUSTCATNAME")
join prx_customer cc on cc.customer_number = tel."ACCNUMB"
join prx_customer_category cat1 on cc.category_id = cat1.id
where cat.deleted_by is null
  and cc.deleted_by is null
  and cc.category_id <> cat.id;

