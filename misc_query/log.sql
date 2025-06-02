/*telmico*/
WITH raw_data AS (select c.customer_number,
                         c.create_date,
                         lg.entity_instance_name,
                         lg.change_type,
                         lg.changes raw_string,
                         lg.event_ts,
                         lg.username
                  from audit_entity_log lg
                  join prx_customer c on c.id = lg.entity_id
                  where c.customer_number='5979827'
                      /*lg.entity = 'prx_Customer'
                    and c.deleted_by is null
                    and (lower(lg.changes) like '%givetype%' or lower(lg.changes) like '%category%')*/)
SELECT customer_number,
       create_date,
       event_ts,
       username,
       raw_string,
    /*REGEXP_MATCH(split_part(split_part(raw_string, 'giveType-oldVl=', 2), ' ', 1), 'public') supply_old,
    REGEXP_MATCH(split_part(split_part(raw_string, 'giveType=', 2), ' ', 1), 'universal') supply_new,*/
/*    REGEXP_REPLACE(split_part(split_part(raw_string, 'category-oldVl=', 2), ' category-oldVlId=', 1), '[a-zA-Z= \-]', '', 'g') cat_old,
    REGEXP_REPLACE(split_part(split_part(raw_string, 'category=', 2), ' category-id=', 1), '[a-zA-Z= \-]', '', 'g') cat_new,
    REGEXP_REPLACE(split_part(split_part(raw_string, 'category-oldVl=', 2), ' category-oldVlId=', 1), '[a-zA-Z= \-]', '', 'g') AS category_old,
    REGEXP_REPLACE(split_part(split_part(raw_string, 'category=', 2), ' category-id=', 1), '[a-zA-Z= \-]', '', 'g') AS category_new,*/
       (REGEXP_MATCHES(raw_string, 'giveType-oldVl=([^\s ]+)', 'g'))[1] AS supply_old,
       (REGEXP_MATCHES(raw_string, 'giveType=([^\s]+)', 'g'))[1]        AS supply_new,
       (REGEXP_MATCHES(raw_string, 'category-oldVl=([^\s ]+)', 'g'))[1] AS category_old,
       (REGEXP_MATCHES(raw_string, 'category=([^\s]+)', 'g'))[1]        AS category_new,
       (REGEXP_MATCHES(raw_string, 'fullname-oldVl=([^\s]+)', 'g'))[1]        AS name_old,
       (REGEXP_MATCHES(raw_string, 'fullname=([^\s]+)', 'g'))[1]        AS name_new
/*    split_part(split_part(raw_string, 'giveType-oldVl=', 2), ' ', 1) AS give_type_old,
    split_part(split_part(raw_string, 'giveType=', 2), ' ', 1) AS give_type_new,*/
--     split_part(split_part(raw_string, 'giveType-id=', 2), ' ', 1) AS give_type_id,
--     split_part(split_part(raw_string, 'category-oldVl=', 2), ' category-oldVlId=', 1) AS category_old,
--     split_part(split_part(raw_string, 'category-oldVlId=', 2), ' category=', 1) AS category_old_id,
--     split_part(split_part(raw_string, 'category=', 2), ' category-id=', 1) AS category_new
--     split_part(split_part(raw_string, 'category-id=', 2), ' ', 1) AS category_new_id
FROM raw_data;

/*SELECT
    REGEXP_REPLACE(SPLIT_PART(column_value, 'category-oldVl=', 2), '[\x00-\x7F]', '', 'g') AS category_oldvl_nonlatin,
    REGEXP_REPLACE(SPLIT_PART(column_value, 'category=', 2),'[\x00-\x7F]', '', 'g') AS category_nonlatin
FROM (VALUES
    ('category-oldVl=მოსახლეობა  -18% დღგ category-oldVlId=1c89179a-2e10-5aa0-4482-424a893f75a6 category=კომერციული -18% დღგ category-id=c6f7b736-9872-62a9-7249-6af5a08e77aa')
) AS t(column_value); - VALUES (...) AS t(column_value): This part creates a temporary table with one column column_value containing the input string.
*/

/**/

/*telasi*/
select *
from prx_customer_log_import
/**/

