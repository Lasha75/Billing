with tmp as (select id
             from prx_rect_message
             where lower(status) like '%draft%'
               and deleted_by is null)

update prx_rect_message rm
set deleted_by='sgordeev',
    deleted_date = now()
from tmp t
where t.id = rm.id;