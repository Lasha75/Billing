SELECT  pid,
        now()-pg_stat_activity.query_start duration,
        query,
       * FROM pg_stat_activity WHERE state = 'active';



--SELECT pg_cancel_backend(13586);--pid

--SELECT pg_terminate_backend(23537)