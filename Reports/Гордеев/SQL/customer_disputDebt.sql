select distinct cu.customer_number numb,
                cu.name            name,
                cat.name           cat,
                cu.disputed_debt dis_db,
                dt.daricxvaamount chg_am,
                dt.davalianebaamount debt,
                dt.period_ prd
from public.prx_customer cu
join prx_debtor_balance_report dt on dt.customer_number = cu.customer_number
join public.prx_customer_category cat on cu.category_id = cat.id
where cu.deleted_by is null
  and coalesce(cu.disputed_debt, 0) != 0
    and coalesce(dt.daricxvaamount, 0) != 0
    and coalesce(dt.davalianebaamount, 0) != 0
    and dt.period_=${prd}



