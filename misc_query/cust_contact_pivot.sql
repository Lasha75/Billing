select * from crosstab('select customer_number,
                            regexp_replace(COALESCE(cu.name, ''''), ''[\x00-\x1F\x7F]'', '''', ''g'') Name,
                            contact_type,
                            contact_info
                        from public.prx_customer_contact cc
                       join prx_customer cu on cu.id = cc.customer_id
                        where lower(contact_info) not like ''%off%''
                            and cc.deleted_by is null and cu.deleted_by is null
                       order by 1',
                        'select distinct contact_type
                        from public.prx_customer_contact
                        where lower(contact_info) not like ''%off%''
                            and deleted_by is null
                        order by 1')
                       as
                       res (cust_numb text, Name text, CONTACT_PERSON text, mail text, FAX text, home text,  mob text,  work text);
