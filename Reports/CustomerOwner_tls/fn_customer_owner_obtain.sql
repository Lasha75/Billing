create or replace function "LK".fn_customer_owner_obtain() returns void
    language plpgsql
as
$$
BEGIN
        call "LK".prc_customer_owner_obtain();
        raise notice 'Owner Customer Inserted';

exception
    when others then
        raise exception 'Outer. fn_customer_owner_obtain Exception %', SQLERRM;
--         rollback;
END ;
$$;

alter function "LK".fn_customer_owner_obtain() owner to "Billing";

