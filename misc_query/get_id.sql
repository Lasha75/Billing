with own_id as (SELECT distinct customer_id,
                       regexp_replace(COALESCE(NULLIF(personal_id, ''), tax_id), '[\x00-\x1F\x7F]', '', 'g') AS ow_id
                      FROM prx_proprietor_information
                      WHERE deleted_by IS NULL
                        AND end_date IS NULL
                        AND COALESCE(NULLIF(personal_id, ''), tax_id) IS NOT NULL),
     ben_id as (select pbi.customer_id,
                       regexp_replace(COALESCE(pbi.personal_id, ''), '[\x00-\x1F\x7F]', '', 'g') personal_id
                from prx_beneficiary_information pbi
                where pbi.deleted_by is null
                  and end_date is null)

select distinct cu.customer_number,
                regexp_replace(COALESCE(NULLIF(cu.identification_number, ''), NULLIF(o.ow_id, ''), b.personal_id), '[\x00-\x1F\x7F]', '', 'g') AS p_id
from prx_customer cu
left join own_id o on o.customer_id = cu.id
left join ben_id b on b.customer_id = cu.id
where deleted_by is null;
/*and cu.id='47b4cfc8-a1b2-0dc3-263a-74e7d44636a3'*/