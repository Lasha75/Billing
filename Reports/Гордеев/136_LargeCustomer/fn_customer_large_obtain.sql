create or replace function "LK".fn_customer_large_obtain() returns void
    language plpgsql
as
$$
BEGIN
        call "LK".prc_customer_large_obtain();
        raise notice 'Large Customer Inserted';

exception
    when others then
        raise exception 'Outer. fn_customer_large_obtain Exception %', SQLERRM;
--         rollback;
END ;
$$;

alter function "LK".fn_customer_large_obtain() owner to "Billing";

select "LK".fn_customer_large_obtain()