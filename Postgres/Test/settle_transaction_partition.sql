create table if not exists public.prx_settle_transaction_part
(
    id                        uuid    not null,
    connection_uuid           uuid    not null,
    account_type_id           uuid,
    settlement_connection_id  bigint,
    category_id               uuid,
    customer_id               uuid    not null,
    customer_number           varchar(100),
    account_number            varchar(100),
    amount                    numeric(19, 2),
    category_name             varchar(200),
    block_id                  uuid,
    block_name                varchar(200),
    route_id                  uuid,
    route_name                varchar(200),
    trans_date                date    not null,
    due_date                  date,
    trans_type_combination_id uuid    not null,
    settle_date               date,
    is_reversed               boolean,
    connected_trans_id        uuid,
    transaction_id            uuid    not null,
    version                   integer not null,
    created_by                varchar(255),
    created_date              timestamp,
    last_modified_by          varchar(255),
    last_modified_date        timestamp,
    deleted_by                varchar(255),
    deleted_date              timestamp
)PARTITION BY RANGE(created_date);

alter table public.prx_settle_transaction_part
    owner to "Billing";

CREATE TABLE public."prx_settle_tran_2021_2022" PARTITION OF public.prx_settle_transaction_part
FOR VALUES from (timestamp '01-jun-2021 00:00:00') to (timestamp'31-dec-2022 00:00:00');

CREATE TABLE public."prx_settle_tran_2023" PARTITION OF public.prx_settle_transaction_part
FOR VALUES from (timestamp'01-jan-2023 00:00:00') to (timestamp'31-dec-2023 00:00:00');

CREATE TABLE public."prx_settle_tran_null" PARTITION OF public.prx_settle_transaction_part  default;

insert into prx_settle_transaction_part
select * from prx_settle_transaction ;


/*constraint*/
alter table prx_settle_transaction_part
    add constraint pk_prx_settle_transaction
        primary key (id, created_date);

alter table prx_settle_transaction_part
    add constraint fk_prx_settle_transaction_on_account_type
        foreign key (account_type_id) references prx_customer_contract_type;

alter table prx_settle_transaction_part
    add constraint fk_prx_settle_transaction_on_block
        foreign key (block_id) references prx_block;

alter table prx_settle_transaction_part
    add constraint fk_prx_settle_transaction_on_category
        foreign key (category_id) references prx_customer_category;

alter table prx_settle_transaction_part
    add constraint fk_prx_settle_transaction_on_connected_trans
        foreign key (connected_trans_id) references prx_settle_transaction;

alter table prx_settle_transaction_part
    add constraint fk_prx_settle_transaction_on_customer
        foreign key (customer_id) references prx_customer;

alter table prx_settle_transaction_part
    add constraint fk_prx_settle_transaction_on_route
        foreign key (route_id) references prx_route;

alter table prx_settle_transaction_part
    add constraint fk_prx_settle_transaction_on_trans_type_combination
        foreign key (trans_type_combination_id) references prx_transaction_type_combinati;

alter table prx_settle_transaction_part
    add constraint fk_prx_settle_transaction_on_transaction
        foreign key (transaction_id) references prx_transaction;
/**/


/*indexing*/
create index if not exists idx_prx_settle_transaction_part
    on public.prx_settle_transaction_part (customer_id, deleted_by, trans_date, account_type_id);

create index if not exists idx_prx_settle_transaction_1_part
    on public.prx_settle_transaction_part (transaction_id, deleted_by);

create index if not exists idx_settletransaction_part
    on public.prx_settle_transaction_part (account_type_id);
/**/
grant select on public.prx_settle_transaction_part to teldoc;