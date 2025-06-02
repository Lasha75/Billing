create or replace procedure "LK".prc_charge_zero_report(in p_sDate date, in p_eDate date)
    language plpgsql
as
$$
begin
    truncate table "LK".lk_charge_zero_same_report restart identity;

--     create temporary table tmp on commit drop as
    with charge_met as (select cust_numb,
                               met_numb
                        from (select tr.customer_number        cust_numb,
                                     tr.counter_serial_number  met_numb,
                                     count(tr.customer_number) cnt
                              from prx_transaction tr
                              where tr.created_date::date between p_sDate and p_eDate
                                and tr.deleted_by is null
                                and tr.cycle_type = 'CIRCULAR'
                                and tr.trans_type_combination_id in
                                    ('de579ca8-118d-0f99-1012-c2e6b3a02307', '92064740-2471-1450-a569-ac4b7efe9a0c')
                                and (coalesce(tr.amount, 0) = 0 and coalesce(tr.kilowatt_hour, 0) = 0)
                              group by cust_numb,
                                       tr.counter_serial_number) zc
                        where zc.cnt = 6),
         cust_met as (select cu.customer_number,
                             met.serial_number,
                             count(cu.customer_number) over (partition by cu.customer_number ) cnt
                      from prx_counter met
                      inner join prx_customer cu on cu.cust_key = met.cust_key
                      where cu.create_date <= date_trunc('day', now()) - interval '6 months'
                      and cu.deleted_by is null)

    insert into "LK".lk_charge_zero_same_report(customer_number, flag_zero_charge)
    select distinct customer_number,
                    true
    from (select chm.met_numb,
                 chm.cust_numb,
                 cum.customer_number,
                 cum.serial_number,
                 cum.cnt,
                 count(cum.customer_number) over (partition by cum.customer_number ) rnc
          from charge_met chm
          right join cust_met cum on cum.customer_number = chm.cust_numb and cum.serial_number = chm.met_numb
          where chm.met_numb is not null) cumet
    where cumet.cnt = cumet.rnc;

   --commit;
    raise notice 'prc Zero Charge done';

    exception
        when no_data_found then
            rollback;
            raise notice 'Zero Charge Exception (No data found) %, %', SQLSTATE, SQLERRM;
        when others then
            rollback;
            raise notice 'Zero Charge (Others) %, %', SQLSTATE, SQLERRM;
end;
$$;

-- alter procedure "LK".prc_charge_zero_same_report(date, date) owner to "Billing";
