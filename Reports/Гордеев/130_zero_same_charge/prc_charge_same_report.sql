create or replace procedure "LK".prc_charge_same_report(in p_sDate date, in p_eDate date,
                                                        in p_sDate1 date, in p_eDate1 date,
                                                        in p_sDate2 date, in p_eDate2 date)
    language plpgsql
as
$$
begin
        raise notice 'prc Same Charge begin';

        WITH transaction_summary AS (SELECT tr.customer_number,
                                        tr.counter_serial_number,
                                        case tr.trans_type_combination_id
                                            when 'de579ca8-118d-0f99-1012-c2e6b3a02307' then 'დარიცხვა ჩვენება'
                                            when '92064740-2471-1450-a569-ac4b7efe9a0c' then 'დარიცხვა პირობითი' end oper,
                                        SUM(CASE WHEN tr.created_date::date BETWEEN p_sDate AND p_eDate
                                                    THEN tr.amount
                                                ELSE 0 END) AS               amount,
                                        SUM(CASE WHEN tr.created_date::date BETWEEN p_sDate AND p_eDate
                                                    THEN tr.kilowatt_hour
                                                ELSE 0 END) AS               kwt,
                                        SUM(CASE WHEN tr.created_date::date BETWEEN p_sDate1 AND p_eDate1
                                                    THEN tr.amount
                                                ELSE 0 END) AS               amount1,
                                        SUM(CASE WHEN tr.created_date::date BETWEEN p_sDate1 AND p_eDate1
                                                    THEN tr.kilowatt_hour
                                                ELSE 0 END) AS               kwt1,
                                        SUM(CASE WHEN tr.created_date::date BETWEEN p_sDate2 AND p_eDate2
                                                    THEN tr.amount
                                                ELSE 0 END) AS               amount2,
                                        SUM(CASE WHEN tr.created_date::date BETWEEN p_sDate2 AND p_eDate2
                                                    THEN tr.kilowatt_hour
                                                ELSE 0 END) AS               kwt2
                                 FROM prx_transaction tr
                                 WHERE tr.deleted_by IS NULL
                                   AND tr.cycle_type = 'CIRCULAR'
                                   AND tr.trans_type_combination_id IN
                                       ('de579ca8-118d-0f99-1012-c2e6b3a02307', '92064740-2471-1450-a569-ac4b7efe9a0c')
--                                  and tr.created_date between now()::date and DATE_TRUNC('MONTH', now() - INTERVAL '3 MONTH')::date
                                 GROUP BY tr.customer_number,
                                          tr.counter_serial_number,
                                          tr.trans_type_combination_id),
         met_qua as (select cu.customer_number,
                            count(met.id) met_qua
                     from prx_counter met
                     join prx_customer cu on cu.cust_key = met.cust_key
                     where met.deleted_by is null
                     and cu.create_date <= date_trunc('day', now()) - interval '6 months'
                     and cu.deleted_by is null
                     group by cu.customer_number)

    insert into "LK".lk_charge_zero_same_report(customer_number, metter_serial, same_charge_metter_quantity, kwt, operation_telmico, flag_zero_charge )
    SELECT ts.customer_number,
           ts.counter_serial_number,
           mq.met_qua,
           ts.kwt,
           ts.oper,
           false
    FROM transaction_summary ts
    JOIN met_qua mq ON mq.customer_number = ts.customer_number
    WHERE ts.amount > 0
      AND ts.kwt = ts.kwt1
      AND ts.kwt = ts.kwt2
      and ts.amount = ts.amount1
      and ts.amount = ts.amount2;

    raise notice 'prc Same Charge end';

exception
    when no_data_found then
        rollback;
        raise notice 'Same Charge Exception (No data found) %, %', SQLSTATE, SQLERRM;
    when others then
        rollback;
        raise notice 'Same Charge Exception (Others) %, %', SQLSTATE, SQLERRM;
end;
$$;