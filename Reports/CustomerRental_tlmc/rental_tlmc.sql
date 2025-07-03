select cu.customer_number                                                               num,
       ow.create_date                                                                   crdt,
       regexp_replace(COALESCE(first_name, ''), '[\x00-\x1F\x7F]', '', 'g')             fnam,
       regexp_replace(COALESCE(last_name, ''), '[\x00-\x1F\x7F]', '', 'g')              lnam,
       regexp_replace(COALESCE(commercial_name, ''), '[\x00-\x1F\x7F]', '', 'g')        cnam,
       regexp_replace(COALESCE(personal_id, ''), '[\x00-\x1F\x7F]', '', 'g')            pid,
       start_date                                                                       sdate,
       end_date                                                                         edate,
       owt.name                                                                         otyp,
       regexp_replace(COALESCE(additional_personal_id, ''), '[\x00-\x1F\x7F]', '', 'g') apid,
       regexp_replace(COALESCE(additional_name, ''), '[\x00-\x1F\x7F]', '', 'g')        anam,
       regexp_replace(COALESCE(tax_id, ''), '[\x00-\x1F\x7F]', '', 'g')                 tid,
       st.name stat,
       bl.block_index bl
from prx_customer cu
left join public.prx_status st on cu.status_id = st.id
left join prx_counter met on met.cust_key = cu.cust_key
left join prx_block bl on bl.id = met.block_id
join lateral (
    select *
    from "Billing_TestDB".public.prx_beneficiary_information ren
    where ren.customer_id = cu.id
      and ren.deleted_by is null
    order by ren.start_date desc
    limit 1
    ) ow on true -- გამოიყენება როდესაც საჭიროა რაიმე ერთი მნიშვნელობის წამოღბა გარე ცხრილიდან (max(), min() etc)
left join prx_owner_type owt on ow.owner_type_id = owt.id
where ow.deleted_by is null
  and cu.deleted_by is null;

-------------------------------------------


update "LK".tmp_lk t
    set cust_id=cu.id
from prx_customer cu
where cu.customer_number=t.custnum;


select t.custnum,
       t.date_,
       pi.*
    from prx_proprietor_information pi
    join "LK".tmp_lk t on t.cust_id = pi.customer_id
    where deleted_by is null
-- and end_date is  null
;

update prx_proprietor_information pi
set start_date = t.date_,
    last_modified_date=current_date,
    last_modified_by='lkhvichia'
from "LK".tmp_lk t
where t.cust_id =  pi.customer_id
and pi.deleted_by is null
/*and pi.end_date is null;*/
and t.custnum='8333047'
