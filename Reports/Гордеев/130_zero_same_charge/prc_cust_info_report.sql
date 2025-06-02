create or replace procedure "LK".prc_cust_info_report(IN p_period text)--one update after all cte-s
    language plpgsql
as
$$
begin
    raise  notice 'cust begin';
    with cust as (select distinct cc.customer_number,
           regexp_replace(COALESCE(cc.name::text, ''), '[\x00-\x1F\x7F]', '', 'g') cust_name,
           cat.name cat,
           act.name act,
           bc.name bc,
           regexp_replace(COALESCE(cc.address_text::text, ''), '[\x00-\x1F\x7F]', '', 'g') adr,
           st.name stat
    from prx_customer cc
    join  "LK".lk_charge_zero_same_report zsc on cc.customer_number = zsc.customer_number
    join prx_status st on st.id = cc.status_id
    join prx_business_center bc on bc.id = cc.business_center_id
    join prx_customer_category cat on cat.id = cc.category_id
    left join prx_activity act on act.id = cc.activity_id
         where cc.deleted_by is null
           and bc.deleted_by is null
           and cat.deleted_by is null
           and st.deleted_by is null
           and cc.create_date <= date_trunc('day', now()) - interval '6 months')
--შეიძლება cteების გაერთიანება, Join და მერე Update!!
    update "LK".lk_charge_zero_same_report zc
    set customer_name = c.cust_name,
        category = c.cat,
        activity = c.act,
        address = c.adr,
        business_center = c.bc,
        status = c.stat
    from cust c
    where c.customer_number = zc.customer_number;

    with dz as (select customer_number,
                       davalianebaamount
                from prx_debtor_balance_report r /*prx_currentbalancenew1_vw*/
                where r.period_ = p_period and coalesce(davalianebaamount, 0)!=0
                  and r.customer_number not in ('6016601', '7160190', '5015501'))

    update "LK".lk_charge_zero_same_report zc
    set dz = davalianebaamount
    from dz d
    where d.customer_number = zc.customer_number;

raise  notice 'dz';
    with metQua as (select cu.customer_number,
                           count(met.id) met_qua
                    from prx_counter met
                    inner join prx_customer cu on cu.cust_key = met.cust_key
                    where met.deleted_by is null
                    group by cu.customer_number)

    update "LK".lk_charge_zero_same_report zc
    set metter_quantity = mq.met_qua
    from metQua mq
    where mq.customer_number = zc.customer_number;

raise notice 'metQua';
    with cutHist as (select c.customer_number,
                            c.operationtype,
                            c.reason reas
                     from (select ch.customer_number,
                                  ch.operationtype,
                                  case
                                      when ch.gwp then 'GWP'
                                      when ch.telmico then 'Telmico'
                                      when ch.trash then 'Trash'
                                      end                                                                        reason,
                                  row_number() over (partition by ch.customer_number order by ch.mark_date desc) rn
                           from "LK".lk_cut_history_vw ch
                           where ch.create_date <= (date_trunc('day'::text, now()) - '6 mons'::interval)) c
                     where rn = 1)

    update "LK".lk_charge_zero_same_report zc
    set operation_telasi = ch.operationtype,
        reason           = ch.reas
    from cutHist ch
    where ch.customer_number = zc.customer_number;
raise notice 'cutHist';

    with cutQua as (select cu.customer_number,
                           cut.cut_qua
                    from (select customer_id,
                                 sum(cut) cut_qua
                          from (select ccut.customer_id,
                                       count(ccut.customer_id) cut
                                from prx_customer_cutoff ccut
                                where ccut.created_date between DATE_TRUNC('MONTH', now() - INTERVAL '6 MONTH')
                                    and (DATE_TRUNC('MONTH', now()) + INTERVAL '1 MONTH' - INTERVAL '1 DAY')
                                  and ccut.deleted_by is null
                                group by ccut.customer_id
                                union
                                select icut.customer_id,
                                       count(icut.customer_id)
                                from prx_Individual_Cutoff icut
                                where icut.created_date between DATE_TRUNC('MONTH', now() - INTERVAL '6 MONTH')
                                    and (DATE_TRUNC('MONTH', now()) + INTERVAL '1 MONTH' - INTERVAL '1 DAY')
                                  and icut.deleted_by is null
                                group by icut.customer_id) cq
                          group by customer_id) cut
                    join prx_customer cu on cu.id = cut.customer_id
                    where cu.deleted_by is null)

    update "LK".lk_charge_zero_same_report zc
    set cut_quantity = cq.cut_qua
    from cutQua cq
    where cq.customer_number = zc.customer_number;
raise notice 'cutQua';

    with reconQua as (select cu.customer_number,
                             rec.recon_qua
                      from (select customer_id,
                                   sum(rec_qua) recon_qua
                            from (select crec.customer_id,
                                         count(crec.customer_id) rec_qua
                                  from prx_Customer_Reconnection crec
                                  where crec.created_date between DATE_TRUNC('MONTH', now() - INTERVAL '6 MONTH')
                                      and (DATE_TRUNC('MONTH', now()) + INTERVAL '1 MONTH' - INTERVAL '1 DAY')
                                    and crec.deleted_by is null
                                  group by crec.customer_id
                                  union
                                  select irec.customer_id,
                                         count(irec.customer_id)
                                  from prx_Individual_Reconnection irec
                                  where irec.created_date between DATE_TRUNC('MONTH', now() - INTERVAL '6 MONTH')
                                      and (DATE_TRUNC('MONTH', now()) + INTERVAL '1 MONTH' - INTERVAL '1 DAY')
                                    and irec.deleted_by is null
                                  group by irec.customer_id) cq
                            group by customer_id) rec
                      join prx_customer cu on cu.id = rec.customer_id
                      where cu.deleted_by is null)

    update "LK".lk_charge_zero_same_report zc
    set connect_quantity = rq.recon_qua
    from reconQua rq
    where rq.customer_number = zc.customer_number;

raise notice 'reconQua';

exception
    when no_data_found then
        raise notice 'CustInfo Exception (No data found) %, %', SQLSTATE, SQLERRM;
        rollback;
    when others then
        raise notice 'CustInfo Exception (Others) %, %', SQLSTATE, SQLERRM;
        rollback;
end;
$$;

alter procedure "LK".prc_cust_info_report(text) owner to "Billing";