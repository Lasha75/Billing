select sms_bill, cu.needs_el_bill,  *
from prx_customer cu
join "LK".ttt on ttt.pid = cu.customer_number;


update prx_customer cu
set /*sms_bill   = true,
    email_bill = false*/
    needs_el_bill = false
from "LK".ttt
where ttt.pid = cu.customer_number;