create function prx_semeki_report(startdate date, enddate date)
    returns TABLE
            (
                miwodebistipi1       text,
                abonentisnomeri1     text,
                customername1        text,
                block1               numeric,
                bisnescentr1         text,
                saqmianoba1          text,
                operaciisdasaxeleba1 text,
                moxmarebisseqtori1   text,
                counter_number1      text,
                code1                text,
                start_killowat1      text,
                end_killowat1        text,
                tarifissafexuri1     text,
                simdzlavre1          text,
                operaciebi1          text,
                amount1              numeric,
                kv1                  numeric
            )
    language plpgsql
as
$$

BEGIN


    drop table if exists tem;
    CREATE temporary TABLE tem
    (
        miwodebistipi       text,
        abonentisnomeri     text,
        customerName        text,
        block               numeric,
        bisnescentri        text,
        saqmianoba          text,
        operaciisDasaxeleba text,
        --cast(t.created_date as date),
        moxmarebisseqtori   text,
        counter_number      text,
        code                text,
        start_killowat      text,
        end_killowat        text,
        tarifissafexuri     text,
        simdzlavre          text,
        operaciebi          text,
        amount              numeric,
        kv                  numeric
    );
    insert into tem(miwodebistipi,
                    abonentisnomeri,
                    customerName,
                    block,
                    bisnescentri,
                    saqmianoba,
                    operaciisDasaxeleba,
                    moxmarebisseqtori,
                    counter_number,
                    code,
                    start_killowat,
                    end_killowat,
                    tarifissafexuri,
                    simdzlavre,
                    operaciebi,
                    amount,
                    kv)

    select miwodebistipi,
           abonentisnomeri,
           regexp_replace(customerName, '[\x00-\x1F\x7F]', '', 'g') as customerName,
           block,
           bisnescentri,
           saqmianoba,
           operaciisDasaxeleba,
           --cast(t.created_date as date),
           moxmarebisseqtori,
           counter_number,
           code,
           start_killowat,
           end_killowat,
           tarifissafexuri,
           simdzlavre,
           operaciebi,
           sum(amount)                                              as amount,
           sum(kv)                                                  as kv
    from (select c.give_type                                                as miwodebistipi,
                 c.customer_number                                          as abonentisnomeri,
                 regexp_replace(c.customerName, '[\x00-\x1F\x7F]', '', 'g') as customerName,
                 st.block                                                   as block,
                 c.business_center                                          as bisnescentri,
                 c.activity                                                 as saqmianoba,
                 combi.subtypename                                          as operaciisDasaxeleba,
                 --cast(t.created_date as date),
                 c.category                                                 as moxmarebisseqtori,
                 t.counter_number,
                 st.code,
                 st.start_killowat                                          as start_killowat,
                 st.end_killowat                                            as end_killowat,
                 t.Step                                                     as tarifissafexuri,
                 st.voltage                                                 as simdzlavre,
                 combi.name                                                 as operaciebi,
                 sum(t.amount)                                              as amount,
                 sum(t.kilowatt_hour)                                       as kv
          from prx_transaction t
          join (select cc.customer_number as customer_number,
                       cc.name            as customerName,
                       gt.name            as give_Type,
                       bc.name            as business_center,
                       --cat.name    as category,
                       cat.fullcategory   as category,
                       ac.name            as activity,
                       cc.id,
                       categoryid
                from prx_customer cc
                left outer join prx_give_type gt on gt.id = cc.give_type_id and gt.deleted_by is null
                left outer join prx_business_center bc on bc.id = cc.business_center_id and bc.deleted_by is null
                    --left outer join prx_customer_category cat on cat.id = cc.category_id and cat.deleted_by is null
                left join  (select c.name as fullcategory, c.id as fullcategoryid, d.name as category, d.id as categoryid
                            from prx_customer_category c
                            left join prx_drs_category_item cc on c.id = cc.category_id
                            left join prx_drs_category d on d.id = cc.drs_category_id
                            where c.deleted_by is null) cat on cat.fullcategoryid = cc.category_id
                left outer join prx_activity ac on ac.id = cc.activity_id
                where cc.deleted_by is null) c on t.customer_id = c.id
          left join (select met.code,
                            tl.start_killowat,
                            tl.end_killowat,
                            met.voltage,
                            tl.step_number as Step,
                            block_index    as block
                     from prx_counter met
                     join prx_block b on b.id = met.block_id and b.deleted_by is null and met.deleted_by is null
                     left join  prx_tariff tr on tr.id = met.tariff_id and tr.deleted_by is null
                     join prx_tariff_line tl on tl.tariff_id = tr.id and tl.deleted_by is null
                     where met.deleted_by is null
                     order by met.code, tl.start_killowat) as st on extract(day from (DATE_TRUNC('MONTH', invoice_date::DATE) + INTERVAL '1 MONTH - 1 DAY')::DATE) !=
                       31 and t.counter_number = st.code  and abs(case when coalesce(t.kilowatt_hour, 0) = 0 then 1 else coalesce(t.kilowatt_hour, 0) end) >
                       st.start_killowat and abs(case when coalesce(t.kilowatt_hour, 0) = 0 then 1 else coalesce(t.kilowatt_hour, 0) end) <= st.end_killowat
                    and st.code is not null
          left outer join (select rc.combination_id, rc.group_code as name, v.subtypename
                           from PRX_REP_CON_TURN_OVER_BY_MONTH rc
                           join prx_transaction_type_combinati_vw v on v.id = rc.combination_id
                           where rc.use_main_report = true) as combi  on t.trans_type_combination_id = combi.combination_id
          where t.deleted_by is null
            and t.created_date::date between startDate and endDate
            and ( ((t.kilowatt_hour = 0 or t.kilowatt_hour is null) and (t.amount = 0 or t.amount is null) and
               t.cycle_type = 'CIRCULAR' and t.trans_type_combination_id != 'dac93a92-41eb-8905-7021-53f1f8d559b5')
                  or
              (t.kilowatt_hour != 0 and t.kilowatt_hour is not null and t.amount != 0 and t.amount is not null)              )
            and (t.step is not null or (t.step is null and categoryid not in ('b639fe3b-8f54-8265-094b-8836c7cf802e',
                                                                              'de39607a-e2c5-3fed-46cb-0fd5d6cfb76d',
                                                                              '65b97a21-336f-b9ee-a185-529f6cda0ee7')))
--and st.voltage!='0' and st.voltage is not null
          group by c.give_type, c.customer_number, c.customerName, c.business_center --, cast(t.created_date as Date)
                  , c.category, combi.name, combi.subtypename, c.activity,
                   t.counter_number, st.code, st.start_killowat, st.end_killowat, t.Step, st.voltage, st.block) tt
    group by miwodebistipi,
             abonentisnomeri,
             customerName,
             block,
             bisnescentri,
             saqmianoba,
             operaciisDasaxeleba,
             --cast(t.created_date as date),
             moxmarebisseqtori,
             counter_number,
             code,
             start_killowat,
             end_killowat,
             tarifissafexuri,
             simdzlavre,
             operaciebi;


    --31iani dajgufeba
-- union all
    drop table if exists tem1;
    CREATE temporary TABLE tem1
    (
        miwodebistipi       text,
        abonentisnomeri     text,
        customerName        text,
        block               numeric,
        bisnescentri        text,
        saqmianoba          text,
        operaciisDasaxeleba text,
        --cast(t.created_date as date),
        moxmarebisseqtori   text,
        counter_number      text,
        code                text,
        start_killowat      text,
        end_killowat        text,
        tarifissafexuri     text,
        simdzlavre          text,
        operaciebi          text,
        amount              numeric,
        kv                  numeric
    );
    insert into tem1(miwodebistipi,
                     abonentisnomeri,
                     customerName,
                     block,
                     bisnescentri,
                     saqmianoba,
                     operaciisDasaxeleba,
                     moxmarebisseqtori,
                     counter_number,
                     code,
                     start_killowat,
                     end_killowat,
                     tarifissafexuri,
                     simdzlavre,
                     operaciebi,
                     amount,
                     kv)
    select t.miwodebistipi,
           t.abonentisnomeri,
           regexp_replace(t.customerName, '[\x00-\x1F\x7F]', '', 'g') as customerName,
           t.block,
           t.bisnescentri,
           t.saqmianoba,
           t.operaciisDasaxeleba,
           --cast(t.created_date as date),
           t.moxmarebisseqtori,
           t.counter_number,
           t.code,
           t.start_killowat,
           t.end_killowat,
           t.tarifissafexuri,
           t.simdzlavre,
           t.operaciebi,
           t.amount                                                      amount,
           t.kv
    from (select miwodebistipi,
                 abonentisnomeri,
                 regexp_replace(customerName, '[\x00-\x1F\x7F]', '', 'g') as customerName,
                 block,
                 bisnescentri,
                 saqmianoba,
                 operaciisDasaxeleba,
                 --cast(t.created_date as date),
                 moxmarebisseqtori,
                 counter_number,
                 code,
                 start_killowat,
                 end_killowat,
                 tarifissafexuri,
                 simdzlavre,
                 operaciebi,
                 sum(amount)                                              as amount,
                 sum(kv)                                                  as kv
          from (select c.give_type                                                as miwodebistipi,
                       c.customer_number                                          as abonentisnomeri,
                       regexp_replace(c.customerName, '[\x00-\x1F\x7F]', '', 'g') as customerName,
                       st.block                                                   as block,
                       c.business_center                                          as bisnescentri,
                       c.activity                                                 as saqmianoba,
                       combi.subtypename                                          as operaciisDasaxeleba,
                       --cast(t.created_date as date),
                       c.category                                                 as moxmarebisseqtori,
                       t.counter_number,
                       st.code,
                       st.start_killowat                                          as start_killowat,
                       st.end_killowat                                            as end_killowat,
                       t.Step                                                     as tarifissafexuri,
                       st.voltage                                                 as simdzlavre,
                       combi.name                                                 as operaciebi,
                       sum(t.amount)                                              as amount,
                       sum(t.kilowatt_hour)                                       as kv
                from prx_transaction t
                join (select cc.customer_number as customer_number,
                             cc.name            as customerName,
                             gt.name            as give_Type,
                             bc.name            as business_center,
                             --cat.name    as category,
                             cat.fullcategory   as category,
                             ac.name            as activity,
                             cc.id,
                             categoryid
                      from prx_customer cc
                      left outer join prx_give_type gt on gt.id = cc.give_type_id and gt.deleted_by is null
                      left outer join prx_business_center bc on bc.id = cc.business_center_id and bc.deleted_by is null
                          --left outer join prx_customer_category cat on cat.id = cc.category_id and cat.deleted_by is null
                      left join  (select c.name as fullcategory, c.id as fullcategoryid, d.name as category, d.id as categoryid
                                  from prx_customer_category c
                                  left join prx_drs_category_item cc on c.id = cc.category_id
                                  left join prx_drs_category d on d.id = cc.drs_category_id
                                  where c.deleted_by is null) cat on cat.fullcategoryid = cc.category_id
                      left outer join prx_activity ac on ac.id = cc.activity_id
                      where cc.deleted_by is null) c on t.customer_id = c.id
                left join (select met.code,
                                  tl.start_killowat,
                                  tl.end_killowat,
                                  met.voltage,
                                  tl.step_number as Step,
                                  block_index    as block
                           from prx_counter met
                           join prx_block b on b.id = met.block_id and b.deleted_by is null and met.deleted_by is null
                           left join prx_tariff tr on tr.id = met.tariff_id and tr.deleted_by is null
                           join prx_tariff_line tl on tl.tariff_id = tr.id and tl.deleted_by is null
                           where met.deleted_by is null
                           order by met.code, tl.start_killowat) as st
                          on extract(day from
                                     (DATE_TRUNC('MONTH', invoice_date::DATE) + INTERVAL '1 MONTH - 1 DAY')::DATE) = 31
                                 and t.counter_number = st.code and abs(case when coalesce(t.kilowatt_hour / 31 * 30, 0) = 0
                                                                        then 1
                                                                    else coalesce(t.kilowatt_hour / 31 * 30, 0) end) >
                                                            st.start_killowat
                              and abs(case when coalesce(t.kilowatt_hour / 31 * 30, 0) = 0 then 1
                                          else coalesce(t.kilowatt_hour / 31 * 30, 0) end) <= st.end_killowat
                              and st.code is not null
                left outer join (select rc.combination_id, rc.group_code as name, v.subtypename
                                 from PRX_REP_CON_TURN_OVER_BY_MONTH rc
                                 join prx_transaction_type_combinati_vw v on v.id = rc.combination_id
                                 where rc.use_main_report = true) as combi
                                on t.trans_type_combination_id = combi.combination_id
                where t.deleted_by is null
                  and t.created_date::date between startDate and endDate
                  and (((t.kilowatt_hour = 0 or t.kilowatt_hour is null) and (t.amount = 0 or t.amount is null) and
                     t.cycle_type = 'CIRCULAR' and t.trans_type_combination_id != 'dac93a92-41eb-8905-7021-53f1f8d559b5')
                        or
                    (t.kilowatt_hour != 0 and t.kilowatt_hour is not null and t.amount != 0 and t.amount is not null))
                  and (t.step is not null or (t.step is null and categoryid not in
                                                                 ('b639fe3b-8f54-8265-094b-8836c7cf802e',
                                                                  'de39607a-e2c5-3fed-46cb-0fd5d6cfb76d',
                                                                  '65b97a21-336f-b9ee-a185-529f6cda0ee7')))
--and st.voltage!='0' and st.voltage is not null
                group by c.give_type, c.customer_number, c.customerName,
                         c.business_center, c.category, combi.name, combi.subtypename, c.activity,
                         t.counter_number, st.code, st.start_killowat, st.end_killowat, t.Step, st.voltage, st.block) tt
          group by miwodebistipi,
                   abonentisnomeri,
                   customerName,
                   block,
                   bisnescentri,
                   saqmianoba,
                   operaciisDasaxeleba,
                   --cast(t.created_date as date),
                   moxmarebisseqtori,
                   counter_number,
                   code,
                   start_killowat,
                   end_killowat,
                   tarifissafexuri,
                   simdzlavre,
                   operaciebi) t
    -- left join tem m on t.abonentisnomeri=m.abonentisnomeri and t.amount=m.amount and t.kv=m.kv
-- where m.abonentisnomeri is null
    ;


    --not 31 dajgufebis gareshe
-- union all
    drop table if exists tem2;
    CREATE temporary TABLE tem2
    (
        miwodebistipi       text,
        abonentisnomeri     text,
        customerName        text,
        block               numeric,
        bisnescentri        text,
        saqmianoba          text,
        operaciisDasaxeleba text,
        --cast(t.created_date as date),
        moxmarebisseqtori   text,
        counter_number      text,
        code                text,
        start_killowat      text,
        end_killowat        text,
        tarifissafexuri     text,
        simdzlavre          text,
        operaciebi          text,
        amount              numeric,
        kv                  numeric
    );
    insert into tem1(miwodebistipi,
                     abonentisnomeri,
                     customerName,
                     block,
                     bisnescentri,
                     saqmianoba,
                     operaciisDasaxeleba,
                     moxmarebisseqtori,
                     counter_number,
                     code,
                     start_killowat,
                     end_killowat,
                     tarifissafexuri,
                     simdzlavre,
                     operaciebi,
                     amount,
                     kv)
    select t.miwodebistipi,
           t.abonentisnomeri,
           regexp_replace(t.customerName, '[\x00-\x1F\x7F]', '', 'g') as customerName,
           t.block,
           t.bisnescentri,
           t.saqmianoba,
           t.operaciisDasaxeleba,
           --cast(t.created_date as date),
           t.moxmarebisseqtori,
           t.counter_number,
           t.code,
           t.start_killowat,
           t.end_killowat,
           t.tarifissafexuri,
           t.simdzlavre,
           t.operaciebi,
           t.amount                                                      amount,
           t.kv
    from (select miwodebistipi,
                 abonentisnomeri,
                 regexp_replace(customerName, '[\x00-\x1F\x7F]', '', 'g') as customerName,
                 block,
                 bisnescentri,
                 saqmianoba,
                 operaciisDasaxeleba,
                 --cast(t.created_date as date),
                 moxmarebisseqtori,
                 counter_number,
                 code,
                 start_killowat,
                 end_killowat,
                 tarifissafexuri,
                 simdzlavre,
                 operaciebi,
                 sum(amount)                                              as amount,
                 sum(kv)                                                  as kv
          from (select c.give_type                                                as miwodebistipi,
                       c.customer_number                                          as abonentisnomeri,
                       regexp_replace(c.customerName, '[\x00-\x1F\x7F]', '', 'g') as customerName,
                       st.block                                                   as block,
                       c.business_center                                          as bisnescentri,
                       c.activity                                                 as saqmianoba,
                       combi.subtypename                                          as operaciisDasaxeleba,
                       --cast(t.created_date as date),
                       c.category                                                 as moxmarebisseqtori,
                       t.counter_number,
                       st.code,
                       st.start_killowat                                          as start_killowat,
                       st.end_killowat                                            as end_killowat,
                       t.Step                                                     as tarifissafexuri,
                       st.voltage                                                 as simdzlavre,
                       combi.name                                                 as operaciebi,
                       t.amount                                                   as amount,
                       t.kilowatt_hour                                            as kv
                from prx_transaction t
                join (select cc.customer_number as customer_number,
                             cc.name            as customerName,
                             gt.name            as give_Type,
                             bc.name            as business_center,
                             --cat.name    as category,
                             cat.fullcategory   as category,
                             ac.name            as activity,
                             cc.id,
                             categoryid
                      from prx_customer cc
                      left outer join prx_give_type gt on gt.id = cc.give_type_id and gt.deleted_by is null
                      left outer join prx_business_center bc on bc.id = cc.business_center_id and bc.deleted_by is null
                          --left outer join prx_customer_category cat on cat.id = cc.category_id and cat.deleted_by is null
                      left join
                      (select c.name as fullcategory, c.id as fullcategoryid, d.name as category, d.id as categoryid
                       from prx_customer_category c
                       left join prx_drs_category_item cc on c.id = cc.category_id
                       left join prx_drs_category d on d.id = cc.drs_category_id
                       where c.deleted_by is null) cat on cat.fullcategoryid = cc.category_id
                      left outer join prx_activity ac on ac.id = cc.activity_id
                      where cc.deleted_by is null) c on t.customer_id = c.id
                left join (select met.code,
                                  tl.start_killowat,
                                  tl.end_killowat,
                                  met.voltage,
                                  tl.step_number as Step,
                                  block_index    as block
                           from prx_counter met
                           join prx_block b on b.id = met.block_id and b.deleted_by is null and met.deleted_by is null
                           left join
                           prx_tariff tr on tr.id = met.tariff_id and tr.deleted_by is null
                           join
                           prx_tariff_line tl on tl.tariff_id = tr.id and tl.deleted_by is null
                           where met.deleted_by is null

                           order by met.code, tl.start_killowat) as st
                          on extract(day from
                                     (DATE_TRUNC('MONTH', invoice_date::DATE) + INTERVAL '1 MONTH - 1 DAY')::DATE) !=
                             31 and
                             t.counter_number = st.code and abs(case
                                                                    when coalesce(t.kilowatt_hour, 0) = 0 then 1
                                                                    else coalesce(t.kilowatt_hour, 0) end) >
                                                            st.start_killowat
                              and abs(case
                                          when coalesce(t.kilowatt_hour, 0) = 0 then 1
                                          else coalesce(t.kilowatt_hour, 0) end) <= st.end_killowat
                              and st.code is not null
                left outer join (select rc.combination_id, rc.group_code as name, v.subtypename
                                 from PRX_REP_CON_TURN_OVER_BY_MONTH rc
                                 join prx_transaction_type_combinati_vw v on v.id = rc.combination_id
                                 where rc.use_main_report = true) as combi
                                on t.trans_type_combination_id = combi.combination_id
                where t.deleted_by is null
                  and t.created_date::date between startDate and endDate
                  and (
                    ((t.kilowatt_hour = 0 or t.kilowatt_hour is null) and (t.amount = 0 or t.amount is null) and
                     t.cycle_type = 'CIRCULAR'
                        and t.trans_type_combination_id != 'dac93a92-41eb-8905-7021-53f1f8d559b5'
                        )
                        or
                    (t.kilowatt_hour != 0 and t.kilowatt_hour is not null and t.amount != 0 and t.amount is not null)
                    )
                  and ((t.step is not null or t.step <> 0) and categoryid in ('b639fe3b-8f54-8265-094b-8836c7cf802e',
                                                                              'de39607a-e2c5-3fed-46cb-0fd5d6cfb76d',
                                                                              '65b97a21-336f-b9ee-a185-529f6cda0ee7'))) tt
          group by miwodebistipi,
                   abonentisnomeri,
                   customerName,
                   block,
                   bisnescentri,
                   saqmianoba,
                   operaciisDasaxeleba,
                   --cast(t.created_date as date),
                   moxmarebisseqtori,
                   counter_number,
                   code,
                   start_killowat,
                   end_killowat,
                   tarifissafexuri,
                   simdzlavre,
                   operaciebi) t
    -- left join tem m on t.abonentisnomeri=m.abonentisnomeri and t.amount=m.amount and t.kv=m.kv
-- left join tem1 m1 on t.abonentisnomeri=m1.abonentisnomeri and t.amount=m1.amount and t.kv=m.kv
-- where m.abonentisnomeri is null and m1.abonentisnomeri is null
    ;


    --31iani dajgufebis gareshe
-- union all
    drop table if exists tem3;
    CREATE temporary TABLE tem3
    (
        miwodebistipi       text,
        abonentisnomeri     text,
        customerName        text,
        block               numeric,
        bisnescentri        text,
        saqmianoba          text,
        operaciisDasaxeleba text,
        --cast(t.created_date as date),
        moxmarebisseqtori   text,
        counter_number      text,
        code                text,
        start_killowat      text,
        end_killowat        text,
        tarifissafexuri     text,
        simdzlavre          text,
        operaciebi          text,
        amount              numeric,
        kv                  numeric
    );
    insert into tem3(miwodebistipi,
                     abonentisnomeri,
                     customerName,
                     block,
                     bisnescentri,
                     saqmianoba,
                     operaciisDasaxeleba,
                     moxmarebisseqtori,
                     counter_number,
                     code,
                     start_killowat,
                     end_killowat,
                     tarifissafexuri,
                     simdzlavre,
                     operaciebi,
                     amount,
                     kv)
    select t.miwodebistipi,
           t.abonentisnomeri,
           regexp_replace(t.customerName, '[\x00-\x1F\x7F]', '', 'g') as customerName,
           t.block,
           t.bisnescentri,
           t.saqmianoba,
           t.operaciisDasaxeleba,
           --cast(t.created_date as date),
           t.moxmarebisseqtori,
           t.counter_number,
           t.code,
           t.start_killowat,
           t.end_killowat,
           t.tarifissafexuri,
           t.simdzlavre,
           t.operaciebi,
           t.amount                                                      amount,
           t.kv
    from (select miwodebistipi,
                 abonentisnomeri,
                 regexp_replace(customerName, '[\x00-\x1F\x7F]', '', 'g') as customerName,
                 block,
                 bisnescentri,
                 saqmianoba,
                 operaciisDasaxeleba,
                 --cast(t.created_date as date),
                 moxmarebisseqtori,
                 counter_number,
                 code,
                 start_killowat,
                 end_killowat,
                 tarifissafexuri,
                 simdzlavre,
                 operaciebi,
                 sum(amount)                                              as amount,
                 sum(kv)                                                  as kv
          from (select c.give_type                                                as miwodebistipi,
                       c.customer_number                                          as abonentisnomeri,
                       regexp_replace(c.customerName, '[\x00-\x1F\x7F]', '', 'g') as customerName,
                       st.block                                                   as block,
                       c.business_center                                          as bisnescentri,
                       c.activity                                                 as saqmianoba,
                       combi.subtypename                                          as operaciisDasaxeleba,
                       --cast(t.created_date as date),
                       c.category                                                 as moxmarebisseqtori,
                       t.counter_number,
                       st.code,
                       st.start_killowat                                          as start_killowat,
                       st.end_killowat                                            as end_killowat,
                       t.Step                                                     as tarifissafexuri,
                       st.voltage                                                 as simdzlavre,
                       combi.name                                                 as operaciebi,
                       t.amount                                                   as amount,
                       t.kilowatt_hour                                            as kv
                from prx_transaction t
                join (select cc.customer_number as customer_number,
                             cc.name            as customerName,
                             gt.name            as give_Type,
                             bc.name            as business_center,
                             --cat.name    as category,
                             cat.fullcategory   as category,
                             ac.name            as activity,
                             cc.id,
                             categoryid
                      from prx_customer cc
                      left outer join prx_give_type gt on gt.id = cc.give_type_id and gt.deleted_by is null
                      left outer join prx_business_center bc on bc.id = cc.business_center_id and bc.deleted_by is null
                          --left outer join prx_customer_category cat on cat.id = cc.category_id and cat.deleted_by is null
                      left join
                      (select c.name as fullcategory, c.id as fullcategoryid, d.name as category, d.id as categoryid
                       from prx_customer_category c
                       left join prx_drs_category_item cc on c.id = cc.category_id
                       left join prx_drs_category d on d.id = cc.drs_category_id
                       where c.deleted_by is null) cat on cat.fullcategoryid = cc.category_id
                      left outer join prx_activity ac on ac.id = cc.activity_id
                      where cc.deleted_by is null) c on t.customer_id = c.id
                left join (select met.code,
                                  tl.start_killowat,
                                  tl.end_killowat,
                                  met.voltage,
                                  tl.step_number as Step,
                                  block_index    as block
                           from prx_counter met
                           join prx_block b on b.id = met.block_id and b.deleted_by is null and met.deleted_by is null
                           left join
                           prx_tariff tr on tr.id = met.tariff_id and tr.deleted_by is null
                           join
                           prx_tariff_line tl on tl.tariff_id = tr.id and tl.deleted_by is null
                           where met.deleted_by is null

                           order by met.code, tl.start_killowat) as st
                          on extract(day from
                                     (DATE_TRUNC('MONTH', invoice_date::DATE) + INTERVAL '1 MONTH - 1 DAY')::DATE) =
                             31 and
                             t.counter_number = st.code and abs(case
                                                                    when coalesce(t.kilowatt_hour / 31 * 30, 0) = 0
                                                                        then 1
                                                                    else coalesce(t.kilowatt_hour / 31 * 30, 0) end) >
                                                            st.start_killowat
                              and abs(case
                                          when coalesce(t.kilowatt_hour / 31 * 30, 0) = 0 then 1
                                          else coalesce(t.kilowatt_hour / 31 * 30, 0) end) <= st.end_killowat
                              and st.code is not null
                left outer join (select rc.combination_id, rc.group_code as name, v.subtypename
                                 from PRX_REP_CON_TURN_OVER_BY_MONTH rc
                                 join prx_transaction_type_combinati_vw v on v.id = rc.combination_id
                                 where rc.use_main_report = true) as combi
                                on t.trans_type_combination_id = combi.combination_id
                where t.deleted_by is null
                  and t.created_date::date between startDate and endDate
                  and (
                    ((t.kilowatt_hour = 0 or t.kilowatt_hour is null) and (t.amount = 0 or t.amount is null) and
                     t.cycle_type = 'CIRCULAR'
                        and t.trans_type_combination_id != 'dac93a92-41eb-8905-7021-53f1f8d559b5'
                        )
                        or
                    (t.kilowatt_hour != 0 and t.kilowatt_hour is not null and t.amount != 0 and t.amount is not null)
                    )
                  and ((t.step is null or t.step = 0) and categoryid in ('b639fe3b-8f54-8265-094b-8836c7cf802e',
                                                                         'de39607a-e2c5-3fed-46cb-0fd5d6cfb76d',
                                                                         '65b97a21-336f-b9ee-a185-529f6cda0ee7'))) tt

          group by miwodebistipi,
                   abonentisnomeri,
                   customerName,
                   block,
                   bisnescentri,
                   saqmianoba,
                   operaciisDasaxeleba,
                   --cast(t.created_date as date),
                   moxmarebisseqtori,
                   counter_number,
                   code,
                   start_killowat,
                   end_killowat,
                   tarifissafexuri,
                   simdzlavre,
                   operaciebi) t
    -- left join tem m on t.abonentisnomeri=m.abonentisnomeri and t.amount=m.amount and t.kv=m.kv
-- left join tem1 m1 on t.abonentisnomeri=m1.abonentisnomeri and t.amount=m1.amount and t.kv=m.kv
-- left join tem2 m2 on t.abonentisnomeri=m2.abonentisnomeri and t.amount=m2.amount and t.kv=m.kv
-- where m.abonentisnomeri is null and m1.abonentisnomeri is null and m2.abonentisnomeri is null
    ;

    -- delete from tem where abonentisnomeri in
-- (select abonentisnomeri  from tem
--     group by abonentisnomeri
-- having count(*)>1) and code is null;

    drop table if exists tem4;
    CREATE temporary TABLE tem4
    (
        miwodebistipi       text,
        abonentisnomeri     text,
        customerName        text,
        block               numeric,
        bisnescentri        text,
        saqmianoba          text,
        operaciisDasaxeleba text,
        --cast(t.created_date as date),
        moxmarebisseqtori   text,
        counter_number      text,
        code                text,
        start_killowat      text,
        end_killowat        text,
        tarifissafexuri     text,
        simdzlavre          text,
        operaciebi          text,
        amount              numeric,
        kv                  numeric
    );
    insert into tem4(miwodebistipi,
                     abonentisnomeri,
                     customerName,
                     block,
                     bisnescentri,
                     saqmianoba,
                     operaciisDasaxeleba,
                     moxmarebisseqtori,
                     counter_number,
                     code,
                     start_killowat,
                     end_killowat,
                     tarifissafexuri,
                     simdzlavre,
                     operaciebi,
                     amount,
                     kv)
    select distinct miwodebistipi:: text,
                    abonentisnomeri:: text,
                    customerName:: text,
                    block ::numeric,
                    bisnescentri ::text,
                    saqmianoba :: text,
                    operaciisDasaxeleba :: text,
                    --cast(t.created_date as date),
                    moxmarebisseqtori :: text,
                    counter_number :: text,
                    code :: text,
                    start_killowat ::text,
                    end_killowat ::text,
                    tarifissafexuri ::text,
                    simdzlavre ::text,
                    operaciebi ::text,
                    amount ::numeric,
                    kv ::numeric
    from (select *
          from tem
          union all
          select t.*
          from tem1 t
          left join tem m on t.abonentisnomeri = m.abonentisnomeri
          --and t.amount=m.amount and t.kv=m.kv
          where m.abonentisnomeri is null
          union all
          select t.*
          from tem2 t
          left join tem m on t.abonentisnomeri = m.abonentisnomeri
              --and t.amount=m.amount and t.kv=m.kv
          left join tem1 m1 on t.abonentisnomeri = m1.abonentisnomeri
          --and t.amount=m1.amount and t.kv=m.kv
          where m.abonentisnomeri is null
            and m1.abonentisnomeri is null
          union all
          select t.*
          from tem3 t
          left join tem m on t.abonentisnomeri = m.abonentisnomeri
              --and t.amount=m.amount and t.kv=m.kv
          left join tem1 m1 on t.abonentisnomeri = m1.abonentisnomeri
              --and t.amount=m1.amount and t.kv=m.kv
          left join tem2 m2 on t.abonentisnomeri = m2.abonentisnomeri
          --and t.amount=m2.amount and t.kv=m.kv
          where m.abonentisnomeri is null
            and m1.abonentisnomeri is null
            and m2.abonentisnomeri is null) tt;

    delete
    from tem4
    where abonentisnomeri in
          (select abonentisnomeri
           from tem4
           group by abonentisnomeri, amount, kv, operaciebi, counter_number, start_killowat, end_killowat,
                    tarifissafexuri, simdzlavre
           having count(*) > 1)
      and code is null;

    return query
        select distinct miwodebistipi:: text,
                        abonentisnomeri:: text,
                        customerName:: text,
                        block ::numeric,
                        bisnescentri ::text,
                        saqmianoba :: text,
                        operaciisDasaxeleba :: text,
                        --cast(t.created_date as date),
                        moxmarebisseqtori :: text,
                        counter_number :: text,
                        code :: text,
                        start_killowat ::text,
                        end_killowat ::text,
                        tarifissafexuri ::text,
                        simdzlavre ::text,
                        operaciebi ::text,
                        amount ::numeric,
                        kv ::numeric
        from tem4;


END;
$$;

alter function prx_semeki_report(date, date) owner to "Billing";
