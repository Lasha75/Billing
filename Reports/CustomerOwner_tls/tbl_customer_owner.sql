create table if not exists "LK".lk_customer_owner
(
    id                integer generated always as identity,
    customer_number   text,
    customer_id       uuid,
    "CUSTKEY"         numeric,
    "FIRST_NAME"      varchar,
    "LAST_NAME"       varchar,
    "COMMERCIAL_NAME" varchar,
    "PERSON_ID"       varchar,
    "TAXID"           varchar,
    "REGISTER_CODE"   varchar,
    "START_DATE"      date,
    "END_DATE"        date,
    "STATUS"          numeric
);

alter table "LK".lk_customer_owner
    owner to "Billing";