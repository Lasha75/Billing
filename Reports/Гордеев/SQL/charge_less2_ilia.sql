with charge as (select distinct met_num1,
                                customer_number1
                from (select tr.counter_number        met_num1,
                             tr.customer_number              customer_number1,
                             date_trunc('DAY', created_date) date1,
                             sum(kilowatt_hour) as           kilowatt_hour1
                      from prx_transaction tr
                      where /*tr.customer_number = '7105232'  and*/
                          tr.kilowatt_hour > 0 and tr.kilowatt_hour <= 2
                        and tr.trans_type_combination_id = 'de579ca8-118d-0f99-1012-c2e6b3a02307'
                      group by tr.customer_number,
                               tr.counter_number,
                               date_trunc('DAY', created_date)
                      order by tr.customer_number,
                               tr.counter_number,
                               date_trunc('DAY', created_date)) a
                join (select tr.counter_number        met_num2,
                             tr.customer_number              customer_number2,
                             date_trunc('DAY', created_date) date2,
                             sum(kilowatt_hour) as           kilowatt_hour2
                      from prx_transaction tr
                      where
                          /*tr.customer_number = '7105232'  and*/
                          tr.kilowatt_hour = 0
                        and tr.trans_type_combination_id = 'de579ca8-118d-0f99-1012-c2e6b3a02307'
                      group by tr.customer_number,
                               tr.counter_number,
                               date_trunc('DAY', created_date)
                      order by tr.customer_number,
                               tr.counter_number,
                               date_trunc('DAY', created_date)) b on b.customer_number2 = a.customer_number1
                                                                         and (b.met_num2 = a.met_num1 or (b.met_num2 isnull and  a.met_num1 isnull) )
                join (select tr.counter_number        met_num3,
                             tr.customer_number              customer_number3,
                             date_trunc('DAY', created_date) date3,
                             sum(kilowatt_hour) as           kilowatt_hour3
                      from prx_transaction tr
                      where
                          /*tr.customer_number = '7105232'  and*/
                          tr.kilowatt_hour = 0
                        and tr.trans_type_combination_id = 'de579ca8-118d-0f99-1012-c2e6b3a02307'
                      group by tr.customer_number,
                               tr.counter_number,
                               date_trunc('DAY', created_date)
                      order by tr.customer_number,
                               tr.counter_number,
                               date_trunc('DAY', created_date)) d on d.customer_number3 = b.customer_number2 and (d.met_num3 = b.met_num2 or (d.met_num3 is null and  b.met_num2 is null  ))
                join (select tr.counter_number        met_num4,
                             tr.customer_number              customer_number4,
                             date_trunc('DAY', created_date) date4,
                             sum(kilowatt_hour) as           kilowatt_hour4
                      from prx_transaction tr
                      where   /*tr.customer_number = '7105232'  and*/
                          tr.kilowatt_hour = 0
                        and tr.trans_type_combination_id = 'de579ca8-118d-0f99-1012-c2e6b3a02307'
                      group by tr.customer_number,
                               tr.counter_number,
                               date_trunc('DAY', created_date)
                      order by tr.customer_number,
                               tr.counter_number,
                               date_trunc('DAY', created_date)) e on e.customer_number4 = d.customer_number3 and (e.met_num4 = d.met_num3 or (e.met_num4 is null and d.met_num3 isnull))
                where a.date1 = (b.date2 + INTERVAL '1 Month')
                  and b.date2 = (d.date3 + INTERVAL '1 Month')
                  and d.date3 = (e.date4 + INTERVAL '1 Month')
                and (kilowatt_hour1 > 0 and kilowatt_hour1 <= 2)
                /*and kilowatt_hour2 = 0
                and kilowatt_hour3 = 0
                and kilowatt_hour4 = 0*/),
     cust_info as (select cu.customer_number,
                          regexp_replace(COALESCE(cu.name, ''), '[\x00-\x1F\x7F]', '', 'g')         cust_nam,
                          cat.name                                                                  cat,
                          act.name                                                                  act,
                          regexp_replace(COALESCE(cu.address_text, ''), '[\x00-\x1F\x7F]', '', 'g') addr,
                          bc.name                                                                   bc,
                          cu.created_date                                                           crda,
                          st.name                                                                   stat,
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
                   where cu.deleted_by is null ),
     bal_tlmc as (select * from "LK".fn_current_balance_tlmc() where cur_bal > 0),
     mon_charge as (select *
                    from crosstab($$select  distinct counter_number,
                                            lpad(cast(extract(month from tr.created_date) as  text), 2,'0') ||'-'||extract(year from tr.created_date),
                                            tr.kilowatt_hour
                                    from prx_transaction tr
                                    where tr.created_date::date between '01-jul-2021' and now()
                                    and tr.deleted_by is null and tr.trans_type_combination_id = 'de579ca8-118d-0f99-1012-c2e6b3a02307'
                                    order by 1,2 $$,
                                    $$SELECT to_char(date_trunc('month', dd), 'MM-YYYY') AS month_year
                                      FROM generate_series('2021-07-01'::timestamp, CURRENT_DATE, '1 month') dd$$) as ch (mett text,
                                  "07-2021" text, "08-2021" text, "09-2021" text, "10-2021" text,
                                  "11-2021" text, "12-2021" text, "01-2022" text, "02-2022" text, "03-2022" text, "04-2022" text,
                                  "05-2022" text, "06-2022" text, "07-2022" text, "08-2022" text, "09-2022" text, "10-2022" text,
                                  "11-2022" text, "12-2022" text, "01-2023" text, "02-2023" text, "03-2023" text, "04-2023" text, "05-2023" text,
                                  "06-2023" text, "07-2023" text, "08-2023" text, "09-2023" text, "10-2023" text, "11-2023" text,
                                  "12-2023" text, "01-2024" text, "02-2024" text, "03-2024" text, "04-2024" text, "05-2024" text,
                                  "06-2024" text, "07-2024" text, "08-2024" text, "09-2024" text, "10-2024" text, "11-2024" text))


select *
from charge ch
 left join cust_info ci on ci.customer_number = ch.customer_number1
 join bal_tlmc dz on dz.cust_num = ch.customer_number1
left join mon_charge mch on /*ch.customer_number1 = mch.cust_num and*/ ch.met_num1 = mch.mett;
-- where ch.customer_number1='7105232';

