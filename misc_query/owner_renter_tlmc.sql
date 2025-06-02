/*owner*/
select cu.customer_number,
       own.first_name,
       own.last_name,
       own.commercial_name,
       own.personal_id,
       own.tax_id,
       own.start_date,
       own.end_date,
        ownt.name Owner_type,
       own.additional_personal_id,
       own.additional_name
from public.prx_proprietor_information own
left join prx_customer cu on own.customer_id = cu.id
left join prx_owner_type ownt on own.owner_type_id = ownt.id
where own.deleted_by is null;

/*renter*/
select *
from prx_beneficiary_information pbi
where pbi.deleted_by is null;