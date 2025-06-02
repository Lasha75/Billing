create temp table chargeTMP
(
    custNum varchar(30),
    metCode varchar(40),
    kwt     decimal(19, 2),
    amount  decimal(19, 2),
    step    int
);
insert into chargeTMP(custNum, metCode, kwt, amount, step)
select c.customer_number,
       met.code,
       imp.daricxva_kwt,
       imp.amount,
       imp.stepi
from "importCharges" imp
join prx_customer c on c.cust_key = imp.custkey
join prx_counter met on met.cust_key = c.cust_key
where c.deleted_by is null
  and met.deleted_by is null;


create temp table transTMP
(
    trId   uuid,
    amount decimal(19, 2),
    kwt    decimal(19, 2),
    step   int
);
insert into transTMP(trId, amount, kwt, step)
select tr.id,
       ch.amount,
       kwt,
       ch.step
from chargeTMP ch
join prx_transaction tr on tr.customer_number = ch.custNum and tr.counter_number = ch.metCode
where tr.deleted_by is null
  and tr.trans_date = '2024-06-27'
  and tr.kilowatt_hour = 0;

select *
from transTMP;

select *
From transTMP imp
join prx_transaction tr on tr.id = imp.trId
where tr.deleted_by is null;

/*
update prx_transaction tr
set amount = imp.amount,
    kilowatt_hour = imp.kwt,
    step = imp.step
from transTMP imp
 where tr.id = imp.trId;


update prx_open_transaction tr
set amount = imp.amount,
    kilowatt_hour = imp.kwt
from transTMP imp
 where tr.transaction_id = imp.trId;

 */
