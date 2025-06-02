BEGIN;

DO $$
DECLARE cn prx_customer.customer_number%TYPE;
DECLARE rc int := 0;
DECLARE rcs int := 0;
BEGIN
	FOR cn IN /*SELECT cu.customer_number FROM prx_customer cu LIMIT 10*/
		SELECT custnum FROM "LK".tmp_lk WHERE done = FALSE LIMIT 1000
	LOOP
	WITH cr as(
		UPDATE prx_transaction tr
		SET	telasi_acccount_id = met.telasi_acc_id, 
			counter_serial_number = met.serial_number
		FROM prx_counter met
		WHERE met.telasi_acc_key = tr.tl_acc_key
		AND tr.deleted_by IS NULL
--		AND (tr.telasi_acccount_id IS NULL OR  tr.counter_serial_number IS NULL)
		AND tr.customer_number = cn
		RETURNING 1)
		
		SELECT count(*) INTO rc FROM cr;
		rcs := rcs + rc;

		UPDATE "LK".tmp_lk SET done = TRUE  WHERE custnum = cn;
	END LOOP;
	
	RAISE NOTICE '%', rcs;
	
EXCEPTION
WHEN OTHERS THEN
	RAISE NOTICE '% %', SQLERRM, SQLSTATE;
	ROLLBACK;
END;

$$ LANGUAGE 'plpgsql';

COMMIT;

    