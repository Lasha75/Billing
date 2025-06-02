CREATE OR REPLACE VIEW PRX_OPS AS SELECT  DISTINCT tr.trans_type_combination_id,
			ptt."name" || ' ' || ptst."name" oper,
			'prx_transaction_type' tt,
			ptt.id ttid, 
			ptt.code ttcode,
			ptt."name" ttname,
			'prx_transaction_sub_type' tsp,
			ptst.id tspid,
			ptst.code tspcode,
			ptst."name" tspname
		FROM prx_transaction tr
		JOIN prx_transaction_type_combinati pttc ON pttc.id = tr.trans_type_combination_id AND pttc.deleted_by IS  null
		JOIN prx_transaction_type ptt ON ptt.id = pttc.transaction_type_id AND ptt.deleted_BY IS  null
		JOIN prx_transaction_sub_type ptst ON ptst.id = pttc.transaction_sub_type_id AND ptst.deleted_BY IS  null
		WHERE tr.deleted_by IS NULL 