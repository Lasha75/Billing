SELECT t.payment_doc_number,
	t.customer_number,
	count(*)
FROM prx_transaction t
WHERE t.payment_doc_number IS NOT NULL AND t.deleted_by IS NULL
GROUP BY t.payment_doc_number, t.customer_number
HAVING count(*)>1;

/*
DROP TABLE paymentTransCustomerForDelete;

SELECT t.payment_doc_number, 
	t.customer_number, 
	count(*) 
INTO paymentTransCustomerForDelete
FROM prx_transaction t
WHERE t.payment_doc_number IS NOT NULL AND t.deleted_by IS NULL
GROUP BY t.payment_doc_number, t.customer_number
HAVING count(*)>1;

DROP TABLE paymentTransCustomerForDeleteRow;

SELECT t.payment_doc_number, 
	t.customer_number, 
	t.id , 
	ROW_NUMBER() OVER (PARTITION BY t.payment_doc_number) AS rownumber 
INTO paymentTransCustomerForDeleteRow
FROM prx_transaction t
INNER JOIN paymenttransCustomerfordelete p ON p.payment_doc_number = t.payment_doc_number 
		AND p.customer_number = t.customer_number;

UPDATE prx_settle_transaction
SET
	deleted_by = 'lkhvichia', 
	deleted_date = now()
FROM paymentTransCustomerForDeleteRow r
WHERE r.rownumber>1 AND prx_settle_transaction.transaction_id = r.id;

UPDATE prx_transaction
SET
	deleted_by = 'lkhvichia', 
	deleted_date = now()
FROM paymentTransCustomerForDeleteRow r
WHERE r.rownumber>1 AND prx_transaction.id = r.id;

UPDATE prx_open_transaction
SET
	deleted_by = 'lkhvichia', 
	deleted_date = now()
FROM paymentTransCustomerForDeleteRow r
WHERE r.rownumber>1 AND prx_open_transaction.transaction_id = r.id;

UPDATE prx_open_transaction o
SET
	amount = t.amount
FROM prx_transaction t
WHERE t.id = o.transaction_id AND t.deleted_by IS NULL AND o.deleted_by IS NULL 
	AND t.customer_number IN (SELECT DISTINCT r.customer_number 
					FROM paymentTransCustomerForDeleteRow r);
*/