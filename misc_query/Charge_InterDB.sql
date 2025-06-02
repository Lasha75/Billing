select /*cu.cust_key              custkey,
       met.telasi_acc_key       acckey,
       tr.read_date             new_readdate,
       tr.counter_reading_value new_reading,*/
       sum(tr.kilowatt_hour)         new_kwt/*,
       pttc.operation_key       new_rdtype*/
from prx_transaction tr
join prx_counter met on met.code = tr.counter_number
join prx_transaction_type_combinati pttc on tr.trans_type_combination_id = pttc.id
join prx_customer cu on tr.customer_id = cu.id
where tr.read_date between '04-dec-2023' and '05-jan-2024'
  and tr.deleted_by is null
  and met.deleted_by is null
  and cu.deleted_by is null
  and tr.trans_type_combination_id in ('de579ca8-118d-0f99-1012-c2e6b3a02307',
                                       'ce5ae29e-cf2a-1053-e58e-c16bf1063670',
                                       '51a53157-c480-2e09-fb94-a9625dc12e32',
                                       '61922bb4-daa5-9696-c7b5-69609e027171',
                                       'a4e37496-cbb1-51bb-0a94-32bc07dd3710',
                                       '92064740-2471-1450-a569-ac4b7efe9a0c')
  and tr.cycle_type = 'CIRCULAR'

