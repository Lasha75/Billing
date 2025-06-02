create or replace procedure "LK".prc_overdue_payment()
    language plpgsql
as
$$
declare
    v_count integer :=0;
begin
    DROP TABLE IF EXISTS Good_Customers, TempCustomers, customers_delayer;
    truncate table "LK".lk_overdue_payment_report;

    create temporary table TempCustomers
    (
        customer_id UUid
    );

    create table customers_delayer
    (
        customer_id UUid,
        wina        date,
        start_date  date,
        end_date    date
    );

    create temporary table Good_Customers
    (
        customer_id    UUid,
        transaction_id uuid,
        amount         numeric(12, 2),
        gadaxda        numeric(12, 2) default 0,
        trans_date     date,
        due_date       date,
        gadaxd_date    date,
        wina           date,
        start_date     date,
        end_date       date,
        real_due_date  date,
        bad_trans      boolean
    );

    -- აბონენტების სია რომლებსაც აქვთ ერთი მაინც დარიცხვის ტრანზაქცია.
    insert into TempCustomers(customer_id)
    select distinct pt.customer_id as customer_id
    from public.prx_transaction pt
    join public.prx_transaction_type_combinati tt on tt.id = pt.trans_type_combination_id
    where pt.account_type_id in ('c425684a-1695-fca4-b245-73192da9a52e',
                                 '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9')  -- თელმიკო ოპერაციები და დეპოზიტი
      and tt.transaction_type_id = '7902fe57-9a18-35d3-4ab3-b593c1884a13' -- დარიცხვა
      and pt.trans_date::date > (current_date - interval '3 year')::date
      and pt.amount > 0;

    -- ახლა ამ სიისაგან გამოვრიცხოთ ყველა ის აბონენტი რომელსაც აქვს მუდმივი გადავადება
    delete
    from TempCustomers tc using (select d.customer_id
                                 from public.prx_delayer d
                                 where d.status = 'ACTIVE'
                                   and d.type_ = 'PERMANENT') a
    where a.customer_id = tc.customer_id;

-- ამ სიიდან ახლა კი გამოვრიცხოთ ყველა აბონენტი რომელსაც აქვს დარიცხვის ოპერაციაში ერთი მაინც DUE_DATE = NULL
    delete
    from TempCustomers tc using (select distinct ptt.customer_id as customer_id
                                 from public.prx_transaction ptt
                                 join public.prx_transaction_type_combinati tt on tt.id = ptt.trans_type_combination_id
                                 where ptt.account_type_id in ('c425684a-1695-fca4-b245-73192da9a52e',
                                                               '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9') -- თელმიკო ოპერაციები და დეპოზიტი
                                   and tt.transaction_type_id = '7902fe57-9a18-35d3-4ab3-b593c1884a13' -- დარიცხვა
                                   and ptt.due_date is null
                                   and ptt.trans_date::date > (current_date - interval '3 year')::date
                                   and ptt.amount > 0) aa
    where aa.customer_id = tc.customer_id;

    --  დავადგინოთ აბონენტების და მათი გადავადების პერიოდები
-- ეს ინსერტი ანხორციელებს აბონენტების გადავადებების გაშლას პერიოდებად
    insert into customers_delayer (customer_id, wina, start_date, end_date)
    select a.customer_id,
           case
               when b.end_date is null then a.start_date
               else
                   b.end_date + 1
               end as wina,
           a.start_date,
           a.end_date
    from (select p.customer_id,
                 p.start_date,
                 p.end_date,
                 row_number() over (partition by p.customer_id order by p.start_date asc, p.end_date asc) - 1 as rw_id
          from (select distinct p1.customer_id,
                                p1.start_date,
                                p1.end_date
                from public.prx_delayer p1
                where p1.type_ = 'SHORT_TERM'
                  and p1.status in ('ACTIVE', 'DELAY_ABOLISHED', 'FINISHED')
                  and p1.start_date <= p1.end_date) p) a
    left join (select p.customer_id,
                      p.start_date,
                      p.end_date,
                      row_number()
                      over (partition by p.customer_id order by p.start_date asc, p.end_date asc) as rw_id_p
               from (select distinct p1.customer_id,
                                     p1.start_date,
                                     p1.end_date
                     from public.prx_delayer p1
                     where p1.type_ = 'SHORT_TERM'
                       and p1.status in ('ACTIVE', 'DELAY_ABOLISHED', 'FINISHED')
                       and p1.start_date <= p1.end_date) p) b on b.rw_id_p = a.rw_id and a.customer_id = b.customer_id;

    -- მხოლოდ იმ აბონენტების ტრანზაქციების მიღება რომლებიც გამორიცხვის შედეგად დამრჩა.
-- აქ ჯერ კიდევ არამაქვს კარგი აბონენტები
    insert into Good_Customers (customer_id, transaction_id, amount, trans_date, due_date)
    select pt.customer_id as customer_id,
           pt.id          as transaqtion_id,
           pt.amount      as amount,
           pt.trans_date  as trans_date,
           pt.due_date    as due_date
    from public.prx_transaction pt
    join public.prx_transaction_type_combinati tt on tt.id = pt.trans_type_combination_id
    join TempCustomers tc on tc.customer_id = pt.customer_id
    where pt.account_type_id in ('c425684a-1695-fca4-b245-73192da9a52e',
                                 '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9')  -- თელმიკო ოპერაციები და დეპოზიტი
      and tt.transaction_type_id = '7902fe57-9a18-35d3-4ab3-b593c1884a13' -- დარიცხვა
      and pt.deleted_by is null
      and pt.deleted_date is null
      and pt.trans_date::date > (current_date - interval '3 year')::date
      and pt.amount > 0;


    -- ახლა მინდა მივუყენო ტრანზაქციებს გადავადების პერიოდები, რომ შემდგომში შევძლო გადახდის პერიოდის დადგენა

    update Good_Customers c
    set wina       = d.wina,
        start_date = d.start_date,
        end_date   = d.end_date
    from customers_delayer d
    where d.customer_id = c.customer_id
      and c.trans_date between d.wina and d.end_date;


    -- რეალურად შესრულების თარიღი
    update Good_Customers c
    set real_due_date = case
                            when start_date is null then
                                due_date
                            when due_date < start_date then
                                due_date
                            when due_date > end_date then
                                due_date
                            else
                                end_date
        end;

    -- ახლა ვნახოთ შეთვსებები, დავადგინოთ მოცემულ აბონენტზე და შესაბამის ტრანზაქციაზე
-- შეთავსება  სრულად მოხდა თუ არა  და თუ რამოდენიმე ოპერაციით შეთვსდა ბოლო შეთავსების თარიღი
-- დავადგინოთ.


    update Good_Customers c1
    set gadaxda     = a.sum_amount,
        gadaxd_date = a.max_settle_date
    from (select c.customer_id,
                 c.transaction_id,
                 sum(st.amount)     as sum_amount,
                 max(st.trans_date) as max_settle_date
          from Good_Customers c
          join public.prx_settle_transaction pst on pst.transaction_id = c.transaction_id
          join public.prx_settle_transaction st on st.connection_uuid = pst.connection_uuid
          where st.amount < 0
            and pst.deleted_by is null
            and pst.deleted_date is null
            and st.deleted_by is null
            and st.deleted_date is null
          group by c.customer_id, c.transaction_id) a
    where c1.customer_id = a.customer_id
      and c1.transaction_id = a.transaction_id;


    -- დავადგინოთ ცუდი ტრანზაქციები
    update Good_Customers c
    set bad_trans = true
    where (amount + gadaxda) > 0 or gadaxd_date > real_due_date;


-- წავშალოთ ყველა აბონენტი რომელსაც ერთი მაინც ცუდი ტრანზაქცია აქვს
    delete
    from Good_Customers c1 using (select distinct customer_id
                                  from Good_Customers c
                                  where bad_trans) a
    where a.customer_id = c1.customer_id;

-- წავშალოთ ყველა ის აბონენტი რომელსაც დავალიანება აქვს.
    delete
    from Good_Customers c1 using (select d.customer_id,
                                         sum(d.amount) as sum_amount
                                  from public.prx_open_transaction d
                                  join Good_Customers g on g.customer_id = d.customer_id
                                  where d.deleted_by is null
                                    and d.deleted_date is null
                                  group by d.customer_id
                                  having sum(d.amount) > 0) a
    where a.customer_id = c1.customer_id;

    insert into "LK".lk_overdue_payment_report (customer_id, customer_number)
    select distinct cu.id,
                    cu.customer_number
    from public.prx_customer cu
    join Good_Customers c on c.customer_id = cu.id
    where cu.deleted_by is null;
-- commit;
    GET DIAGNOSTICS v_count = ROW_COUNT;

   RAISE NOTICE 'Rows inserted: %', v_count;

exception
    when no_data_found then
--         rollback;
        raise exception 'Overdue Payment (No data found) %, %', SQLSTATE, SQLERRM;
--         raise notice 'Overdue Payment (No data found) %, %', SQLSTATE, SQLERRM;
    when others then
--         rollback;
        raise exception 'Overdue Payment (Others) %, %', SQLSTATE, SQLERRM;
--         raise notice 'Overdue Payment (Others) %, %', SQLSTATE, SQLERRM;
end;
$$;

alter procedure "LK".prc_overdue_payment() owner to "Billing";