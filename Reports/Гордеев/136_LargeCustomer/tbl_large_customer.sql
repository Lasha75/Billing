create table if not exists "LK".lk_customer_large
(
    id              integer generated always as identity,
    custkey         integer not null,
    customer_number text,
    customer_id uuid
);

alter table "LK".lk_customer_large     owner to "Billing";

