CREATE OR REPLACE FUNCTION "LK".fn_charge_zero_same_report(p_period text, p_sDate6mos date, p_eDate6mos date,
                                                            p_sDate date, p_eDate date,
                                                            p_sDate1 date, p_eDate1 date,
                                                            p_sDate2 date, p_eDate2 date)
    RETURNS void /*TABLE
            (
                cust_num     varchar(10),
                cust_nam     text,
                cat          text,
                act          text,
                adr          text,
                bc           text,
                stat         text,
                met_qua      smallint,
                rsn          text,
                op_tls       text,
                cut_qua      smallint,
                con_qua      smallint,
                kwt          decimal(10, 2),
                dz           decimal(10, 2),
                op_tlmc      text,
                met_qua_same smallint,
                flg          boolean,
                met_num      text

            )*/
AS
$$
BEGIN
        call "LK".prc_charge_zero_report(p_sDate6mos, p_eDate6mos);
        raise notice 'Zero Charge Inserted';

        call "LK".prc_charge_same_report(p_sDate, p_eDate, p_sDate1, p_eDate1, p_sDate2, p_eDate2);
        raise notice 'Same Charge Inserted';

        call "LK".prc_cust_info_report(p_period);
        raise notice 'Cust Info Inserted';

    /*RETURN QUERY select rp.customer_number,
                        rp.customer_name,
                        rp.category,
                        rp.activity,
                        rp.address,
                        rp.business_center,
                        rp.status,
                        rp.metter_quantity,
                        rp.reason,
                        rp.operation_telasi,
                        rp.cut_quantity,
                        rp.connect_quantity,
                        rp.dz,
                        rp.kwt,
                        rp.operation_telmico,
                        rp.same_charge_metter_quantity,
                        rp.flag_zero_charge,
                        rp.metter_serial
                 from "LK".lk_charge_zero_same_report rp;*/

exception
    when others then
--         rollback;
        raise notice 'fn_charge_zero_same_report Exception %', SQLERRM;
END ;
$$
    LANGUAGE plpgsql;
alter function "LK".fn_charge_zero_same_report(text, date, date, date, date, date, date, date, date) owner to "Billing";






select * from "LK".fn_charge_zero_same_report('2024-03', '04-oct-2023',
                                              '03-apr-2024', '06-jan-2024',
                                              '03-feb-2024', '04-feb-2024',
                                              '03-mar-2024', '04-mar-2024', '03-apr-2024');
commit;
-- drop function "LK".fnc_charge_zero_same_report
-- drop procedure  "LK".prc_charge_zero_same_report
--  select * from "LK".lk_charge_zero_same_report
--select * from "LK".lk_charge_same_report
/*
select * from "LK".fnc_charge_zero_same_report(period, sDate6mos, eDate6mos,
                                                sDate, eDate, sDate1,
                                                sDate1, sDate2, sDate2);*/

select customer_number cust_num,
    customer_name cust_nam,
    category cat,
    activity act,
    address adr,
    status stat,
    metter_quantity met_qua,
    operation_telmico op_tlmc,
    operation_telasi op_tls,
    reason resn,
    cut_quantity cut_qua,
    connect_quantity con_qua,
    dz,
    same_charge_metter_quantity met_qua_same,
    kwt,
    business_center bc,
    metter_serial met_num
    from "LK".lk_charge_zero_same_report lkzs
where flag_zero_charge
