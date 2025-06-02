create or replace function "LK".fn_overdue_payment()
    returns TABLE
            (
                cust_id uuid,
                cust_num varchar(10)
            )
    language plpgsql
as
$$
BEGIN
    raise notice 'LK.prc_overdue_payment() run';
/*    begin*/
        call "LK".prc_overdue_payment();
        raise notice 'LK.prc_overdue_payment() finish';

/*        exception
            when others then
--         rollback;
            raise notice 'Exception raised by prc_overdue_payment %', SQLERRM;
    end;*/

    RETURN QUERY
        select customer_id cust_id,
               customer_number cust_num
        from "LK".lk_overdue_payment_report;

exception
    when others then
--         rollback;
--         raise notice 'fn_overdue_payment Exception %', SQLERRM;
        raise exception 'fn_overdue_payment Exception %', SQLERRM;
END ;
$$;

alter function "LK".fn_overdue_payment() owner to "Billing";

