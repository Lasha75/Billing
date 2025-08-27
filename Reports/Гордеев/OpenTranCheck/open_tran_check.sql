SELECT otr.customer_number num,
                    sum(case
                             when coalesce(otr.amount, 0) > 0
                                 then otr.amount
                             else 0 end) sum_pos,
                                    sum(case
                             when coalesce(otr.amount, 0) < 0
                                 then otr.amount
                             else 0 end) sum_neg,
                     sum(case
                             when trans_date < (current_date - INTERVAL '3 year') and otr.amount > 0
                                 then otr.amount
                             else 0 end) old_debt
              from public.prx_open_transaction otr
              where otr.deleted_by is null
                and coalesce(otr.amount, 0) != 0
              group by otr.customer_number