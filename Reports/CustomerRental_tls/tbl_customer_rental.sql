create table if not exists "LK".lk_customer_rental
(
    id              integer generated always as identity,
    customer_number text,
    customer_id uuid,
        "CUSTKEY" numeric,
        "FIRST_NAME" varchar,
        "LAST_NAME" varchar,
        "COMMERCIAL_NAME" varchar,
        "PERSON_ID" varchar,
        "TAXID" varchar,
        "START_DATE" date,
        "END_DATE" date,
        "ENTER_DATE" date,
        "COMPANY_ID" numeric
);

alter table "LK".lk_customer_rental owner to "Billing";