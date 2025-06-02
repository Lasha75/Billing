update "LK".lk_pre_court
set status= case trim(status)
                when 'დასრულდა' then 'FINISHED'
                when 'პროცესშია' then 'IN_PROCESS'
                when 'გადაეცა იურიდიულ სამსახურს' then 'PASSED'
                when 'სასამართლოში ადრე გადაცემული' then 'PREVIOUSCOURT'
                when 'დამუშავებული' then 'PROCESSED'
                when 'უკან დაბრუნდა იურიდიული სამსახურიდან' then 'RETURNED'
                when 'არაიდენტიფიცირებული' then 'UNIDENTIFIED'
    end
where id >= 1;
--------
select cu.deleted_by,
       cu.deleted_date,
       cu.customer_number,
       *
from prx_pre_court_work pcw
join prx_customer cu on pcw.customer_id = cu.id
-- join "LK".lk_pre_court lpc on lpc.customer_number = cu.customer_number
where pcw.status  is null-- 'IN_PROCESS'
  and pcw.created_date::date > date_trunc('month', current_date)::date
  and pcw.deleted_by is null
  and cu.deleted_by is null;

update prx_pre_court_work pcw
set status = lpc.status,
    remark = lpc.remark
from "LK".lk_pre_court lpc
join prx_customer cu on lpc.customer_number = cu.customer_number
where cu.id = pcw.customer_id
  and pcw.created_date::date > date_trunc('month', current_date)--'2025-03-01'
  and pcw.status = 'IN_PROCESS'
--   and pcw.status is null
  and pcw.deleted_by is null
  and cu.deleted_by is null;
/*and lpc.customer_number in ('4968921',
                            '2534494',
                            '4124502',
                            '5465016',
                            '5262878',
                            '5737571',
                            '2713692',
                            '6369468',
                            '4815542');*/
