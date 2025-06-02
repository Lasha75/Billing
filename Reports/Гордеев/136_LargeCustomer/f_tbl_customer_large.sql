CREATE FOREIGN TABLE "LK".lk_f_tbl_customer_large (
        "CUSTKEY" numeric)
    SERVER telasiint
    OPTIONS (schema_name 'public', table_name 'lk_tlcustomer_large');