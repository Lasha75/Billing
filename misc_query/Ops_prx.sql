SELECT
	 ptt."name"  || ' ' || ptst."name" op,
	 ptt."name" opType,
	 ptst."name" opSubType,
	 pttc.id combId,
	 pttc.operation_key,
	ptt.id opId,
	ptt.code opCode,
	ptst."name" opSubType,
	ptst.id opSubId,
	ptst.code subOpCode,
	pttc.id combId,
	pttc.created_by, 
	ptt.created_by,
	ptst.created_by 
FROM  prx_transaction_type_combinati pttc 
JOIN prx_transaction_type ptt ON ptt.id = pttc.transaction_type_id
JOIN prx_transaction_sub_type ptst ON ptst.id = pttc.transaction_sub_type_id
WHERE pttc.deleted_by IS NULL AND ptt.deleted_by IS NULL and ptst.deleted_by IS NULL
and pttc.id in ('de579ca8-118d-0f99-1012-c2e6b3a02307',
                                                       'ce5ae29e-cf2a-1053-e58e-c16bf1063670',
                                                       '51a53157-c480-2e09-fb94-a9625dc12e32',
                                                       '61922bb4-daa5-9696-c7b5-69609e027171',
                                                       'a4e37496-cbb1-51bb-0a94-32bc07dd3710',
                                                       '92064740-2471-1450-a569-ac4b7efe9a0c')
ORDER BY opType;

