truncate table public.prx_circular_accural;
insert INTO public.prx_circular_accural(id, version, created_by, created_date, last_modified_by, last_modified_date,
                                        deleted_by, deleted_date, customer_id, block_id, counter_number, new_kilowatt,
                                        new_reading, new_read_date, prev_read, prev_read_date, prev_read_type_id,
                                        read_type_id, status, prev_real_date, prev_real_reading, enter_date_time,
                                        create_time_stamp)
select gen_random_uuid(),
       1,
       'admin',
       now(),
       'admin',
       now(),
       null,
       null,
       c.id,
       cnt.block_id,
       cnt.code,
       rt.NEW_KWT,
       rt.NEW_READING,
       rt.NEW_READDATE,
       rt.PRV_READING,
       rt.PRV_READDATE,
       ptp.id as prevReadType,
       ntp.id as newReadType,
       'TO_BE_CHARGED',
       null,
       null,
       rt.ENTERDATE,
       #timestamp
from public.prx_customer c
join public.prx_customer_contract k on k.customer_id = c.id
join public.prx_customer_contract_type kt on kt.id = k.type_id
left join public.prx_counter cnt on cnt.contract_id = k.id
join public.VWTelasiRouteStore rt on rt.CUSTKEY = c.cust_key
join public.prx_transaction_type_combinati ptp on ptp.operation_key = rt.PRV_RDTYPE
join public.prx_transaction_type_combinati ntp on ntp.operation_key = rt.NEW_RDTYPE
where cnt.deleted_by is null
  and c.deleted_by is null
  and k.deleted_by is null
  and rt.NEW_READDATE >= '5/27/2023'
  and cnt.block_id = #blprm /*and kt.code = '001'*/
  and rt.ACCKEY = cnt.telasi_acc_key;

create temp TABLE temp_tb
(
    customer_id     UUID,
    prevrealdate    date,
    prevrealreading DECIMAL,
    counter_number  varchar(30)
);

insert INTO temp_tb(customer_id, prevrealdate, prevrealreading, counter_number)
select a.customer_id,
       a.prevrealdate,
       a.prevrealreading,
       a.counter_number
FROM public.TransactionLastRecordDataVW a;

UPDATE public.prx_circular_accural C
SET prev_real_date    = a.prevrealdate,
    prev_real_reading = a.prevrealreading
FROM temp_tb a
WHERE a.customer_id = c.customer_id
  AND c.counter_number = a.counter_number
  AND c.create_time_stamp = #createTimeStamp;

drop TABLE temp_tb;

UPDATE public.prx_circular_accural c
SET prev_block_read_date = pbs.read_date
FROM prx_block_schedule pbs
WHERE c.block_id = pbs.block_id_id
  and pbs.deleted_by is null
  AND pbs.year_ = EXTRACT(YEAR FROM date_trunc('month', c.new_read_date - interval '1' month))
  AND pbs.month_ = EXTRACT(MONTH FROM date_trunc('month', c.new_read_date - interval '1' month))
  AND c.create_time_stamp = #createTimeStamp