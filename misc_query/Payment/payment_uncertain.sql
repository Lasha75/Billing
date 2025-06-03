select tr.customer_number,
       cu.name,
       tr.amount,
       bank_code,
       pm.status,
       payment_doc_number,
       pm.comment_,
       tr.comment_,
       pm.payment_date,
       tr.created_by
from prx_transaction tr
join prx_payment pm on tr.payment_doc_number = pm.payment_id
left join prx_customer cu on tr.customer_id = cu.id
where /*tr.comment_ like '%გაურკვევლ%' or tr.comment_ like '%გაურკვეველ%'*/
    (tr.created_by like '%kkhakhishvili%' or tr.created_by like '%kikab%' or tr.created_by like '%maisu%'
        or tr.created_by like '%bibil%')
  and tr.deleted_by is null
  and tr.reporting_date::date between date_trunc('month', current_date - INTERVAL '1 month')::date
      and (date_trunc('month', current_date) - INTERVAL '1 day')::date;
