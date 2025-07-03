SELECT c.accnumb,
       c.taxid,
       c.tel,
       c.fax,
       c.custkey,
       c.email,
       c.createdate,
       ac.cycleday,
       co.first_name || ' ' || co.last_name "owner name",
       co.commercial_name,
       co.person_id,
       co.taxid,
       c.register_code,
       co.start_date,
       co.end_date,
       co.status,
       t.NEW_READDATE,
       t.NEW_READING,
       t.NEW_KWT,
       t.ENTERDATE,
       bo.billopername curr_oper,
       bo1.billopername prv_oper,
       ac.mtnumb,
       ac.cycleday,
       ac.accid,
       c.custkey,
       am.fax,
       c.*
FROM   bs.tl_route_store_v t
RIGHT  JOIN bs.tl_customer_v c ON c.custkey = t.CUSTKEY
RIGHT  JOIN bs.tl_account_v ac ON ac.custkey = c.CUSTKEY --(ac.acckey = t.ACCKEY)
RIGHT  JOIN bs.tl_customer_owner_v co ON co.custkey = t.CUSTKEY
JOIN   bs.tl_billoperation_v bo ON bo.billoperkey = t.NEW_RDTYPE
LEFT   JOIN bs.tl_billoperation_v bo1 ON bo1.billoperkey = t.PRV_RDTYPE
LEFT   JOIN bs.tl_cust_alt_mobiles_v am ON am.custkey = t.custkey
WHERE  c.accnumb IN ('1536332')
       OR ac.acckey IN (); --ცილლური

SELECT cu.accnumb,
       it.custkey,
       itemdate,
       reading,
       kwt,
       bo.billopername,
       enterdate,
       note
FROM   bs.tl_item_transf_v it
JOIN   bs.tl_customer_v cu ON cu.custkey = it.custkey
LEFT   JOIN bs.tl_billoperation_v bo ON bo.billoperkey = it.billoperkey
WHERE cu.accnumb in ();--it.custkey=1012012--  --არაციკლური

SELECT COUNT(*) 
FROM bs.tl_route_store_v ;

SELECT *
FROM BS.TL_CUSTOMER_BALANCE_V bal; -- თელასის ბალანსი


SELECT * 
FROM bs.tl_route_store_v rs 
LEFT JOIN bs.tl_customer_v cu ON cu.custkey = rs.CUSTKEY 
WHERE cu.accnumb in ('3384965'); --rs.custkey IN (1005519), 1007671);

SELECT ow.custkey,
       cu.accnumb,
       first_name,
       last_name,
       commercial_name,
       person_id,
       ow.taxid,
       cu.taxid,
       ow.register_code,
       cu.register_code,
       start_date,
       end_date,
       status
FROM   bs.tl_customer_owner_v ow
LEFT   JOIN bs.tl_customer_v cu ON cu.custkey = ow.custkey
WHERE  cu.accnumb IN ('8482297');

SELECT re.custkey,
       cu.accnumb,
       first_name,
       last_name,
       commercial_name,
       person_id,
       re.taxid,
       start_date,
       end_date,
       enter_date
FROM   bs.tl_customer_rental_v re
JOIN bs.tl_customer_v cu ON cu.custkey = re.custkey
WHERE  cu.accnumb in ('2047911');


select * from bs.tl_disconn_balance_v;
--mp
select cu.accnumb,
        mp.* ,
        bo.billopername
from bs.tl_mpitem_v mp
join bs.tl_customer_v cu on cu.custkey = mp.custkey
JOIN   bs.tl_billoperation_v bo ON bo.billoperkey = mp.billoperkey
where cu.accnumb='7193547' and mp.itemdate = '30-jun-2025'


