create table if not exists public.prx_open_transaction_part
(
    id                      uuid    not null ,
    account_type_id         uuid,
    category_id             uuid,
    customer_id             uuid not null,
    account_number          varchar(100),
    amount                  numeric(19, 2),
    category_name           varchar(200),
    block_id                uuid,
    block_name              varchar(200),
    route_id                uuid,
    route_name              varchar(350),
    trans_date              date    not null,
    due_date                  date,
    trans_type_combination_id uuid    not null,
    charge_type               varchar(255),
    transaction_id             uuid    not null,
    customer_number           varchar(100),
    deposit_type              varchar(255),
    version                   integer not null,
    created_by                varchar(255),
    created_date              timestamp,
    last_modified_by          varchar(255),
    last_modified_date        timestamp,
    deleted_by                varchar(255),
    deleted_date              timestamp,
    bank_guarantee_end_date   date,
    bank_guarantee_number     varchar(255),
    bank_guarantee_start_date date,
    tariff_id                   uuid,
    value_                    numeric(19, 2),
    invoice_date              date,
    kilowatt_hour             numeric(19, 2),
    used_in_bill              boolean,
    used_in_check             boolean,
    blocked                   boolean,
    create_time_stamp         varchar(100)
)PARTITION BY RANGE(created_date);

alter table public.prx_open_transaction_part
    owner to "Billing";

CREATE TABLE public."prx_open_tran_2021_2022" PARTITION OF public.prx_open_transaction_part
FOR VALUES from (timestamp '01-jun-2021 00:00:00') to (timestamp'31-dec-2022 00:00:00');

CREATE TABLE public."prx_open_tran_2023" PARTITION OF public.prx_open_transaction_part
FOR VALUES from (timestamp'01-jan-2023 00:00:00') to (timestamp'31-dec-2023 00:00:00');

CREATE TABLE public."prx_open_tran_null" PARTITION OF public.prx_open_transaction_part  default;

insert into prx_open_transaction_part
select * from prx_open_transaction ;

/*update prx_open_transaction_part
    set created_date = '01-jan-1900'
where created_date is null;*/

/*constraint*/
alter table prx_open_transaction_part
    add constraint pk_prx_open_transaction_part
        primary key (id, created_date);

alter table prx_open_transaction_part
    add constraint fk_prx_open_transaction_on_account_type
        foreign key (account_type_id) references prx_customer_contract_type;

alter table prx_open_transaction_part
    add constraint fk_prx_open_transaction_on_block
        foreign key (block_id) references prx_block;

alter table prx_open_transaction_part
    add constraint fk_prx_open_transaction_on_category
        foreign key (category_id) references prx_customer_category;

alter table prx_open_transaction_part
    add constraint fk_prx_open_transaction_on_customer
        foreign key (customer_id) references prx_customer;

alter table prx_open_transaction_part
    add constraint fk_prx_open_transaction_on_route
        foreign key (route_id) references prx_route;

alter table prx_open_transaction_part
    add constraint fk_prx_open_transaction_on_tariff
        foreign key (tariff_id) references prx_tariff;

alter table prx_open_transaction_part
    add constraint fk_prx_open_transaction_on_trans_type_combination
        foreign key (trans_type_combination_id) references prx_transaction_type_combinati;

alter table prx_open_transaction_part
    add constraint fk_prx_open_transaction_on_transaction
        foreign key (transaction_id) references prx_transaction;
/**/


/*indexing*/


create index if not exists idx_opentransaction_part
    on public.prx_open_transaction_part (account_type_id);

create index if not exists idx_opentransaction_block_id_part
    on public.prx_open_transaction_part (block_id);

create index if not exists idx_opentransaction_route_id_part
    on public.prx_open_transaction_part (route_id);

create index if not exists idx_opentransaction_tariff_id_part
    on public.prx_open_transaction_part (tariff_id);

create index if not exists idx_prx_open_transaction_debt_part
    on public.prx_open_transaction_part (due_date, deleted_by, used_in_bill, account_type_id, customer_id);

create index if not exists idx_prx_open_transaction_settlement_part
    on public.prx_open_transaction_part (account_type_id, trans_type_combination_id, amount, customer_number);

create index if not exists idx_prx_open_transaction_dep_part
    on public.prx_open_transaction_part (customer_id, used_in_bill, invoice_date, deleted_date);

create index if not exists idx_prx_open_transaction_part
    on public.prx_open_transaction_part (transaction_id, amount, deleted_by);
/**/
grant select on public.prx_open_transaction_part to teldoc;

