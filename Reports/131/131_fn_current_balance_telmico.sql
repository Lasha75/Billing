create or replace function "LK".fn_current_balance_tlmc()
    returns TABLE
            (
                cust_num character varying,
                cur_bal  numeric,
                old_am   numeric
            )
    language plpgsql
as
$$
BEGIN
    drop table if exists cur_amount;
    drop table if exists old_amount;

    create temporary table cur_amount on commit drop as (select customer_number,
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
                            AND otr.trans_date >= (now()::DATE - INTERVAL '3 year')
                          group by otr.customer_number
                          union
                          SELECT o.customer_number,
                                 sum(coalesce(o.amount, 0))
                          FROM prx_open_transaction o
                          WHERE o.deleted_by IS NULL
                            AND o.trans_date < (now()::DATE - INTERVAL '3 year')
                            AND coalesce(o.amount, 0) < 0
                          GROUP BY o.customer_number) am
                    group by customer_number);

    create temporary table old_amount on commit drop as (SELECT o.customer_number,
                                                                sum(coalesce(o.amount, 0)) old_amount
                    FROM prx_open_transaction o
                    WHERE o.deleted_by IS NULL
                      AND o.trans_date < (now()::DATE - INTERVAL '3 year')
                      AND coalesce(o.amount, 0)> 0
                    GROUP BY o.customer_number);

    RETURN QUERY
        select coalesce(ca.customer_number, oa.customer_number) cust,
               amount,
               oa.old_amount
        from cur_amount ca
        full join old_amount oa on oa.customer_number = ca.customer_number;

exception
    when others then
--         rollback;
        raise notice 'fn_current_balance_tlmc Exception %', SQLERRM; -- notice - execution continues, exception - execution stops and tran rolled back
END ;
$$;

alter function "LK".fn_current_balance_tlmc() owner to "Billing";