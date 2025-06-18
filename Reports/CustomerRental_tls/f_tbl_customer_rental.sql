CREATE FOREIGN TABLE "LK".lk_f_customer_rental (
        "CUSTKEY" numeric,
        "FIRST_NAME" varchar,
        "LAST_NAME" varchar,
        "COMMERCIAL_NAME" varchar,
        "PERSON_ID" varchar,
        "TAXID" varchar,
        "START_DATE" date,
        "END_DATE" date,
        "ENTER_DATE" date,
        "COMPANY_ID" numeric)
    SERVER telasiint
    OPTIONS (schema_name 'public', table_name 'tlcustomerrental');

alter foreign table "LK".lk_f_customer_rental owner to "Billing";