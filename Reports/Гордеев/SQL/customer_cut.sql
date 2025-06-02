select cu.customer_number,
       cu.name customer_name,
        bc.name BC,
        adr.street,
        adr.building,
        adr.house,
        adr.porch,
        adr.flate,
       cu.cut_off_telasi_debt,
       cu.cut_off_telmico_debt,
       cu.cut_for_electricity,
       cu.cut_for_garbage,
       cu.cut_for_water,
       cu.cut_off_type,
       cu.cut_of_type_date_time,
       cu.cut_status_telasi
from prx_customer cu
join public.prx_business_center bc on bc.id = cu.business_center_id
LEFT JOIN (SELECT ad.street,
               ad.building,
               ad.house,
               ad.porch,
               ad.flate,
               ad.customer_id,
               row_number() over (partition by ad.customer_id order by ad.last_modified_date desc) rn
            from  prx_customer_address ad
            where ad.deleted_by IS null) adr ON adr.customer_id = cu.id AND adr.rn = 1
where cu.deleted_by is null and cu.cut_status_telasi in ('CUT', 'FORCUT') and cu.cut_for_electricity = 'true'
order by 1;

