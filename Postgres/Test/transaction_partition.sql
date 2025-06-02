create table prx_transaction_part
(
    id                          uuid    not null,
    category_id                 uuid,
    customer_id                 uuid    not null,
    customer_number             varchar(100),
    account_number              varchar(100),
    account_type_id             uuid,
    amount                      numeric(19, 2),
    consumption                 double precision,
    bank_code                   varchar(200),
    bank_trans_code             varchar(300),
    block_id                    uuid,
    block_name                  varchar(100),
    category_name               varchar(100),
    chatge_type                 varchar(255),
    trans_date                  date    not null,
    due_date                    date,
    counter_number              varchar(90),
    counter_reading_value       numeric,
    counter_prev_reading_value  numeric,
    counter_serial_number       varchar(200),
    parent_customer_number      varchar(100),
    payment_doc_number          varchar(250),
    route_id                    uuid,
    route_name                  varchar(300),
    tariff_number               varchar(100),
    trans_type_combination_id   uuid    not null,
    comment_                    varchar(800),
    deposit_type                varchar(255),
    version                     integer not null,
    created_by                  varchar(255),
    created_date                timestamp,
    last_modified_by            varchar(255),
    last_modified_date          timestamp,
    deleted_by                  varchar(255),
    deleted_date                timestamp,
    bank_guarantee_end_date     date,
    bank_guarantee_number       varchar(255),
    bank_guarantee_start_date   date,
    tariff_id                   uuid,
    value_                      numeric(19, 2),
    invoice_date                date,
    invoice_is_written          boolean,
    kilowatt_hour               numeric(19, 2),
    used_in_bill                boolean,
    used_in_check               boolean,
    cycle_type                  varchar(255),
    read_date                   date,
    prev_read_date              date,
    prev_real_date              date,
    invoice_id                  uuid,
    parent_id                   uuid,
    tl_acc_key                  numeric(8),
    tl_acc_tar_key              numeric(8),
    tl_amount                   numeric(10, 2),
    tl_balance                  numeric(10, 2),
    tl_bill_oper_key            numeric(8),
    tl_cust_key                 numeric(8),
    tl_enter_date               date,
    tl_item_cat_key             numeric(1),
    tl_item_date                date,
    tl_item_key                 numeric(12),
    tl_item_number              varchar(60),
    tl_kwt                      numeric(13, 3),
    tl_note_key                 numeric(8),
    tl_pers_key                 numeric(8),
    tl_reading                  numeric(14, 6),
    tl_sched_key                numeric(8),
    tl_sign_key                 numeric(8),
    payment_purpose             varchar(255),
    create_time_stamp           varchar(100),
    chiled_counter_id           uuid,
    voucher                     varchar(50),
    is_corrected                boolean,
    enter_date_time             timestamp,
    cycle_day_difference        numeric(19),
    telasi_acccount_id          varchar(40),
    telasi_chiled_account_id    varchar(40),
    chiled_customer_id          uuid,
    with_gel                    boolean,
    is_mp_charge                boolean,
    step                        integer,
    view_detail_connection_id   uuid,
    aviso_date                  date,
    bank_account                varchar(100),
    bank_operation_type         varchar(100),
    reporting_date              date,
    restructurization_header_id uuid
) PARTITION BY RANGE (created_date);

alter table public.prx_transaction_part
    owner to "Billing";

CREATE TABLE public."prx_tran_2021_2022" PARTITION OF public.prx_transaction_part
FOR VALUES from (timestamp '01-jun-2021 00:00:00') to (timestamp'31-dec-2022 00:00:00');

CREATE TABLE public."prx_tran_2023" PARTITION OF public.prx_transaction_part
FOR VALUES from (timestamp'01-jan-2023 00:00:00') to (timestamp'31-dec-2023 00:00:00');

CREATE TABLE public."prx_tran_null" PARTITION OF public.prx_transaction_part  default;

INSERT INTO prx_transaction_part
SELECT * FROM public.prx_transaction;


/*constraint*/
alter table prx_transaction_part
    add constraint pk_prx_transaction
        primary key (id, created_date);

alter table prx_transaction_part
    add constraint fk_prx_transaction_on_account_type
        foreign key (account_type_id) references prx_customer_contract_type;

alter table prx_transaction_part
    add constraint fk_prx_transaction_on_block
        foreign key (block_id) references prx_block;

alter table prx_transaction_part
    add constraint fk_prx_transaction_on_category
        foreign key (category_id) references prx_customer_category;

alter table prx_transaction_part
    add constraint fk_prx_transaction_on_chiled_counter
        foreign key (chiled_counter_id) references prx_counter;

alter table prx_transaction_part
    add constraint fk_prx_transaction_on_customer
        foreign key (customer_id) references prx_customer;

alter table prx_transaction_part
    add constraint fk_prx_transaction_on_route
        foreign key (route_id) references prx_route;

alter table prx_transaction_part
    add constraint fk_prx_transaction_on_tariff
        foreign key (tariff_id) references prx_tariff;

alter table prx_transaction_part
    add constraint fk_prx_transaction_on_trans_type_combination
        foreign key (trans_type_combination_id) references prx_transaction_type_combinati;

alter table prx_transaction_part
    add constraint fk_prxtransact_on_chiledcusto
        foreign key (chiled_customer_id) references prx_customer;
  /**/


/*indexing*/
create index if not exists idx_prx_transaction_part
    on prx_transaction_part (customer_id, deleted_by, counter_number, read_date, trans_type_combination_id);

create index idx_prx_transaction_1_part
    on prx_transaction_part (telasi_acccount_id, customer_id, account_type_id);

create index idx_prx_transaction_2_part
    on prx_transaction_part (account_type_id, customer_id);

create index idx_prx_transaction_3_part
    on prx_transaction_part (customer_id, counter_number);

create index idx_prx_transaction_4_part
    on prx_transaction_part (view_detail_connection_id);

create index idx_prx_transaction_5_part
    on prx_transaction_part (create_time_stamp);

create index idx_prx_transaction_bank_part
    on prx_transaction_part (bank_code, payment_doc_number);

create index idx_prx_transaction_chiled_counter_part
    on prx_transaction_part (chiled_counter_id);

create index idx_prx_transaction_counter_part
    on prx_transaction_part (counter_number);

create index idx_prx_transaction_cust_createdate_delete_part
    on prx_transaction_part (customer_id, created_date, deleted_date, tl_item_key);

create index idx_prx_transaction_customer_part
    on prx_transaction_part (customer_number);

create index idx_prx_transaction_overdue_part
    on prx_transaction_part (customer_id, invoice_date, used_in_bill, trans_type_combination_id);

create index idx_prx_transaction_reportingdate_part
    on prx_transaction_part (reporting_date, deleted_by);

create index idx_prx_transaction_tlitemkey_part
    on prx_transaction_part (tl_item_key);

create index idx_prx_transaction_trans_cust_part
    on prx_transaction_part (customer_id, trans_type_combination_id, created_date, deleted_date);

create index idx_prxtransacti_chiledcustom_part
    on prx_transaction_part (chiled_customer_id);

create index idx_transaction_part
    on prx_transaction_part (account_type_id);

create index idx_transaction_block_id_part
    on prx_transaction_part (block_id);

create index idx_transaction_category_id_part
    on prx_transaction_part (category_id);

create index idx_transaction_customer_id_part
    on prx_transaction_part (customer_id);

create index idx_transaction_invoice_id_id_part
    on prx_transaction_part (invoice_id);

create index idx_transaction_tariff_id_part
    on prx_transaction_part (tariff_id);
/**/

grant select on prx_transaction_part to teldoc;


