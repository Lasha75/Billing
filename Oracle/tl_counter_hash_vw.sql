create or replace view  tl.tl_counter_hash as
SELECT createdate,
       closedate,
       tl.f_md5(concat(c.createdate, c.closedate) || c.voltage || concat(c.startdate, c.inst_cp) || c.mtnumb || concat(c.dateinst, c.mtname) ||
                concat(c.digit, c.mttpkey) || concat(c.mtkoef, c.cycleday) || concat(c.acckey, c.custkey) || c.accid || concat(c.is_smart, c.company_id)) hashcode,
       voltage,
       startdate,
       inst_cp,
       mtnumb,
       dateinst,
       mtname,
       digit,
       mttpkey,
       mtkoef,
       cycleday,
       acckey,
       custkey,
       accid,
       is_smart,
       company_id
FROM   bs.tl_account_v c


