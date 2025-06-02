select
       t.customer_number,
       sum(t.amount)                                              as amount,
       sum(t.kilowatt_hour)                                       as kw
from prx_transaction t
where t.deleted_by is null
  and t.created_date::date between '2023-01-31' and '2023-01-31'
  and (((t.kilowatt_hour = 0 or t.kilowatt_hour is null) and (t.amount = 0 or t.amount is null) and
     t.cycle_type = 'CIRCULAR' and t.trans_type_combination_id != 'dac93a92-41eb-8905-7021-53f1f8d559b5'/*ჯამური დარიცხვა*/ )
        or
    (t.kilowatt_hour != 0 and t.kilowatt_hour is not null and t.amount != 0 and t.amount is not null))
group by t.customer_number

;