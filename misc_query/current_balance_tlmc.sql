with cur_amount as (select customer_number,
                           sum(old_amount_neg) amount
                    from (select otr.customer_number,
                                 sum(coalesce(otr.amount, 0)) as old_amount_neg
                          From prx_open_transaction otr
                          where otr.deleted_by is null
                            -- and coalesce(otr.amount, 0) > 0
                            and (otr.account_type_id = (select p.contract_type_telmico_id from prx_parameters p) or
                                 otr.account_type_id is null or
                                 otr.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9'/*deposit*/)
                            and otr.created_date >= (date_trunc('month', now()) + interval '-3 year')
                            and customer_number = '0860517'
                            AND otr.trans_date >= (now()::DATE - INTERVAL '3 year')
                          group by otr.customer_number
                          union
                          SELECT o.customer_number,
                                 sum(coalesce(o.amount, 0))
                          FROM prx_open_transaction o
                          WHERE o.deleted_by IS NULL
                            and customer_number = '0860517'
                            AND o.trans_date < (now()::DATE - INTERVAL '3 year')
                            AND coalesce(o.amount, 0) < 0
                          GROUP BY o.customer_number) am
                    group by customer_number),
    /*neg_amount as (select o.customer_number,
                          sum(coalesce(o.amount, 0)) neg_amount
                   from prx_open_transaction o
                   where o.deleted_by is null
                     AND (o.account_type_id = (SELECT p.contract_type_telmico_id FROM prx_parameters p)
                       OR o.account_type_id IS NULL)
                     AND coalesce(o.amount, 0) < 0 and customer_number='4144526'
                   group by o.customer_number),*/
     old_amount as (SELECT o.customer_number, sum(coalesce(o.amount, 0)) old_amount
                    FROM prx_open_transaction o
                    WHERE o.deleted_by IS NULL
                      and customer_number = '0860517'
                      AND o.trans_date
                        < (now()::DATE - INTERVAL '3 year')
                      AND coalesce(o.amount, 0)> 0
                    GROUP BY o.customer_number)

select /*coalesce(*/coalesce(ca.customer_number, oa.customer_number)/*, na.customer_number)*/ cust,
                    amount,
--        neg_amount,
--        (coalesce(amount,0) + coalesce(neg_amount,0))+ old_amount cur_bal,
          old_amount
from cur_amount ca
full join old_amount oa on oa.customer_number = ca.customer_number
-- full join neg_amount na on na.customer_number = ca.customer_number


/*select  customer_number,
regexp_replace(r.customer_name, '[\x00-\x1F\x7F]', '', 'g') as customer_name,
give_type,
business_center,
category,
abonentissatusi,
sawkisivaliamount,
daricxvaamount,
subsidiaamount,
gadaxdebiamount,
davalianebaamount -- ეს ჭირდება გარძეევს, პროქსიმასთან
from prx_debtor_balance_report r
where r.period_=${period}
and r.customer_number not in ('6016601','7160190','5015501')*/