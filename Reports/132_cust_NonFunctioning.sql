with max_dt as (select icut.customer_id,
                       dt.sent_date,
                       icut.document_number
                 from prx_individual_cutoff icut
                 join (select ic.customer_id,
                              max(ic.sent_date) sent_date
                       from prx_individual_cutoff ic
                       where ic.deleted_by is null
                       group by ic.customer_id) dt on dt.customer_id = icut.customer_id and dt.sent_date = icut.sent_date
                 where icut.deleted_by is null /*and icut.customer_id='be82ba61-a229-a2bb-a96d-93e29c576fa0'*/),
         charge_after_cut as (select tr.customer_id       cust,
                       sum(tr.kilowatt_hour) as kwt,
                       sum(tr.amount)        as amount
                from prx_transaction tr
                join max_dt dt on dt.customer_id = tr.customer_id
                where tr.kilowatt_hour >= 0
                  and tr.deleted_by is null
                  and tr.trans_date between dt.sent_date and now()::date
                  /*and tr.customer_id='be82ba61-a229-a2bb-a96d-93e29c576fa0'*/
                group by tr.customer_id),
        ind_cut as (select cu.customer_number,
                       icut.document_number,
                       dt.sent_date,
                       ch.amount,
                       ch.kwt
                 from prx_individual_cutoff icut
                 join (select ic.customer_id,
                              max(ic.sent_date) sent_date
                       from prx_individual_cutoff ic
                       where ic.deleted_by is null
                       group by ic.customer_id) dt on dt.customer_id = icut.customer_id and dt.sent_date = icut.sent_date
                 left join charge_after_cut ch on ch.cust  = icut.customer_id
                 join prx_customer cu on icut.customer_id = cu.id
                 where icut.deleted_by is null
                   /*and icut.customer_id='be82ba61-a229-a2bb-a96d-93e29c576fa0'*/) ,
     ch_dz as (select ic.customer_number,
                      ic.document_number,
                      ic.sent_date,
                      ic.kwt,
                      ic.amount,
                      dz.kwt           kwt_per,
                      dz.charge_amount amount_per,
                      dz.dz,
                      dz.pdz
               from "LK".fn_charge_dz_pdz(${period}) dz
               left join ind_cut ic on ic.customer_number = dz.cust),
    cur_bal as (select cust_num,
                       cur_bal
                from "LK".fn_current_balance_tlmc())

select cu.customer_number                                                         num,
       regexp_replace(COALESCE(cu.name, ''), '[\x00-\x1F\x7F]', '', 'g')          name,
       cat.name                                                                   cat,
       bc.name                                                                    bc,
       regexp_replace(coalesce(adr.street::text, ''), '[\x00-\x1F\x7F]', '', 'g') str,
       regexp_replace(coalesce(adr.house::text, ''), '[\x00-\x1F\x7F]', '', 'g')  hs,
       regexp_replace(coalesce(adr.building, ''), '[\x00-\x1F\x7F]', '', 'g')     bld,
       regexp_replace(coalesce(adr.porch, ''), '[\x00-\x1F\x7F]', '', 'g')        pr,
       regexp_replace(coalesce(adr.flate, ''), '[\x00-\x1F\x7F]', '', 'g')        fl,
       coalesce(cz.dz, 0) dz,
       coalesce(cz.pdz, 0) pdz,
       coalesce(cz.kwt, 0) kwt,
       coalesce(cz.amount, 0) amount,
       cz.kwt_per,
       cz.amount_per,
       cz.document_number doc_num,
       cz.sent_date sent_dt,
       coalesce(cb.cur_bal, 0) cur_bal
from prx_customer cu
join prx_customer_category cat on cu.category_id = cat.id
left join prx_business_center bc on cu.business_center_id = bc.id
left join ch_dz cz on cz.customer_number = cu.customer_number
left join cur_bal cb on cb.cust_num = cu.customer_number
LEFT JOIN (SELECT ad.street,
                  ad.building,
                  ad.house,
                  ad.porch,
                  ad.flate,
                  ad.customer_id,
                  row_number() over (partition by ad.customer_id order by ad.last_modified_date desc) rn
           from prx_customer_address ad
           where ad.deleted_by IS null) adr ON adr.customer_id = cu.id AND adr.rn = 1
where cu.deleted_by is null /*and cu.customer_number='5343372'*/
  and lower(cu.name) like N'%შეწყვეტილი ფუნქციონირება%';



