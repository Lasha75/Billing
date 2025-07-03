SELECT c.accnumb,
       c.custname,
       t.oper_code,
       t.mark_code,
       t.mark_date,
       t.enter_date,
       t.status_telasi,
       t.status_telmico,
       t.oper_motive,
       t.oper_type
FROM   BS.FT_CUT_HISTORY t
JOIN   bs.tl_customer_v c ON c.custkey = t.custkey
WHERE  c.accnumb = '0393808'
ORDER  BY mark_date desc ;

SELECT c.accnumb, 
       ct.CUSTKEY,
       stat_el,
       oper_date,
       mark_date,
       oper_code,
       mark_code,
       reading,
       discrecstatuskey,
       enter_date_insp,
       enter_date_oper,
       acckey,
       stat_tr,
       stat_w
FROM   bs.tl_cut_history_v ct
JOIN   bs.tl_customer_v c ON c.custkey = ct.custkey
WHERE  c.accnumb = '1688089'
order by mark_date desc


SELECT *  FROM bs.tl_item_transf_v 


DECLARE
   v1 VARCHAR2(50);
BEGIN
   v1 := Utl_Raw.Cast_To_Raw(sys.dbms_obfuscation_toolkit.md5(input_string => '123'));
   dbms_output.put_line(v1);
END;



CREATE OR REPLACE FUNCTION F_MD5(in_str VARCHAR2) RETURN VARCHAR2 IS
   STR_MD5 VARCHAR2(2000);
BEGIN
   STR_MD5 := utl_raw.cast_to_raw(dbms_obfuscation_toolkit.MD5(input_string => in_str));
   RETURN STR_MD5;
END F_MD5;




select tl.f_md5('123') from dual

202CB962AC59075B964B07152D234B70
202CB962AC59075B964B07152D234B70
