-- I/O consuming queries
SELECT query,
calls,
(shared_blks_read + local_blks_read + temp_blks_read) AS total_blks_read,
(shared_blks_written + local_blks_written + temp_blks_written) AS total_blks_written ,
shared_blks_hit,
shared_blks_read,
shared_blks_dirtied,
shared_blks_written,
local_blks_hit,
local_blks_read,
local_blks_dirtied,
local_blks_written,
temp_blks_read,
temp_blks_written
FROM pg_stat_statements
ORDER BY --calls desc,total_blks_read DESC
total_blks_read DESC , calls DESC
LIMIT 20;

-- TOP 20 slow queries
SELECT substring(query, 1, 50)                                    AS short_query,
       round(total_exec_time::numeric, 2)                         AS total_exec_time,
       calls,
       round(mean_exec_time::numeric, 2)                          AS avg_exec_time,
       round((100 * total_exec_time /
              sum(total_exec_time::numeric) OVER ())::numeric, 2) AS percentage_cpu
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

-- TOP Cpu consuming queries

SELECT query,
       total_exec_time,
       total_plan_time,
       calls,
       mean_exec_time,
       mean_plan_time,
       (total_exec_time / calls) AS avg_exec_time_per_call,
       (total_plan_time / calls) AS avg_plan_time_per_call
FROM pg_stat_statements
ORDER BY total_exec_time + total_plan_time DESC
LIMIT 20;

-- Query to Find All Jobs in pgAgent
SELECT *
FROM pgagent.pga_job;

--Query to Find Active Queries/Processes
SELECT pid, query, state, backend_start, *
FROM pg_stat_activity
WHERE state = 'active';


select * from pg_foreign_server

SHOW server_version;
SELECT version();

-------columns list
SELECT column_name FROM information_schema.columns
WHERE table_name = 'prx_transaction';