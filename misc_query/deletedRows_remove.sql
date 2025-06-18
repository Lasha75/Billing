do
$$
    declare
        v_cnt bigint := 0;
        v_rec prx_transaction%rowtype;
    begin
        create table "LK".lk_trans_deleted as
        select *
        from prx_transaction
        where deleted_by is not null
        and created_date between current_date - interval '3 YEARS' and current_date ;

        create table "LK".lk_open_trans_deleted as
        select *
        from "Billing_TestDB".public.prx_open_transaction
        where deleted_by is not null
        and created_date between current_date - interval '3 YEARS' and current_date;

        create table "LK".lk_settle_trans_deleted as
        select *
        from "Billing_TestDB".public.prx_settle_transaction
        where deleted_by is not null
        and created_date between current_date - interval '3 YEARS' and current_date;
------------------------------------------------------


        SELECT string_agg('tr.' || quote_ident(column_name), ', ')
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'prx_transaction'
          AND column_name <> 'id';

        SELECT string_agg('otr.' || quote_ident(column_name), ', ')
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'prx_open_transaction'
          AND column_name <> 'id';

        SELECT string_agg('str.' || quote_ident(column_name), ', ')
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'prx_settle_transaction'
          AND column_name <> 'id';


        with tr as (select tr.category_id, tr.customer_id, tr.customer_number, tr.account_number, tr.account_type_id, tr.amount, tr.consumption, tr.bank_code, tr.bank_trans_code, tr.block_id, tr.block_name, tr.category_name, tr.chatge_type, tr.trans_date, tr.due_date, tr.counter_number, tr.counter_reading_value, tr.counter_prev_reading_value, tr.counter_serial_number, tr.parent_customer_number, tr.payment_doc_number, tr.route_id, tr.route_name, tr.tariff_number,
               tr.trans_type_combination_id, tr.comment_, tr.deposit_type, tr.version, tr.created_by, tr.created_date, tr.last_modified_by, tr.last_modified_date, tr.deleted_by, tr.deleted_date, tr.bank_guarantee_end_date, tr.bank_guarantee_number, tr.bank_guarantee_start_date,
               tr.tariff_id, tr.value_, tr.invoice_date, tr.invoice_is_written, tr.kilowatt_hour, tr.used_in_bill, tr.used_in_check, tr.cycle_type, tr.read_date, tr.prev_read_date, tr.prev_real_date, tr.invoice_id, tr.parent_id, tr.tl_acc_key, tr.tl_acc_tar_key,
               tr.tl_amount, tr.tl_balance, tr.tl_bill_oper_key, tr.tl_cust_key, tr.tl_enter_date, tr.tl_item_cat_key, tr.tl_item_date, tr.tl_item_key, tr.tl_item_number, tr.tl_kwt, tr.tl_note_key, tr.tl_pers_key, tr.tl_reading, tr.tl_sched_key, tr.tl_sign_key,
               tr.payment_purpose, tr.create_time_stamp, tr.chiled_counter_id, tr.voucher, tr.is_corrected, tr.enter_date_time, tr.cycle_day_difference, tr.telasi_acccount_id, tr.telasi_chiled_account_id, tr.chiled_customer_id, tr.with_gel,
               tr.is_mp_charge, tr.step, tr.view_detail_connection_id, tr.aviso_date, tr.bank_account, tr.bank_operation_type, tr.reporting_date, tr.restructurization_header_id, tr.activity_id, tr.give_type_id, tr.vat_type, tr.voltage
        from prx_transaction tr
        left join "LK".lk_trans_deleted dl on dl.id = tr.id
        where tr.deleted_by is not null  and dl.id is null
        and tr.created_date between current_date - interval '3 YEARS' and current_date)

        insert
        into "LK".lk_trans_deleted (category_id, customer_id, customer_number, account_number, account_type_id, amount,
                                    consumption, bank_code, bank_trans_code, block_id, block_name, category_name,
                                    chatge_type, trans_date, due_date, counter_number, counter_reading_value,
                                    counter_prev_reading_value, counter_serial_number, parent_customer_number,
                                    payment_doc_number, route_id, route_name, tariff_number, trans_type_combination_id,
                                    comment_, deposit_type, version, created_by, created_date, last_modified_by,
                                    last_modified_date, deleted_by, deleted_date, bank_guarantee_end_date,
                                    bank_guarantee_number, bank_guarantee_start_date, tariff_id, value_, invoice_date,
                                    invoice_is_written, kilowatt_hour, used_in_bill, used_in_check, cycle_type,
                                    read_date, prev_read_date, prev_real_date, invoice_id, parent_id, tl_acc_key,
                                    tl_acc_tar_key, tl_amount, tl_balance, tl_bill_oper_key, tl_cust_key, tl_enter_date,
                                    tl_item_cat_key, tl_item_date, tl_item_key, tl_item_number, tl_kwt, tl_note_key,
                                    tl_pers_key, tl_reading, tl_sched_key, tl_sign_key, payment_purpose,
                                    create_time_stamp, chiled_counter_id, voucher, is_corrected, enter_date_time,
                                    cycle_day_difference, telasi_acccount_id, telasi_chiled_account_id,
                                    chiled_customer_id, with_gel, is_mp_charge, step, view_detail_connection_id,
                                    aviso_date, bank_account, bank_operation_type, reporting_date,
                                    restructurization_header_id, activity_id, give_type_id, vat_type, voltage)
         select *
        from tr;

        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        raise notice 'Inserted rows lk_trans_deleted: %', v_cnt::text;



        with otr as (select *
                     from public.prx_open_transaction otr
                     left join "LK".lk_open_trans_deleted dl on dl.id = otr.id
                     where otr.deleted_by is not null
                       and dl.id is null
                     and otr.created_date between current_date - interval '3 YEARS' and current_date)
        insert
        into "LK".lk_open_trans_deleted
        select *
        from otr;


        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        raise notice 'Inserted rows lk_open_trans_deleted: %', v_cnt::text;



        with str as (select *
                     from public.prx_settle_transaction str
                     left join "LK".lk_settle_trans_deleted dl on dl.id = str.id
                     where str.deleted_by is not null
                       and dl.id is null
                     and str.created_date between current_date - interval '3 YEARS' and current_date)
        insert
        into "LK".lk_settle_trans_deleted
        select *
        from str;

        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        raise notice 'Inserted rows lk_settle_trans_deleted: %', v_cnt::text;

----------------------------------------------------------
        v_cnt = 0;

        delete
        from public.prx_open_transaction
        where deleted_date is not null;

        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        raise notice 'Deleted rows prx_open_transaction: %', v_cnt::text;
---------------------
        alter
            table
            prx_settle_transaction
            disable trigger
                all;
        delete
--         select count(*)
        from prx_settle_transaction
        where deleted_date is not null
        /*and deleted_date::date <'2024-01-01'*/;

/*        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        raise notice 'Deleted rows prx_settle_transaction: %', v_cnt::text;*/

        alter
            table
            prx_settle_transaction
            enable trigger
                all;



--------------------------

         alter
            table
            prx_transaction
            disable trigger
                all;
        delete
        --select count(*)
        from prx_transaction
        where deleted_date is not null
        /*and deleted_date::date <='2024-01-01'*/;
/*
        GET DIAGNOSTICS v_cnt = ROW_COUNT;
        raise notice 'Deleted rows: %', v_cnt::text;*/

        alter
            table
            prx_transaction
            enable trigger
                all;

    exception
        when others then
            raise exception 'Exception prx_transaction: %', SQLERRM;
    end;
$$ LANGUAGE plpgsql;

commit;
/*

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'lk_trans_deleted';

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'prx_transaction';
select *
from
dba_locks;
*/


