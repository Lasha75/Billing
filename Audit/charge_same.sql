do
$$
    declare--report app -> application -> debtors report
        sDate  date := '04-feb-2024';
        eDate  date := '03-mar-2024';
        sDate1 date := '04-mar-2024';
        eDate1 date := '03-apr-2024';
        sDate2 date := '04-apr-2024';
        eDate2 date := '08-may-2024';
    begin
        create temporary table tmp on commit drop as
        with I_mon as (select tr.customer_number,
                            tr.counter_serial_number,
                            sum(tr.amount)        as                                                     amount,
                            sum(tr.kilowatt_hour) as                                                     kwt,
                            case tr.trans_type_combination_id
                                when 'de579ca8-118d-0f99-1012-c2e6b3a02307' then 'დარიცხვა ჩვენება'
                                when '92064740-2471-1450-a569-ac4b7efe9a0c' then 'დარიცხვა პირობითი' end oper
--                               row_number() over (partition by tr.customer_number order by tr.created_date) rn
                     from prx_transaction tr
                     where tr.deleted_by is null
-- and tr.customer_number='2069479'
                       and tr.cycle_type = 'CIRCULAR'
                       and tr.trans_type_combination_id in
                           ('de579ca8-118d-0f99-1012-c2e6b3a02307', '92064740-2471-1450-a569-ac4b7efe9a0c')/*დარიცხვა ჩვენება,  დარიცხვა პირობითი*/
                       and tr.created_date::date between sDate and eDate
                     group by tr.counter_serial_number,
                              tr.customer_number,
                              tr.trans_type_combination_id),
             II_mon as (select tr.customer_number,
                            tr.counter_serial_number,
                            sum(tr.amount)        as                                                     amount,
                            sum(tr.kilowatt_hour) as                                                     kwt,
                            case tr.trans_type_combination_id
                                when 'de579ca8-118d-0f99-1012-c2e6b3a02307' then 'დარიცხვა ჩვენება'
                                when '92064740-2471-1450-a569-ac4b7efe9a0c' then 'დარიცხვა პირობითი' end oper
--                               row_number() over (partition by tr.customer_number order by tr.created_date) rn
                     from prx_transaction tr
                     where tr.deleted_by is null
-- and tr.customer_number='2069479'
                       and tr.cycle_type = 'CIRCULAR'
                       and tr.trans_type_combination_id in
                           ('de579ca8-118d-0f99-1012-c2e6b3a02307', '92064740-2471-1450-a569-ac4b7efe9a0c')/*დარიცხვა ჩვენება,  დარიცხვა პირობითი*/
                       and tr.created_date::date between sDate1 and eDate1
                     group by tr.counter_serial_number,
                              tr.customer_number,
                              tr.trans_type_combination_id),
             III_mon as (select tr.customer_number,
                            tr.counter_serial_number,
                            sum(tr.amount)        as                                                     amount,
                            sum(tr.kilowatt_hour) as                                                     kwt,
                            case tr.trans_type_combination_id
                                when 'de579ca8-118d-0f99-1012-c2e6b3a02307' then 'დარიცხვა ჩვენება'
                                when '92064740-2471-1450-a569-ac4b7efe9a0c' then 'დარიცხვა პირობითი' end oper
--                               row_number() over (partition by tr.customer_number order by tr.created_date) rn
                     from prx_transaction tr
                     where tr.deleted_by is null
-- and tr.customer_number='2069479'
                       and tr.cycle_type = 'CIRCULAR'
                       and tr.trans_type_combination_id in
                           ('de579ca8-118d-0f99-1012-c2e6b3a02307', '92064740-2471-1450-a569-ac4b7efe9a0c')/*დარიცხვა ჩვენება,  დარიცხვა პირობითი*/
                       and tr.created_date::date between sDate2 and eDate2
                     group by tr.counter_serial_number,
                              tr.customer_number,
                              tr.trans_type_combination_id),
            met_qua as (select cu.customer_number,
                        count(met.id) met_qua
                 from prx_counter met
                 inner join prx_customer cu on cu.cust_key = met.cust_key
                 where met.deleted_by is null
                 group by cu.customer_number)


        select I.counter_serial_number,
               I.customer_number,
               mq.met_qua,
               I.amount,
               I.kwt,
               I.oper
        from I_mon I
        join II_mon II on II.customer_number = I.customer_number and II.counter_serial_number = I.counter_serial_number
        join III_mon III on III.customer_number = I.customer_number and III.counter_serial_number = I.counter_serial_number
        left join met_qua mq on mq.customer_number = I.customer_number
        where I.amount = II.amount
          and I.amount = III.amount
          and I.kwt = II.kwt
          and I.kwt = III.kwt
          and I.amount >0;


    raise notice 'Same Charge Inserted';
    end;
$$;
select *
from tmp
order by customer_number;




/*


WITH transaction_summary AS (
    SELECT
        tr.customer_number,
        tr.counter_serial_number,
        case tr.trans_type_combination_id
                                when 'de579ca8-118d-0f99-1012-c2e6b3a02307' then 'დარიცხვა ჩვენება'
                                when '92064740-2471-1450-a569-ac4b7efe9a0c' then 'დარიცხვა პირობითი' end oper,
        SUM(CASE WHEN tr.created_date::date BETWEEN '06-jan-2024' AND '03-feb-2024' THEN tr.amount ELSE 0 END) AS amount1,
        SUM(CASE WHEN tr.created_date::date BETWEEN '06-jan-2024' AND '03-feb-2024' THEN tr.kilowatt_hour ELSE 0 END) AS kwt1,
        SUM(CASE WHEN tr.created_date::date BETWEEN '04-feb-2024' AND '03-mar-2024' THEN tr.amount ELSE 0 END) AS amount2,
        SUM(CASE WHEN tr.created_date::date BETWEEN '04-feb-2024' AND '03-mar-2024' THEN tr.kilowatt_hour ELSE 0 END) AS kwt2,
        SUM(CASE WHEN tr.created_date::date BETWEEN '04-mar-2024' AND '03-apr-2024' THEN tr.amount ELSE 0 END) AS amount3,
        SUM(CASE WHEN tr.created_date::date BETWEEN '04-mar-2024' AND '03-apr-2024' THEN tr.kilowatt_hour ELSE 0 END) AS kwt3
    FROM prx_transaction tr
    WHERE tr.deleted_by IS NULL
        AND tr.cycle_type = 'CIRCULAR'
        AND tr.trans_type_combination_id IN ('de579ca8-118d-0f99-1012-c2e6b3a02307', '92064740-2471-1450-a569-ac4b7efe9a0c')
and tr.created_date between now()::date and select DATE_TRUNC('MONTH', now() - INTERVAL '3 MONTH')::date
    GROUP BY tr.customer_number,
        tr.counter_serial_number,
        tr.trans_type_combination_id),
    met_qua as (select cu.customer_number,
                        count(met.id) met_qua
                 from prx_counter met
                 inner join prx_customer cu on cu.cust_key = met.cust_key
                 group by cu.customer_number)
SELECT    ts.counter_serial_number,
    ts.customer_number,
    mq.met_qua,
    ts.kwt1,
    ts.oper
FROM  transaction_summary ts
JOIN met_qua mq ON mq.customer_number = ts.customer_number
WHERE
    ts.amount1 > 0
    AND ts.kwt1 = ts.kwt2
    AND ts.kwt1 = ts.kwt3
    and ts.amount1 = ts.amount2
    and ts.amount1 = ts.amount3;

*/