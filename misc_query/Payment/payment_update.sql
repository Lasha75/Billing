/*with pmn(id) as (values ('14805662573'), ('14805663517'), ('14805665481'), ('14805666301'), ('14805667730'),( '14805667793'), ('14805668079'),
                        ('14805668103'), ('14805668426'), ('14805668596'), ('14805668605'), ('14805668939'), ('14805669240'), ('14805670081'),
                        ('14805670496'), ('14805670581'), ('14805671338'), ('14805671539'), ('14805671834'), ('14805671941'), ('14805671952'),
                        ('14805672004'), ('14805672326'), ('14805672468'), ('14805672984'), ('14805673088'), ('14805673182'), ('14805673372'),
                        ('14805673495'), ('14805673600'), ('14805674115'), ('14805674267'), ('14805674405'), ('14805674549'), ('14805674618'),
                        ('14805674632'), ('14805675095'), ('14805675410'), ('14805676084'), ('14805676829'), ('14805677215'), ('14805678383'),
                        ('14805678420'), ('14805678743'), ('14805678809'), ('14805678944'), ('14805679121'), ('14805679320'), ('14805680102'),
                        ('14805681210'), ('14805681867'), ('14805682021'), ('14805682119'), ('14805682214'), ('14805683025'), ('14805685920'),
                        ('14805686015'), ('14805686016'), ('14805686905'), ('14805687094'), ('14805687398'), ('14805687564'), ('14805687739'),
                        ('14805688198'), ('14805688358'), ('14805688527'), ('14805688980'), ('14805689052'), ('14805689063'), ('14805689381'),
                        ('14805689556'), ('14805689742'), ('14805689771'), ('14805691025'), ('14805691077'), ('14805691479'), ('14805691884'),
                        ('14805692243'), ('14805692625'), ('14805692707'))
update prx_transaction tr
set reporting_date = '2025-04-03'
from pmn
where pmn.id = tr.payment_doc_number;*/
---------------------------------------
select pm.bank_id,
       pm.status,
       pm.amount,
       pm.reporting_date,
       pm.internal_bank_id,
       pm.transaction_id,
       pm.create_date,
       pm.payment_date_time,
       pm.aviso_date,
       pm.payment_date,
       pm.customer_number,
        pm.telmico_amount,
        pm.telasi_amount
from prx_payment pm
where pm.payment_id in ('27579056392');--pm.internal_bank_id = 'LB' and reporting_date = '2025-03-08';--pm.payment_id in ('1');-- --



/*  დადასტურება
update prx_payment
set reporting_date = '2025-03-28'
where reporting_date='2025-03-08' and internal_bank_id='LB';
*/

/*update prx_payment
set

  reporting_date = '2024-03-26' --internal_bank_id= 'BOG'
where payment_id in ('11558766711')--internal_bank_id = 'LB' and reporting_date = '08-mar-2024'
  --*/

select tr.bank_code,
       tr.created_date,
       tr.amount,
       tr.reporting_date,
       tr.customer_number,
       id
from prx_transaction tr
where tr.payment_doc_number in ('27579056392')--tr.bank_code = 'LB' and reporting_date = '2025-03-27'--
and tr.deleted_by is null;
--
/*update prx_transaction
    set reporting_date = '2025-03-28',
        last_modified_by='kkakhishvili',
        last_modified_date=now()
where bank_code = 'LB' and reporting_date = '2025-03-27';*/
-- join "LK".ttt t on t.pid = pm.payment_doc_number;
/*update prx_transaction
    set reporting_date = '2025-01-24'
        deleted_by = 'lmaisuradze',
        deleted_date=now()
     payment_doc_number in ('25610863716') and deleted_by is null
  and id!='71e4f6a8-1164-4a81-87fb-fb48dff4fe48'
  --bank_code = 'LB' and reporting_date = '08-mar-2024'--bank_code='BOG' --
  --*/


select st.settle_date, tr.trans_date, st.trans_date, st.created_date, tr.aviso_date, tr.read_date, * from prx_settle_transaction st
join prx_transaction tr on st.transaction_id = tr.id
where st.customer_number in ('5593217',
'4964523',
'4964499',
'4964541',
'4964202',
'4964453',
'4964514',
'5494921',
'5191302',
'5466015',
'5593208',
'5593191',
'5718404',
'5718440',
'6456845',
'4964550',
'5718413',
'4964480',
'4964444',
'5028392',
'4964471',
'5593235',
'5593226',
'5593244',
'5523980',
'4964532'
) --tr.payment_doc_number in ('25610863716')
and tr.deleted_by is null and st.deleted_by is null
order by 1 desc




select distinct pm.bank_id, pm.internal_bank_id
from prx_payment pm;

select pm.bank_code
from prx_transaction pm;