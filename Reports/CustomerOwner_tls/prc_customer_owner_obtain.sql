create or replace procedure "LK".prc_customer_owner_obtain()
    language plpgsql
as
$$
begin
    truncate table "LK".lk_customer_owner restart identity;

    insert into "LK".lk_customer_owner (customer_number,
                                        customer_id,
                                        "CUSTKEY",
                                        "FIRST_NAME",
                                        "LAST_NAME",
                                        "COMMERCIAL_NAME",
                                        "PERSON_ID",
                                        "TAXID",
                                        "REGISTER_CODE",
                                        "START_DATE",
                                        "END_DATE",
                                        "STATUS")
    select cu.customer_number,
           cu.id,
           cuo."CUSTCATKEY",
           cuo."FIRST_NAME",
           cuo."LAST_NAME",
           cuo."COMMERCIAL_NAME",
           cuo."PERSON_ID",
           cuo."TAXID",
           cuo."REGISTER_CODE",
           cuo."START_DATE",
           cuo."END_DATE",
           cuo."STATUS"
    from public.prx_customer cu
    right join "LK".lk_f_customer_owner cuo on cuo."CUSTCATKEY" = cu.cust_key
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

alter procedure "LK".prc_customer_owner_obtain() owner to "Billing";