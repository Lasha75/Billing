select cu.customer_number,
       cu.social_municipality
from prx_customer cu
-- right join "LK".ttt on cu.customer_number = ttt.pid
where cu.social_municipality
    and cu.customer_number not in (select pid from "LK".ttt);

select cu.customer_number
from prx_customer cu
where cu.social_municipality
except
select pid
from "LK".ttt;


update prx_customer cu
set social_municipality = null
-- from "LK".ttt
where cu.customer_number not in (select pid from "LK".ttt) --= ttt.pid
  and cu.social_municipality;