/*with dz as (select customer_number,
                   amount_31_91 + amount_92_182 + amount_183_273 + amount_274_365 + amount_366_731 + amount_732_1097 +
                   amount_1098 pdz,
                   amount as   dz
            from prx_aging_report
            where period_ = ${period}),
    dt_range as (select min(bl.read_date) min_dt,
                        max(bl.read_date) max_dt
                 from prx_block_schedule bl
                 where date_part('year', bl.read_date)::text = substr(${period}, 1, 4)
                     and date_part('month', bl.read_date)::text = substr(${period}, 6, 2)),
     charge as (select tr.customer_number    cust,
                       sum(kilowatt_hour) as kwt,
                       sum(amount)           amount
                from prx_transaction tr
                join dt_range on 1=1
                where tr.kilowatt_hour > 0
                  and tr.deleted_by is null
                  and tr.trans_date between min_dt and max_dt
                group by tr.customer_number)

select * from  dz
left join charge ch on ch.cust = dz.customer_number*/

with ch_dz as (select * from "LK".fn_charge_dz_pdz(${period}))
select distinct cu.customer_number                                                         num,
                regexp_replace(cu.name, '[\x00-\x1F\x7F]', '', 'g')                        nam,
                cat.name                                                                   cat,
                cu.create_date                                                             crda,
                cu.identification_number                                                   id,
                bc.name                                                                    bc,
                regexp_replace(coalesce(adr.street::text, ''), '[\x00-\x1F\x7F]', '', 'g') str,
                regexp_replace(coalesce(adr.house::text, ''), '[\x00-\x1F\x7F]', '', 'g')  hs,
                regexp_replace(coalesce(adr.building, ''), '[\x00-\x1F\x7F]', '', 'g')     bld,
                regexp_replace(coalesce(adr.porch, ''), '[\x00-\x1F\x7F]', '', 'g')        pr,
                regexp_replace(coalesce(adr.flate, ''), '[\x00-\x1F\x7F]', '', 'g')        fl,
                coalesce(cz.dz, 0)                                                         dz,
                coalesce(cz.pdz, 0)                                                        pdz,
                coalesce(cz.kwt, 0)                                                        kwt,
                coalesce(cz.charge_amount, 0)                                              amount,
                sc.from_date,
                ss.name as                                                                 stat,
                case
                    when ss.type_ = 'SUPPLYCONTRACT' then 'Yes'
                    else ''
                    end                                                                    contr
from public.prx_customer cu
join public.prx_customer_category cat on cu.category_id = cat.id
join public.prx_business_center bc on bc.id = cu.business_center_id
left join ch_dz cz on cz.cust = cu.customer_number
/*left join dz on dz.customer_number = cu.customer_number
left join charge ch on ch.cust = cu.customer_number*/
LEFT JOIN (SELECT ad.street,
                  ad.building,
                  ad.house,
                  ad.porch,
                  ad.flate,
                  ad.customer_id,
                  row_number() over (partition by ad.customer_id order by ad.last_modified_date desc) rn
           from prx_customer_address ad
           where ad.deleted_by IS null) adr ON adr.customer_id = cu.id AND adr.rn = 1
left join prx_supply_contract sc on sc.customer_id = cu.id
left join prx_status ss on ss.id = sc.status_id
where cu.deleted_by is null
  and sc.deleted_by is null
  and ss.deleted_by is null
  and create_date::date between ${sDate} and ${eDate};