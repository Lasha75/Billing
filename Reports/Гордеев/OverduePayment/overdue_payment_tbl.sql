create table if not exists "LK".lk_overdue_payment_report
(
--     id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id        uuid,
    customer_number varchar(10)/*,
    number          smallint,
    average         numeric,
    amount          numeric,
    due_date        date,
    created_date    timestamp*/
);

alter table "LK".lk_overdue_payment_report
    owner to "Billing";

/*create index if not exists idx_lk_overdue_payment_cust
    on "LK".lk_overdue_payment_report (customer_number);

create index if not exists idx_lk_overdue_payment_custNum_dueDate
    on "LK".lk_overdue_payment_report (customer, due_date);*/

