with cust_pay as (select x.customer_id        as customer_id,
                         x.amount             as amount,
                         x.tlmc_amount,
                         x.tls_amount,
                         x.dep_amount,
                         x.reporting_date,
                         c.categoryreportname as cat,
                         c.give_type             supl
                  from (select t.customer_id,
                               ss.amount as amount,
                               case
                                   ss.account_type_id
                                   when 'c425684a-1695-fca4-b245-73192da9a52e'
                                       then ss.amount
                                   end      tlmc_amount,
                               case
                                   when ss.account_type_id = '74a4b43c-2bb1-1321-b7f2-ba06dadc72ae'
                                       then ss.amount
                                   end      tls_amount,
                               case
                                   when ss.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9'
                                       then ss.amount
                                   end      dep_amount,
                               ss.account_type_id,
                               t.customer_number,
                               t.reporting_date,
                               ss.trans_type_combination_id
                        From prx_settle_transaction ss
                        join prx_transaction t
                             on t.id = ss.transaction_id
                        where t.deleted_by is null
                          and ss.deleted_by is null
                          and ss.trans_type_combination_id in
                              ('4a431bec-24cd-c871-b54d-3ef9ffe1eecb',
                               'df95642d-0f4c-cd63-7689-8b7d4fb80d41') /*დეპოზიტი, ნაღდი*/
                          and t.reporting_date = ${pmDate}
union all
          select o.customer_id,
                o.amount as amount,
                               case
                                   coalesce(o.account_type_id, 'c425684a-1695-fca4-b245-73192da9a52e')
                                   when 'c425684a-1695-fca4-b245-73192da9a52e'
                                       then o.amount
                                   when 'c425684a-1695-fca4-b245-73192da9a52e'
                                       then o.amount
                                   end      tlmc_amount,
                               case
                                   when o.account_type_id = '74a4b43c-2bb1-1321-b7f2-ba06dadc72ae'
                                       then o.amount
                                   end      tls_amount,
                               case
                                   when o.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9'
                                       then o.amount
                                   end      dep_amount,
                               o.account_type_id,
                               t.customer_number,
                               t.reporting_date,
                               o.trans_type_combination_id
          from prx_open_transaction o
          join prx_transaction t on t.id = o.transaction_id
          where o.deleted_by is null and t.deleted_by is null
            and o.amount != 0
            and t.reporting_date = ${pmDate}
            and o.trans_type_combination_id in ('4a431bec-24cd-c871-b54d-3ef9ffe1eecb','df95642d-0f4c-cd63-7689-8b7d4fb80d41')) x
        left outer join prx_customer_full_vw c on c.id = x.customer_id)

select *
from (select sum(com_pub)                     com_pub,
             sum(bud_pub)                     bud_pub,
             sum(com_uni)                     com_uni,
             sum(pop_uni)                     pop_uni,
             rep_date,
             sum(tlmc_amount + coalesce(dep_amount,0))                 tlmc_amount,
             sum(tls_amount)                  tls_amount,
             sum(dep_amount)                    dep_amount,
             sum(amount)                      amount
      from (select case cust_pay.supl
                       when 'public' then
                           case cust_pay.cat
                               when 'Коммерческий' then amount
                               end
                       end                 com_pub,
                   case cust_pay.supl
                       when 'public' then
                           case cust_pay.cat
                               when 'Бюджет' then amount
                               end
                       end                 bud_pub,
                   case cust_pay.supl
                       when 'universal' then
                           case cust_pay.cat
                               when 'Коммерческий' then amount
                               end
                       end                 com_uni,
                   case cust_pay.supl
                       when 'universal' then
                           case cust_pay.cat
                               when 'Абонентский' then amount
                               end
                       end                 pop_uni,
                   cust_pay.reporting_date rep_date,
                   cust_pay.tlmc_amount    tlmc_amount,
                   cust_pay.tls_amount     tls_amount,
                   cust_pay.amount         amount,
                   cust_pay.dep_amount
            from cust_pay) rs
      group by rs.rep_date) s