create or replace function "LK".fn_deposit_info_tlmc()
    returns TABLE(cust_num character varying, dep_am numeric, dep_lia numeric, bank_guar_am numeric)
    language plpgsql
as
$$
BEGIN
    create temporary table dep_amount on commit drop as (select otr.customer_number,
                                                                sum(otr.amount) as dep_amount
                                                         From prx_open_transaction otr
                                                         where otr.deleted_by is null
                                                           and otr.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9'/*deposit*/
                                                         /*and otr.created_date >= (date_trunc('month', now()) + interval '-3 year')*/
                                                         group by otr.customer_number);

    create temporary table dep_liab on commit drop as
        (SELECT t.customer_number,
                sum(t.amount) dep_lia
         FROM prx_transaction t
         JOIN PRX_TRANSACTION_TYPE_COMBINATI trop ON trop.ID = t.TRANS_TYPE_COMBINATION_ID
         JOIN PRX_TRANSACTION_TYPE trt ON trt.ID = trop.TRANSACTION_TYPE_ID
         WHERE t.deleted_by IS NULL
           AND t.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9'
           AND (trt.ID = '7902fe57-9a18-35d3-4ab3-b593c1884a13' /*დარიცხვა*/
             OR t.TRANS_TYPE_COMBINATION_ID = '929493b4-d08e-b8ee-1b30-db5faead049f' /*დეპოზიტის დარიცხვის კორექტირება*/)
         GROUP BY t.customer_number);

    create temporary table bank_guar on commit drop as (SELECT tr.customer_number,
                                                               sum(tr.amount) bank_gua
                                                        FROM prx_transaction tr
                                                        WHERE tr.deleted_by is null
                                                          and tr.trans_type_combination_id = '1ee04290-b6c2-b075-5080-1a17336ec797'
                                                          AND tr.account_type_id = '3aeea7c5-6a36-a898-bc82-5a3923c6e9f9'
                                                        group by tr.customer_number);

    RETURN QUERY
        select da.customer_number,
               da.dep_amount,
               dl.dep_lia,
               bg.bank_gua
        from dep_amount da
        left join dep_liab dl on dl.customer_number = da.customer_number
        left join bank_guar bg on bg.customer_number = da.customer_number;

exception
    when others then
--         rollback;
        raise notice 'fn_deposit_info_tlmc Exception %', SQLERRM;
END ;
$$;

alter function "LK".fn_deposit_info_tlmc() owner to "Billing";

