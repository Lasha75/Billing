create or replace function "LK".fn_customer_rental_obtain() returns void
    language plpgsql
as
$$
BEGIN
        call "LK".prc_customer_rental_obtain();
        raise notice 'Rental Customer Inserted';

exception
    when others then
        raise exception 'Outer. fn_customer_rental_obtain Exception %', SQLERRM;
--         rollback;
END ;
$$;

alter function "LK".fn_customer_rental_obtain() owner to "Billing";

