create foreign table "TelasiTest".public.lk_tlcustomer_large
    (
        "CUSTKEY" numeric
    )
    server oracle
    options (schema 'BS', table 'TL_CUSTOMER_LARGE_V');

alter foreign table "TelasiTest".public.lk_tlcustomer_large    owner to "Billing";

