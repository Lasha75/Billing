--New requisite change
select *
from (select row_number()
             over (partition by customer_number, extract('MONTH' from create_ts) order by e.create_ts desc) rn,
             cu.customer_number,
             create_ts::date                                                                                create_date,
             event_ts::date                                                                                 event_date,
             e.entity,
             changes,
             entity_instance_name,
             e.created_by,
             e.change_type
      from audit_entity_log e
      join prx_customer cu on cu.id = e.entity_id
      /*where (cast(e.create_ts as date) >= '01-mar-2024' or cast(e.event_ts as date) >= '01-mar-2024')
--         and cu.customer_number = '0157573'
        and e.created_by = 'system'
        and left(e.changes, 8) = 'fullName'*/) l
where l.rn = 1


--Old requisite change
SELECT *
FROM   (SELECT cu.customer_number,
               t.oper_time,
               t.oper_type,
               t.oper_object,
               t.object_field,
               t.value_before,
               t.value_after,
               row_number() over(PARTITION BY t.cust_key, t.oper_time  ORDER BY t.cust_key DESC) rn
        FROM   "Billing_TestDB".public.prx_customer_log_import t
        LEFT   JOIN "Billing_TestDB".public.prx_customer cu ON cu.cust_key = t.cust_key
        -- where t.oper_time in (select change_time from logs) and
        WHERE  cast(t.oper_time as date) >= '01-sep-2023'
               AND lower(t.oper_object) = 'customer'
               AND lower(t.object_field) = 'custname') l
WHERE  rn = 1
ORDER  BY 1