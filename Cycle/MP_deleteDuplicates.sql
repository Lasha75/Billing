--დუბლირებული აბონენტები
drop table if exists doubleTMP;
create temp table doubleTMP
(
    custNum       varchar(30),
    counterNumber varchar(40)
);
/*ეს სია ამოსაღებია და მისაწოდებელი*/
insert into doubleTMP(custNum, counterNumber)
select a.customer_number,
       a.counter_number
from (select tr.customer_number,
             tr.counter_number
      from prx_transaction tr
      where tr.deleted_by is null
        and tr.created_by = 'mppower'
        and tr.trans_type_combination_id = 'cb8dea8a-260d-f09d-9772-5bd28b01c663'--სალდირებული დარიცხვა
        and tr.created_date >= date_trunc('month', current_date)--'2025-03-01'
      group by tr.customer_number, tr.counter_number
      having count(tr.customer_number) = 2) a
group by a.customer_number,
         a.counter_number;


-- select * from doubleTMP;
/*დუბლირებული ტრანზაქციების წამოღება*/
drop table if exists delIds;
create temp table delIds
(
    trid uuid
);
insert into delIds(trid)
select a.id
from (select tr.id,
             tr.customer_number,
             tr.counter_number,
             row_number() over (partition by tr.customer_number,tr.counter_number order by abs(tr.kilowatt_hour)) as dt
      from prx_transaction tr
      join doubleTMP dd on dd.custNum = tr.customer_number and dd.counterNumber = tr.counter_number
      where tr.deleted_by is null
        and tr.created_by = 'mppower'
        and tr.trans_type_combination_id = 'cb8dea8a-260d-f09d-9772-5bd28b01c663'--სალდირებული დარიცხვა
        and tr.created_date >= date_trunc('month', current_date)
      ) a
where a.dt > 1;
/*ეს სია ამოსაღებია და მისაწოდებელი*/
select *
from (select tr.id,
             tr.customer_number,
             tr.amount  tr_amount,
             otr.amount otr_amount
      from prx_transaction tr
      join prx_open_transaction otr on tr.id = otr.transaction_id
      join delIds dd on dd.trid = tr.id
      where tr.deleted_by is null
        and otr.deleted_by is null
        and tr.trans_type_combination_id = 'cb8dea8a-260d-f09d-9772-5bd28b01c663') t
where tr_amount != otr_amount;



update prx_transaction tr
set deleted_by   = 'lkhvichia',
    deleted_date =now()
from delIds dl
where dl.trid = tr.id;

update prx_open_transaction tr
set deleted_by   = 'lkhvichia',
    deleted_date =now()
from delIds dl
where dl.trid = tr.transaction_id;
/**/


--ტარიფის updateთვის ჩანაწერები
drop table if exists upTMP;
create temp table upTMP
(
    trId       uuid,
    amount     decimal(19, 2),
    categoryId uuid,
    giveTypeId uuid,
    tariffId   uuid,
    stepNumber int
);
insert into upTMP(trId, amount, categoryId, giveTypeId, tariffId, stepNumber)
select tr.id,
       round(ln.value_ * tr.kilowatt_hour, 2) as am2,
       tar.customer_category_id,
       cc.give_type_id,
       tar.id,
       ln.step_number
from prx_transaction tr
join doubleTMP tmp on tmp.custNum = tr.customer_number and tmp.counterNumber = tr.counter_number
join prx_counter met on met.code = tr.counter_number and met.deleted_by is null
join prx_tariff tar on tar.id = met.tariff_id and tar.deleted_by is null
join prx_tariff_line ln on ln.tariff_id = tar.id and ln.deleted_by is null
join prx_customer cc on cc.customer_number = tr.customer_number and cc.deleted_by is null
where tr.deleted_by is null
  and tr.created_by = 'mppower'
  and tr.trans_type_combination_id = 'cb8dea8a-260d-f09d-9772-5bd28b01c663'
  and tr.created_date >= date_trunc('month', current_date)--'2025-03-01'
  and abs(tr.kilowatt_hour) > ln.start_killowat
  and abs(tr.kilowatt_hour) < ln.end_killowat
order by tr.customer_number, tr.counter_number;


/*ტრანზაქციების update*/
update prx_transaction tr
set amount       = pp.amount,
    category_id  = pp.categoryId,
    give_type_id = pp.giveTypeId,
    step         = pp.stepNumber,
    tariff_id    = pp.tariffId
from upTMP pp,
     prx_tariff tar
where tr.id = pp.trId
  and tar.id = pp.tariffId
  and tar.deleted_by is null
  and tr.deleted_by is null;
/**/

/*ღია ტრანზაქციების update*/
update prx_open_transaction tr
set amount       = pp.amount,
    category_id  = pp.categoryId,
    give_type_id = pp.giveTypeId,
    tariff_id    = pp.tariffId
from upTMP pp,
     prx_tariff tar
where tr.transaction_id = pp.trId
  and tar.id = pp.tariffId
  and tar.deleted_by is null
  and tr.deleted_by is null;
/**/

/*უარყოფითი დარიცხვის (kwt) თანხის განულება*/
drop table if exists minusTMP;
create temp table minusTMP(trId uuid);
insert  into minusTMP(trId)
select tr.id
      from prx_transaction tr
      where tr.deleted_by is null
        and tr.created_by = 'mppower'
        and tr.trans_type_combination_id = 'cb8dea8a-260d-f09d-9772-5bd28b01c663'--სალდირებული დარიცხვა
        and tr.created_date >= date_trunc('month', current_date)--y=asfvasdfasdfasdfasdfas'2025-03-01'
        and tr.kilowatt_hour < 0
        and coalesce(tr.amount, 0) != 0;

update prx_transaction tr
set amount = null
from minusTMP mm
where mm.trId = tr.id;

update prx_open_transaction tr
set amount = null
from minusTMP mm
where mm.trId = tr.transaction_id;
/**/

/* გაითვალისწინე რომ, ტრანზაქციების წაშლის დროს, ის ჩანაწერები რომლებსაც შლი არ უნდა იყოს შეთავსებული.
 ყველა ტრანზაქციას აქვს ჩანაწერი ღია ტრანზაქციების ცხრილში. ანუ იმ ტრანზაქციებს რომლებსაც შლი ტრანზაქციებში და ღია ტრანზაქციებში უნდა ქონდეთ ერთნაირი თანხა.
 თუ ღია ტრანზაქციების ცხრილში და ტრანზაქციების ცხრილში განსხვავებული თანხა გაქვს, ეგეთ აბონენტებზე უნდა გაკეთო ამოთავსება,
 მერე წაშალო წასაშლელები და თავიდან შეათავსო რაც დარჩება ის ტრანზაქციები. შეთავსება/ამოთავსება ბილინგში ყველა იცის და გეტყვიან.

თანხა რო არ ემთხვევა ერთმანეთს, ძაან ბევრი ჩანაწერია მაგ ცხრილებში. ეგ რას ნიშნავს, თუ ერთნაირი თანხები არ აქვთ ტრანზაქციებს? -
    ეგრე უნდა იყოს როცა შეთავსდება მერე არ დაემთხვევა, მაგრამ წაშლის მომენტში უნდა ემთხვეოდეს.
შეთავსების არსი ხო იცი რაც არის, რაღაცა გადახდა ხურავს რაღაც ვალს.
როცა შლი ტრანზაქციას შეთავხებული არ უნდა იყოს, ანუ ღია ტრანზაქციების და ტრანზაქციების თანხები ერთნაიერი უნდა იყოს.
*/
