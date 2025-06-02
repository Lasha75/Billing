create or replace procedure "LK".prc_customer_large_obtain()
    language plpgsql
as
$$
begin
    truncate table "LK".lk_customer_large restart identity;

    insert into "LK".lk_customer_large (custkey, customer_number)
    select cul."CUSTKEY",
           cu.customer_number
    from prx_customer cu
    join "LK".lk_f_tbl_customer_large cul on cul."CUSTKEY" = cu.cust_key
    where cu.deleted_by is null;

exception
    when no_data_found then
        raise notice 'Outer Exception. No Data Found % %', SQLSTATE, SQLERRM;
        rollback;
    when others then
        raise notice 'Outer Exception. Others % %', SQLSTATE, SQLERRM;
        rollback;
end;
$$;

alter procedure "LK".prc_customer_large_obtain() owner to "Billing";