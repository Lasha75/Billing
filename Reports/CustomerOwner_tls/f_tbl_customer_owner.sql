CREATE FOREIGN TABLE "LK".lk_f_customer_owner (
        "CUSTCATKEY" numeric,
        "FIRST_NAME" varchar,
        "LAST_NAME" varchar,
        "COMMERCIAL_NAME" varchar,
        "PERSON_ID" varchar,
        "TAXID" varchar,
        "REGISTER_CODE" varchar,
        "START_DATE" date,
        "END_DATE" date,
        "STATUS" numeric)
    SERVER telasiint
    OPTIONS (schema_name 'public', table_name 'tlowners');

alter foreign table "LK".lk_f_customer_owner owner to "Billing";