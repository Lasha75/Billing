SELECT cu.customer_number cust_num,
       --cu.id,
       cu.full_name       cust_name,
       cat."name"         cat,
       bc."name"          bc,
       pca.street,
       pca.building,
       pca.house,
       pca.porch,
       pca.flate,
       cut.amount,
       cut.amount_penalty,
       cut.amount_telasi,
       cut.amount_telmico,
       cut.tl_oper_date,
       --cut.tl_enter_date,
       --cut.tl_mark_time,
       cut.cut_status,
       cs.description,
       cs.telasi_description,
       cut.note,
       cut.serial_number
FROM prx_customer cu
LEFT JOIN (SELECT ad.street,
               ad.building,
               ad.house,
               ad.porch,
               ad.flate,
               ad.customer_id,
               row_number() over (partition by ad.customer_id order by ad.id desc) rn
            from  prx_customer_address ad
            where ad.deleted_by IS null) pca ON pca.customer_id = cu.id AND pca.rn = 1
JOIN prx_customer_category cat ON cat.id = cu.category_id
JOIN prx_business_center bc ON bc.id = cu.business_center_id
join prx_customer_cutoff cut on cu.id = cut.customer_id and cut.deleted_by is null
left join prx_cutoff_status cs on cut.cutoff_status_id = cs.id and cs.deleted_by is null
where cut.tl_mark_time between  ${start_date} and  ${end_date}  and cu.deleted_by is null --and cu.customer_number='0000117'
ORDER BY 1









 

