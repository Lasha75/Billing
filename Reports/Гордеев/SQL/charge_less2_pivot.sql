truncate table "LK".lk_less_two_charge_report restart identity;


create temporary table charge on commit drop as (select tr.counter_serial_number                                                 ,
                                                        tr.counter_number                                       met_num,
                                                        tr.customer_number                                                       cust_num,
                                                        tr.created_date,
                                                        tr.kilowatt_hour                                                         kwt,
                                                        ROW_NUMBER() OVER (PARTITION BY tr.counter_serial_number ORDER BY tr.created_date) AS rn
                                                 from prx_transaction tr
                                                 where tr.created_date::date between CURRENT_DATE - INTERVAL '3 years' and now()
                                                   and tr.deleted_by is null
                                                   and tr.kilowatt_hour <= 2 and tr.customer_number='3235528'
                                                   and tr.trans_type_combination_id = 'de579ca8-118d-0f99-1012-c2e6b3a02307');
create temporary table dt on commit drop as
    (SELECT *
     FROM (SELECT met_num,
                  cust_num,
                  kwt,
                  created_date,
                  SUM(aa.kwt) OVER (PARTITION BY aa.met_num ORDER BY aa.rn rows BETWEEN 2 PRECEDING and CURRENT ROW)             AS prev2_charge,
                  SUM(aa.kwt) OVER (PARTITION BY aa.met_num ORDER BY aa.rn rows BETWEEN CURRENT ROW and 1 FOLLOWING)             AS next1_charge,
                  SUM(aa.kwt) OVER (PARTITION BY aa.met_num ORDER BY aa.rn rows BETWEEN CURRENT ROW AND 2 FOLLOWING)             AS next2_charge,
                  COUNT(*) OVER (PARTITION BY aa.met_num ORDER BY aa.rn rows BETWEEN 2 PRECEDING AND CURRENT ROW)               AS prev_rows
           FROM (SELECT ch.met_num,
                        ch.kwt,
                        ch.cust_num,
                        ch.created_date,
                        ROW_NUMBER() OVER (PARTITION BY ch.met_num ORDER BY created_date) rn
                 FROM charge ch
                 JOIN (SELECT ch1.met_num,
                              COUNT(*)
                       FROM charge ch1
                       WHERE ch1.kwt = 0
                       GROUP BY ch1.met_num
                       HAVING COUNT(*) >= 3) wz ON wz.met_num = ch.met_num) aa) mm
     WHERE mm.kwt <= 2
       AND mm.prev2_charge > 0 /*=*/
       AND mm.next1_charge <= 2
       AND mm.next2_charge - next1_charge <= 2
       AND mm.prev_rows > 2);

create temporary table bal_tlmc on commit drop as (select * from "LK".fn_current_balance_tlmc() where cur_bal > 0);
create temporary table cust_info on commit drop as (select cu.customer_number,
                                                           regexp_replace(COALESCE(cu.name, ''), '[\x00-\x1F\x7F]', '', 'g') cust_nam,
                                                           cat.name                                                          cat,
                                                           act.name                                                          act,
                                                           regexp_replace(COALESCE(cu.address_text, ''), '[\x00-\x1F\x7F]', '', 'g')                                               addr,
                                                           bc.name                                                           bc,
                                                           cu.created_date                                                   crda,
                                                           st.name                                                           stat,
                                                           ch.op_tls,
                                                           ch.reas
                                                    from prx_customer cu
                                                    join public.prx_status st on cu.status_id = st.id
                                                    join public.prx_customer_category cat on cu.category_id = cat.id
                                                    left join public.prx_business_center bc on bc.id = cu.business_center_id
                                                    left join public.prx_activity act on cu.activity_id = act.id
                                                    left join (select c.customer_number,
                                                                      c.operationtype op_tls,
                                                                      c.reas
                                                               from (select ch.customer_number,
                                                                            ch.operationtype,
                                                                            case
                                                                                when ch.gwp then 'GWP'
                                                                                when ch.telmico then 'Telmico'
                                                                                when ch.trash then 'Trash'
                                                                                end                                                           reas,
                                                                            row_number()
                                                                            over (partition by ch.customer_number order by ch.mark_date desc) rn
                                                                     from "LK".lk_cut_history_vw ch) c
                                                               where rn = 1) ch
                                                              on ch.customer_number = cu.customer_number
                                                    where cu.deleted_by is null);

insert into "LK".lk_less_two_charge_report (id, met_number, cust_number, cust_name, categ, activity, address, bc,
                                     cust_create_date, cust_status, tls_operation, cut_reason, curr_bal_tlmc,  "07-2021",
                                     "08-2021", "09-2021", "10-2021" )
select met_num,
             cust_num,
             cust_nam,
             cat,
             act,
             addr,
             bc,
             crda,
             stat,
             op_tls,
             reas,
             dz,
             null,
             null,
             null,
             null
from (SELECT dt.met_num,
             dt.cust_num,
             ci.cust_nam,
             ci.cat,
             ci.act,
             ci.addr,
             ci.bc,
             ci.crda,
             ci.stat,
             ci.op_tls,
             ci.reas,
             dz.cur_bal                                  dz,
             row_number() over (partition by dt.met_num) rn
      FROM dt
      left join bal_tlmc dz on dz.cust_num = dt.cust_num
      join cust_info ci on ci.customer_number = dt.cust_num) dd
where rn = 1;

--monthly charge
select *
from crosstab($$select distinct tr.customer_number,
                       lpad(cast(extract(month from tr.created_date) as  text), 2,'0') ||'-'||extract(year from tr.created_date),
                      tr.kilowatt_hour
                     from prx_transaction tr
                      where tr.created_date::date between '01-jul-2021' and now()
                        and tr.deleted_by is null and tr.trans_type_combination_id = 'de579ca8-118d-0f99-1012-c2e6b3a02307'
    order by 1,2 $$,
              $$
                 SELECT to_char(date_trunc('month', dd), 'MM-YYYY') AS month_year
                    FROM generate_series('2021-07-01'::timestamp, CURRENT_DATE, '1 month') dd
            $$
     ) as ch (cust_num text, "07-2021" text, "08-2021" text, "09-2021" text, "10-2021" text, "11-2021" text,
              "12-2021" text, "01-2022" text, "02-2022" text, "03-2022" text, "04-2022" text, "05-2022" text,
              "06-2022" text, "07-2022" text, "08-2022" text, "09-2022" text, "10-2022" text, "11-2022" text, "12-2022" text,
              "01-2023" text, "02-2023" text, "03-2023" text, "04-2023" text, "05-2023" text, "06-2023" text,
              "07-2023" text, "08-2023" text, "09-2023" text, "10-2023" text, "11-2023" text, "12-2023" text,
              "01-2024" text, "02-2024" text, "03-2024" text, "04-2024" text, "05-2024" text, "06-2024" text,
              "07-2024" text, "08-2024" text, "09-2024" text, "10-2024" text);


/*
WITH charge AS (SELECT
                FROM (select tr.counter_serial_number                                                              met_num,
                             tr.customer_number                                                                    cust_num,
                             tr.created_date,
                             tr.kilowatt_hour                                                                      kwt,
                             ROW_NUMBER() OVER (PARTITION BY tr.counter_serial_number ORDER BY tr.created_date) AS rn
                      from prx_transaction tr
                      where tr.created_date::date between '01-jul-2021' and now()
                        and tr.deleted_by is null
                        and tr.trans_type_combination_id = 'de579ca8-118d-0f99-1012-c2e6b3a02307') ch
                where coalesce(kwt, 0) <= 2),
     last_zero_charge_date AS (SELECT met_num,
                                      MAX(rn) zero_date,
                                      rn
                               FROM charge
                               WHERE kwt = 0
                               GROUP BY met_num,
                                        rn),

    last_zero_date AS
 (SELECT d1.ab_no,
         MAX(d1.rw) AS rw
    FROM dt d1
    JOIN (SELECT x.ab_no,  rw,
                SUM(x.charge) OVER(PARTITION BY x.ab_no ORDER BY x.rw BETWEEN CURRENT ROW AND 2 PRECEDING) AS total_charge
           FROM dt x
          WHERE x.charge = 0
         ) z3
      ON d1.ab_no = z3.ab_no
     AND d1.rw = z3.rw
   WHERE dt1.charge = 0
     AND z3.total_charge = 0
   GROUP BY d1.ab_no),


     before_zero AS (SELECT ch.met_num,
                           COUNT(*) ch_bef_cnt
                    FROM charge ch
                    JOIN last_zero_charge_date zc
                         ON ch.met_num = zc.met_num AND ch.rn <= zc.rn AND ch.rn >= zc.rn - 2 AND ch.kwt = 0
                    GROUP BY ch.met_num),
     after_zero AS (SELECT ch.met_num,
                           COUNT(*) ch_aft_cnt
                    FROM charge ch
                    JOIN last_zero_charge_date zc
                         ON ch.met_num = zc.met_num AND ch.rn > zc.rn and ch.rn <= zc.rn + 2 AND ch.kwt > 0
                    GROUP BY ch.met_num),
    bal_tlmc as (select * from "LK".fnc_current_balance_tlmc()),
    cust_info as (select cu.customer_number,
                         regexp_replace(COALESCE(cu.name, ''), '[\x00-\x1F\x7F]', '', 'g')         cust_name,
                         cat.name                                                                  cat,
                         act.name                                                                  act,
                         regexp_replace(COALESCE(cu.address_text, ''), '[\x00-\x1F\x7F]', '', 'g') address,
                         bc.name                                                                   bc,
                         cu.created_date                                                           crda,
                         st.name                                                                   stat,
                         ch.operationtype,
                         ch.reas
                  from prx_customer cu
                  join public.prx_status st on cu.status_id = st.id
                  join public.prx_customer_category cat on cu.category_id = cat.id
                  left join public.prx_business_center bc on bc.id = cu.business_center_id
                  left join public.prx_activity act on cu.activity_id = act.id
                  left join (select c.customer_number,
                                    c.operationtype,
                                    c.reason reas
                             from (select ch.customer_number,
                                          ch.operationtype,
                                          case
                                              when ch.gwp then 'GWP'
                                              when ch.telmico then 'Telmico'
                                              when ch.trash then 'Trash'
                                              end                                                           reason,
                                          row_number()
                                          over (partition by ch.customer_number order by ch.mark_date desc) rn
                                   from "LK".lk_cut_history_vw ch) c
                             where rn = 1) ch on ch.customer_number = cu.customer_number
                  where cu.deleted_by is null)

SELECT ch.met_num,
       ci.customer_number,
        ci.cust_name,
       ci.cat,
       ci.act,
       ci.address,
       ci.bc,
       ci.crda,
       ci.stat,
       ci.operationtype,
       ci.reas,
       dz.cur_bal
FROM before_zero bz
JOIN after_zero az ON bz.met_num = az.met_num
left join charge ch on ch.met_num = bz.met_num
left join cust_info ci on ci.customer_number = ch.cust_num
left join bal_tlmc dz on dz.cust_num = ci.customer_number
WHERE az.ch_aft_cnt >= 3
  AND bz.ch_bef_cnt >= 2;*/

/*WITH cur_dt AS (select tr.counter_serial_number                                                              met_numb,
                       tr.customer_number,
                       extract(year from tr.created_date)                                                    cur_yr,
                       extract(month from tr.created_date)                                                   cur_mn,
                       tr.created_date,
                       ROW_NUMBER() OVER (PARTITION BY tr.counter_serial_number ORDER BY tr.created_date) AS rn
                from prx_transaction tr
                where tr.created_date::date between '01-jul-2021' and now()
                  and tr.deleted_by is null
--                        and tr.counter_serial_number = '0000104'
--                   and tr.cycle_type = 'CIRCULAR'
                  and tr.trans_type_combination_id = 'de579ca8-118d-0f99-1012-c2e6b3a02307'
                  and (coalesce(tr.amount, 0) = 0 and coalesce(tr.kilowatt_hour, 0) = 0)
                order by met_numb),
     prev_dt AS (SELECT cd.met_numb,
                        cd.customer_number,
                        cd.created_date,
                        cd.cur_yr,
                        cd.cur_mn,
                        cd.rn,
                        cd1.cur_yr  AS prev_yr,
                        cd1.cur_mn AS prev_mn
                 FROM cur_dt cd
                 LEFT JOIN cur_dt cd1 ON cd.met_numb = cd1.met_numb AND cd.rn = cd1.rn + 1),
     consecutive_months AS (SELECT *,
                                   CASE
                                       WHEN prev_yr IS NULL THEN 0
                                       WHEN cur_yr = prev_yr AND cur_mn = prev_mn + 1 THEN 1
                                       WHEN cur_yr = prev_yr + 1 AND prev_mn = 12 AND cur_mn = 1 THEN 1
                                       ELSE 0
                                       END AS is_consecutive
                            FROM prev_dt) /*select * from consecutive_months where met_numb in ('0000010', '0000104')*/,
     consecutive_groups AS (SELECT *,
--                                    SUM(is_consecutive) OVER (PARTITION BY met_numb ORDER BY created_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS group_id
                            SUM(CASE WHEN is_consecutive = 0 THEN 1 ELSE 0 END) OVER (PARTITION BY met_numb ORDER BY created_date) AS group_id
                            FROM consecutive_months)/*select * from consecutive_groups where met_numb in ('0000010', '0000104')*/,
     final_sequence AS (SELECT met_numb,
                               customer_number,
                               created_date,
                               cur_yr,
                               cur_mn,
                               group_id,
                               COUNT(*) OVER (PARTITION BY met_numb, group_id) AS consecutive_count
                        FROM consecutive_groups)/*select * from final_sequence where in ('0000010', '0000104')*/
SELECT fs.*
FROM final_sequence fs
WHERE consecutive_count >= 3
ORDER BY met_numb, created_date;*/
