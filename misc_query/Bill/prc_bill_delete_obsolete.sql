create procedure prc_bill_delete(IN p_cust_num text, IN p_bill_date date)
    language plpgsql
as
$$
declare
    v_rec_bill record   = null;
    v_rec_tran record   = null;
    v_cnt      smallint = 1;
/*    v_upd_id     smallint = 0;
    v_upd_opn_id smallint = 0;*/
begin
    for v_rec_bill in select bl.id,
                             bl.customer_id,
                             bl.counter_id,
                             bl.generation_id,
                             bl.amount,
                             bl.counter_serial_number
                      from prx_bill bl
                      where customer_number = p_cust_num
                        and cast(bl.created_date as date) = p_bill_date
                        and deleted_by is null
        loop
            raise notice 'prx_bill. metter serial: %  amount: % bill id: % cust id: % generation id:%  metter id: % ', v_rec_bill.counter_serial_number, v_rec_bill.amount, v_rec_bill.id, v_rec_bill.customer_id, v_rec_bill.generation_id, v_rec_bill.counter_id;

            raise notice 'Start update bill % #%', v_rec_bill.id, v_cnt;

            update prx_bill
            set deleted_by   = 'lgaprindashvili',
                deleted_date = now()
            where id = v_rec_bill.id;

            raise notice 'End update bill % #%', v_rec_bill.id, v_cnt;

            v_cnt = v_cnt + 1;
            raise notice '---- next bill № % ----', v_cnt;

        end loop;


    for v_rec_tran in
        select *
        from prx_bill_used_transaction
        where customer_id = v_rec_bill.customer_id
          and generation_id = v_rec_bill.generation_id
          and cast(created_date as date) = p_bill_date
        loop
            raise notice 'prx_bill_used_transaction id: %  transaction id: %', v_rec_tran.id, v_rec_tran.transaction_id;

            raise notice 'Start update trans %' , v_rec_tran.transaction_id;

            update public.prx_transaction
            set used_in_bill       = null,
                last_modified_by   = 'lgaprindashvili',
                last_modified_date = now()
            where id = v_rec_tran.transaction_id;

            update public.prx_open_transaction
            set used_in_bill       = null,
                last_modified_by   = 'lgaprindashvili',
                last_modified_date = now()
            where transaction_id = v_rec_tran.transaction_id;

            raise notice 'End update trans %' , v_rec_tran.transaction_id;
        end loop;

exception
    when others then
--             rollback;
        raise exception 'Outer Exception % %', SQLSTATE, SQLERRM;
end;
$$;

alter procedure prc_bill_delete(text, date) owner to "Billing";

