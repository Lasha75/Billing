select s.trans_date,
       s.aviso_date,
       s.create_date,
       --sum(s.amount) amount,
       case s.give_Type
           when 'public' then
               case cat
                   when 'Коммерческий' then sum(s.amount)
               end
           end com_pub,
       case s.give_Type
           when 'public' then
               case cat
                   when 'Бюджет' then sum(s.amount)
               end
           end bud_pub,
       case s.give_Type
           when 'universal' then
               case cat
                   when 'Коммерческий' then sum(s.amount)
               end
           end com_uni,
       case s.give_Type
           when 'universal' then
               case cat
                   when 'Абонентский' then sum(s.amount)
               end
           end pop_uni/*,
       case s.give_Type
           when 'public' then
               case cat
                   when 'Коммерческий' then sum(s.amount)
                   when 'Бюджет' then sum(s.amount)
               end
           end pub,
       case s.give_Type
           when 'universal' then
               case cat
                   when 'Коммерческий' then sum(s.amount)
                   when 'Абонентский' then sum(s.amount)
               end
           end uni*/
from (select x.trans_date,
             x.aviso_date,
             x.create_date,
             sum(x.amount) as      amount,
             x.give_Type,
             x.repor_category_name cat
      from (select r.*, c.*
            from PRX_DEBTOR_PAYMENT_ACCOUNT r
            left outer join (select gt.name  as give_Type,
                                    cat.name as category,
                                    cc.id,
                                    cat.repor_category_name
                             from prx_customer cc
                             left outer join prx_give_type gt on gt.id = cc.give_type_id
                             left outer join prx_customer_category cat on cat.id = cc.category_id
                             where cc.deleted_by is null
                                    and gt.deleted_by is null
                                    and cat.deleted_by is null) c on r.customer_id = c.id
            left outer join prx_customer_contract_type cct on cct.id = r.account_type_id and cct.deleted_by is null) x
      where ((x.operacia = 'Денежная' and x.aviso_date between ${startDate} and ${endDate})
          or (x.operacia = 'Неденежная' and x.trans_date between ${startDate} and ${endDate}))
        and ((trim(lower(x.give_Type)) = 'public' and x.repor_category_name = 'Коммерческий')
          or (trim(lower(x.give_Type)) = 'public' and x.repor_category_name = 'Бюджет')
          or (trim(lower(x.give_Type)) = 'universal' and x.repor_category_name = 'Коммерческий')
          or (trim(lower(x.give_Type)) = 'universal' and x.repor_category_name = 'Абонентский'))
      group by x.aviso_date,
               x.trans_date,
               x.create_date,
               x.give_Type,
               x.category,
               x.repor_category_name) s
where s.amount != 0
group by s.trans_date,
         s.aviso_date,
         s.create_date,
         s.give_Type,
         s.cat;











select r.trans_date,
       r.aviso_date,
       r.create_date,
       case cat when 'Commercial_pub' then amount end com_public,
       case cat when 'Budget_pub' then amount end budg,
       case cat when 'Commercial_uni' then amount end com_univer,
       case cat when 'Population' then amount end pop,
       r.cat
from (select s.trans_date,
                      s.aviso_date,
                      s.create_date,
                      sum(s.amount) amount,
                      'Commercial_pub' cat
               from (select x.trans_date,
                            x.aviso_date,
                            x.create_date,
                            sum(x.amount) as amount,
                            x.category,
                            x.repor_category_name
                     from (select r.*, c.*
                           from PRX_DEBTOR_PAYMENT_ACCOUNT r
                           left outer join (select gt.name  as give_Type,
                                                    cat.name as category,
                                                    cc.id,
                                                    cat.repor_category_name
                                             from prx_customer cc
                                             left outer join prx_give_type gt on gt.id = cc.give_type_id
                                             left outer join prx_customer_category cat on cat.id = cc.category_id
                                             where cc.deleted_by is null
                                                    and gt.deleted_by is null
                                                    and cat.deleted_by is null) c on r.customer_id = c.id
                          left outer join prx_customer_contract_type cct on cct.id = r.account_type_id and cct.deleted_by is null) x
                     where ((x.operacia = 'Денежная' and x.aviso_date between ${startDate} and ${endDate})
                         or (x.operacia = 'Неденежная' and x.trans_date between ${startDate} and ${endDate}))
                       and trim(lower(x.give_Type)) = 'public'
                       and trim(lower(x.repor_category_name) = 'коммерческий')
                     group by x.aviso_date,
                              x.trans_date,
                              x.create_date,
                              x.give_Type,
                              x.category) s
               group by s.trans_date,
                        s.aviso_date,
                        s.create_date
               union
               select s.trans_date,
                      s.aviso_date,
                      s.create_date,
                      sum(s.amount) amount,
                      'Budget_pub' cat
               from (select x.trans_date,
                            x.aviso_date,
                            x.create_date,
                            sum(x.amount) as amount,
                            x.category,
                            x.repor_category_name
                     from (select r.*, c.*
                           from PRX_DEBTOR_PAYMENT_ACCOUNT r
                           left outer join (select gt.name  as give_Type,
                                                    cat.name as category,
                                                    cc.id,
                                                    cat.repor_category_name
                                            from prx_customer cc
                                            left outer join prx_give_type gt on gt.id = cc.give_type_id
                                            left outer join prx_customer_category cat on cat.id = cc.category_id
                                            where cc.deleted_by is null
                                                  and gt.deleted_by is null
                                                  and cat.deleted_by is null) c on r.customer_id = c.id
                           left outer join prx_customer_contract_type cct on cct.id = r.account_type_id and cct.deleted_by is null) x
                     where ((x.operacia = 'Денежная' and x.aviso_date between ${startDate} and ${endDate})
                         or (x.operacia = 'Неденежная' and x.trans_date between ${startDate} and ${endDate}))
                       and trim(lower(x.give_Type)) = 'public'
                       and trim(lower(x.repor_category_name) = 'бюджет')
                     group by x.aviso_date,
                              x.trans_date,
                              x.create_date,
                              x.give_Type,
                              x.category
                     ) s
               group by s.trans_date,
                        s.aviso_date,
                        s.create_date
               union
               select s.trans_date,
                      s.aviso_date,
                      s.create_date,
                      sum(s.amount) amount,
                      'Commercial_uni' cat
               from (select x.trans_date,
                            x.aviso_date,
                            x.create_date,
                            sum(x.amount) as amount,
                            x.category,
                            x.repor_category_name
                     from (select r.*, c.*
                           from PRX_DEBTOR_PAYMENT_ACCOUNT r
                           left outer join (select gt.name  as give_Type,
                                                    cat.name as category,
                                                    cc.id,
                                                    cat.repor_category_name
                                             from prx_customer cc
                                             left outer join prx_give_type gt on gt.id = cc.give_type_id
                                             left outer join prx_customer_category cat on cat.id = cc.category_id
                                             where cc.deleted_by is null
                                                    and gt.deleted_by is null
                                                    and cat.deleted_by is null) c on r.customer_id = c.id
                          left outer join prx_customer_contract_type cct on cct.id = r.account_type_id and cct.deleted_by is null) x
                     where ((x.operacia = 'Денежная' and x.aviso_date between ${startDate} and ${endDate})
                         or (x.operacia = 'Неденежная' and x.trans_date between ${startDate} and ${endDate}))
                       and trim(lower(x.give_Type)) = 'universal'
                       and trim(lower(x.repor_category_name) = 'коммерческий')
                     group by x.aviso_date,
                              x.trans_date,
                              x.create_date,
                              x.give_Type,
                              x.category) s
               group by s.trans_date,
                        s.aviso_date,
                        s.create_date
               union
               select s.trans_date,
                      s.aviso_date,
                      s.create_date,
                      sum(s.amount) amount,
                      'Population' cat
               from (select x.trans_date,
                            x.aviso_date,
                            x.create_date,
                            sum(x.amount) as amount,
                            x.category,
                            x.repor_category_name
                     from (select r.*, c.*
                           from PRX_DEBTOR_PAYMENT_ACCOUNT r
                           left outer join (select gt.name  as give_Type,
                                                    cat.name as category,
                                                    cc.id,
                                                    cat.repor_category_name
                                             from prx_customer cc
                                             left outer join prx_give_type gt on gt.id = cc.give_type_id
                                             left outer join prx_customer_category cat on cat.id = cc.category_id
                                             where cc.deleted_by is null
                                                    and gt.deleted_by is null
                                                    and cat.deleted_by is null) c on r.customer_id = c.id
                          left outer join prx_customer_contract_type cct on cct.id = r.account_type_id and cct.deleted_by is null) x
                     where ((x.operacia = 'Денежная' and x.aviso_date between ${startDate} and ${endDate})
                         or (x.operacia = 'Неденежная' and x.trans_date between ${startDate} and ${endDate}))
                       and trim(lower(x.give_Type)) = 'universal'
                       and trim(lower(x.repor_category_name) = 'абонентский')
                     group by x.aviso_date,
                              x.trans_date,
                              x.create_date,
                              x.give_Type,
                              x.category) s
               group by s.trans_date,
                        s.aviso_date,
                        s.create_date               ) r
where r.amount !=0
order by r.trans_date;



/*deposit*/
select r.trans_date,
       r.aviso_date,
       r.created_date,
       case cat when 'Commercial' then amount end com_amount_dep,
       case cat when 'Budget' then amount end bud_amount_dep,
        r.cat
from (
SELECT tr.trans_date,
         tr.aviso_date,
         tr.created_date,
        sum(tr.amount) amount,
        'Commercial' cat
from prx_transaction tr
join prx_customer cu on tr.customer_id = cu.id
join prx_give_type supl on supl.id = cu.give_type_id and supl.code = 'C2' --public
join prx_customer_category cat on cat.id = cu.category_id and cat.code in ('C248', 'C257', 'C37', 'C256', 'C258')
WHERE tr.deleted_by is null
  and tr.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9'
  and (tr.TRANS_TYPE_COMBINATION_ID = '4a431bec-24cd-c871-b54d-3ef9ffe1eecb') --დეპოზიტის გადახდა
    and tr.trans_date between ${startDate} and ${endDate}
group by tr.trans_date,
         tr.aviso_date,
         tr.created_date
union
SELECT tr.trans_date,
         tr.aviso_date,
         tr.created_date,
        sum(tr.amount) amount,
        'Budget' cat
from prx_transaction tr
join prx_customer cu on tr.customer_id = cu.id
join prx_give_type supl on supl.id = cu.give_type_id and supl.code = 'C2' --public
join prx_customer_category cat on cat.id = cu.category_id and cat.code in ('C249', 'C44', 'C259', 'C261', 'C260')
WHERE tr.deleted_by is null
  and tr.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9'
  and (tr.TRANS_TYPE_COMBINATION_ID = '4a431bec-24cd-c871-b54d-3ef9ffe1eecb') --დეპოზიტის გადახდა
    and tr.trans_date between ${startDate} and ${endDate}
group by tr.trans_date,
         tr.aviso_date,
         tr.created_date) r
order by r.trans_date;