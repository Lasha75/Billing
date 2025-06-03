with pay as (select customer_number
             from prx_transaction tr
             join prx_transaction_type_combinati pttc on pttc.id = tr.trans_type_combination_id
             JOIN prx_transaction_type ptt ON ptt.id = pttc.transaction_type_id
             JOIN prx_transaction_sub_type ptst ON ptst.id = pttc.transaction_sub_type_id
             WHERE pttc.deleted_by IS NULL
               AND ptt.deleted_by IS NULL
               and ptst.deleted_by IS NULL
               and ptt.code = '003'),
     dz AS (select sum(amount) dz,
                   am.customer_id
            from (select sum(o.amount) as amount,
                         o.customer_id
                  From prx_open_transaction o
                  where o.deleted_by is null
                    and (o.account_type_id = (select p.contract_type_telmico_id from prx_parameters p) or
                         o.account_type_id is null)
                    and o.created_date >= (date_trunc('month', now()) + interval '-3 year')
                  group by o.customer_id
                  union
                  SELECT sum(o.amount),
                         o.customer_id
                  from prx_open_transaction o
                  WHERE o.deleted_by is null
                    and o.account_type_id = (select p.contract_type_deposite_id from prx_parameters p)
                  group by o.customer_id) am
            group by am.customer_id),
     bal AS (select r.customer_number,
                    r.daricxvaamount charge
             from prx_debtor_balance_report r /*prx_currentbalancenew1_vw*/
             where r.period_ = ${Period}
               and r.customer_number not in ('6016601', '7160190', '5015501'))


select cu.customer_number,
       cui.customerName,
       cui.category,
       cui.address,
       cu.create_date,
       b.charge,
       d.dz
from prx_customer cu
left outer join (select cc.customer_number as customer_number,
                        cc.name            as customerName,
                        cat.name           as category,
                        cc.address_text       address
                 from prx_customer cc
                 left outer join prx_give_type gt on gt.id = cc.give_type_id
                 left outer join prx_customer_category cat on cat.id = cc.category_id
                 where cc.deleted_by is null
                   and gt.deleted_by is null
                   and cat.deleted_by is null) cui on cui.customer_number = cu.customer_number
left join pay p on cu.customer_number = p.customer_number
left join dz d on d.customer_id = cu.id
left join bal b on b.customer_number = cu.customer_number
where p.customer_number is null




