create or replace procedure "LK".prc_customer_rental_obtain()
    language plpgsql
as
$$
begin
    truncate table "LK".lk_customer_rental restart identity;

    insert into "LK".lk_customer_rental (customer_number,
                                         customer_id,
                                         "CUSTKEY",
                                         "FIRST_NAME",
                                         "LAST_NAME",
                                         "COMMERCIAL_NAME",
                                         "PERSON_ID",
                                         "TAXID",
                                         "START_DATE",
                                         "END_DATE",
                                         "ENTER_DATE",
                                         "COMPANY_ID")
    select cu.customer_number,
           cu.id,
           cur."CUSTKEY",
           cur."FIRST_NAME",
           cur."LAST_NAME",
           cur."COMMERCIAL_NAME",
           cur."PERSON_ID",
           cur."TAXID",
           cur."START_DATE",
           cur."END_DATE",
           cur."ENTER_DATE",
           cur."COMPANY_ID"
    from public.prx_customer cu
    right join "LK".lk_f_customer_rental cur on cur."CUSTKEY" = cu.cust_key
    where cu.deleted_by is null;

exception
    when no_data_found then
        raise notice 'Outer Exception. No Data Found % %', SQLSTATE, SQLERRM;
        rollback;
    when others then
        raise notice 'Outer Exception. Others % %', SQLSTATE, SQLERRM;
        rollback;
end ;
$$;

alter procedure "LK".prc_customer_rental_obtain() owner to "Billing";