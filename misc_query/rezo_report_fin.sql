-- update prx_payment
-- set status = 'SHADOW', is_transaction = null
-- where id in (select id from prx_payment_bk231011);
DO $$
DECLARE 
	$sDate date := now();
	$eDate date := now() + INTERVAL '1 month';
BEGIN 
/*	
	SET sDate:='03-09-2023';
	set eDate:='04-09-2023';*/

	SELECT cct.name AS "section", 
		tt.name AS operation, 
		c.activity AS activity, 
		CASE
	           	WHEN c.is_legal = TRUE THEN 'არასაყოფაცხოვრებო'
			ELSE 'საყოფაცხოვრებო'
	      END AS "category", 
	      tr.tariff_number AS "tariff", 
	      sum(st.amount) AS amount, 
	      sum(tr.kilowatt_hour) AS killowatt_hour, 
	      p.bank_account AS "bank_account", 
	      CASE
			WHEN c.category = 'კომერციული -18% დღგ' THEN 18
	           	WHEN c.category = 'საბიუჯეტო -18% დღგ' THEN 18
			WHEN c.category = 'კომერციული - ნულოვანი დღგ' THEN 0
			WHEN c.category = 'საბიუჯეტო - ნულოვანი დღგ' THEN 0
			WHEN c.category = 'კომერციული -განთავისუფლებული დღგ გადასახადისაგან' THEN 0
			WHEN c.category = 'საერთო სარგებლობის' THEN 0
			WHEN c.category = 'ლტოლვილები' THEN 0
			WHEN c.category = 'მოსახლეობა -18% დღგ' THEN 0
			WHEN c.category = 'მოსახლეობა - ნულოვანი დღგ' THEN 0
			ELSE 0
	      END AS "vat", 
	      c.category AS sector, 
	      m.voltage AS voltage, 
	      tr.step AS step, 
	      CASE
		      WHEN c.category = 'კომერციული -18% დღგ' THEN sum(st.amount) * 18 / 100
			WHEN c.category = 'საბიუჯეტო -18% დღგ' THEN sum(st.amount) * 18 / 100
			WHEN c.category = 'კომერციული - ნულოვანი დღგ' THEN sum(st.amount)
			WHEN c.category = 'საბიუჯეტო - ნულოვანი დღგ' THEN sum(st.amount)
			WHEN c.category = 'კომერციული -განთავისუფლებული დღგ გადასახადისაგან' THEN sum(st.amount)
			WHEN c.category = 'საერთო სარგებლობის' THEN sum(st.amount)
			WHEN c.category = 'ლტოლვილები' THEN sum(st.amount)
			WHEN c.category = 'მოსახლეობა -18% დღგ' THEN sum(st.amount)
			WHEN c.category = 'მოსახლეობა - ნულოვანი დღგ' THEN sum(st.amount)
			ELSE 0
	      END AS "vat_amount"
	FROM prx_settle_transaction st
	JOIN tempGadaxdisReporti t ON st.transaction_id = t.id
	JOIN prx_transaction tr ON st.transaction_id = tr.id
	LEFT OUTER JOIN prx_customer_contract_type cct ON cct.id = st.account_type_id
	JOIN prx_transaction_type_combinati ttc ON ttc.id = tr.trans_type_combination_id
	JOIN prx_transaction_type tt ON tt.id = ttc.transaction_type_id
	JOIN prx_transaction_sub_type ts ON ts.id = ttc.transaction_sub_type_id
	LEFT OUTER JOIN prx_payment p ON p.transaction_id = tr.id::TEXT
	JOIN (SELECT cc.customer_number AS customer_number, 
			cc.name AS customerName, 
			gt.name AS give_Type, 
			bc.name AS business_center, 
			cat.name AS category, 
			cc.id, 
			cat.vat_type, 
			cat.is_legal, 
			ca.name AS activity
		FROM prx_customer cc
		LEFT OUTER JOIN prx_give_type gt ON gt.id = cc.give_type_id
		LEFT OUTER JOIN prx_business_center bc ON bc.id = cc.business_center_id
		LEFT OUTER JOIN prx_customer_category cat ON cat.id = cc.category_id
		LEFT OUTER JOIN prx_category ca ON ca.id = cc.cust_category_id
		WHERE cc.deleted_by IS NULL AND gt.deleted_by IS NULL AND bc.deleted_by IS NULL AND cat.deleted_by IS NULL) c ON 																	tr.customer_id = c.id
	LEFT OUTER JOIN (SELECT met.code, 
					tl.start_killowat, 
					tl.end_killowat, 
					met.voltage, 
					tl.step_number AS Step
				FROM prx_counter met
				JOIN prx_tariff tr ON tr.id = met.tariff_id
				JOIN prx_tariff_line tl ON tl.tariff_id = tr.id
				WHERE met.deleted_by IS NULL  AND tr.deleted_by IS NULL AND tl.deleted_by IS NULL 
				ORDER BY met.code, tl.start_killowat) AS m ON tr.counter_number = m.code AND abs(tr.kilowatt_hour) > 						m.start_killowat AND abs(tr.kilowatt_hour) <= m.end_killowat
	WHERE st.deleted_by IS NULL AND st.account_type_id != '74a4b43c-2bb1-1321-b7f2-ba06dadc72ae'
	GROUP BY cct.name, 
		tt.name, 
		tr.tariff_number, 
		p.bank_account, 
		vat, 
		c.activity, 
		c.category, 
		tt.name, 
		m.voltage, 
		tr.step, 
		c.is_legal, 
		c.activity
	UNION
	SELECT cct.name AS "section", 
		tt.name AS operation, 
		c.activity AS activity, 
		CASE
	           WHEN c.is_legal = TRUE THEN 'არასაყოფაცხოვრებო'
	           ELSE 'საყოფაცხოვრებო'
	      END AS "category", 
	      tr.tariff_number AS "tariff", 
	      sum(st.amount) AS amount, 
	      sum(tr.kilowatt_hour) AS killowatt_hour, 
	      p.bank_account AS "bank_account", 
	      CASE
	      	WHEN c.category = 'კომერციული -18% დღგ' THEN 18
			WHEN c.category = 'საბიუჯეტო -18% დღგ' THEN 18
			WHEN c.category = 'კომერციული - ნულოვანი დღგ' THEN 0
			WHEN c.category = 'საბიუჯეტო - ნულოვანი დღგ' THEN 0
			WHEN c.category = 'კომერციული -განთავისუფლებული დღგ გადასახადისაგან' THEN 0
			WHEN c.category = 'საერთო სარგებლობის' THEN 0
			WHEN c.category = 'ლტოლვილები' THEN 0
			WHEN c.category = 'მოსახლეობა -18% დღგ' THEN 0
			WHEN c.category = 'მოსახლეობა - ნულოვანი დღგ' THEN 0
			ELSE 0
	      END AS "vat", 
	      c.category AS sector, 
	      m.voltage AS voltage, 
	      tr.step AS step, 
	      CASE
			WHEN c.category = 'კომერციული -18% დღგ' THEN sum(st.amount) * 18 / 100
			WHEN c.category = 'საბიუჯეტო -18% დღგ' THEN sum(st.amount) * 18 / 100
			WHEN c.category = 'კომერციული - ნულოვანი დღგ' THEN sum(st.amount)
			WHEN c.category = 'საბიუჯეტო - ნულოვანი დღგ' THEN sum(st.amount)
			WHEN c.category = 'კომერციული -განთავისუფლებული დღგ გადასახადისაგან' THEN sum(st.amount)
			WHEN c.category = 'საერთო სარგებლობის' THEN sum(st.amount)
			WHEN c.category = 'ლტოლვილები' THEN sum(st.amount)
			WHEN c.category = 'მოსახლეობა -18% დღგ' THEN sum(st.amount)
			WHEN c.category = 'მოსახლეობა - ნულოვანი დღგ' THEN sum(st.amount)
			ELSE 0
	     END AS "vat_amount"
	FROM prx_open_transaction st 
	JOIN tempGadaxdisReporti t ON st.transaction_id = t.id
	JOIN prx_transaction tr ON st.transaction_id = tr.id
	LEFT OUTER JOIN prx_customer_contract_type cct ON cct.id = st.account_type_id
	JOIN prx_transaction_type_combinati ttc ON ttc.id = tr.trans_type_combination_id
	JOIN prx_transaction_type tt ON tt.id = ttc.transaction_type_id
	JOIN prx_transaction_sub_type ts ON ts.id = ttc.transaction_sub_type_id
	LEFT OUTER JOIN prx_payment p ON p.transaction_id = tr.id::TEXT
	JOIN (SELECT cc.customer_number AS customer_number, 
			cc.name AS customerName, 
			gt.name AS give_Type, 
			bc.name AS business_center, 
			cat.name AS category, 
			cc.id, 
			cat.vat_type, 
			cat.is_legal, 
			ca.name AS activity
		FROM prx_customer cc
		LEFT OUTER JOIN prx_give_type gt ON gt.id = cc.give_type_id
		LEFT OUTER JOIN prx_business_center bc ON bc.id = cc.business_center_id
		LEFT OUTER JOIN prx_customer_category cat ON cat.id = cc.category_id
		LEFT OUTER JOIN prx_category ca ON ca.id = cc.cust_category_id
		WHERE cc.deleted_by IS NULL AND gt.deleted_by IS NULL AND bc.deleted_by IS NULL AND cat.deleted_by IS NULL) c ON
											tr.customer_id = c.id
	LEFT OUTER JOIN (SELECT met.code, 
					tl.start_killowat, 
					tl.end_killowat, 
					met.voltage, 
					tl.step_number AS Step
				FROM prx_counter met
				JOIN prx_tariff tr ON tr.id = met.tariff_id
				JOIN prx_tariff_line tl ON tl.tariff_id = tr.id
				WHERE met.deleted_by IS NULL AND tr.deleted_by IS NULL AND tl.deleted_by IS NULL
				ORDER BY met.code, 
					tl.start_killowat) AS m ON tr.counter_number = m.code AND abs(tr.kilowatt_hour) > m.start_killowat AND
	                            abs(tr.kilowatt_hour) <= m.end_killowat
	WHERE st.deleted_by IS NULL AND st.account_type_id != '74a4b43c-2bb1-1321-b7f2-ba06dadc72ae'
	GROUP BY cct.name, 
		tt.name, 
		tr.tariff_number, 
		p.bank_account, 
		vat, 
		c.activity, 
		c.category, 
		tt.name, 
		m.voltage, 
		tr.step, 
		c.is_legal, 
		c.activity
	UNION
	SELECT cct.name AS "section", 
		tt.name AS operation, 
		c.activity AS activity, 
		CASE
	           	WHEN c.is_legal = TRUE THEN 'არასაყოფაცხოვრებო'
			ELSE 'საყოფაცხოვრებო'
	      END AS "category", 
	      t.tariff_number AS "tariff", 
	      sum(t.amount) AS amount, 
	      sum(t.kilowatt_hour) AS killowatt_hour, 
	      p.bank_account AS "bank_account", 
	      CASE
	      	WHEN c.category = 'კომერციული -18% დღგ' THEN 18
			WHEN c.category = 'საბიუჯეტო -18% დღგ' THEN 18
			WHEN c.category = 'კომერციული - ნულოვანი დღგ' THEN 0
			WHEN c.category = 'საბიუჯეტო - ნულოვანი დღგ' THEN 0
			WHEN c.category = 'კომერციული -განთავისუფლებული დღგ გადასახადისაგან' THEN 0
			WHEN c.category = 'საერთო სარგებლობის' THEN 0
			WHEN c.category = 'ლტოლვილები' THEN 0
			WHEN c.category = 'მოსახლეობა -18% დღგ' THEN 0
			WHEN c.category = 'მოსახლეობა - ნულოვანი დღგ' THEN 0
			ELSE 0
	      END AS "vat", 
	      c.category AS sector, 
	      st.voltage AS voltage, 
	      t.step AS step, 
	      CASE
			WHEN c.category = 'კომერციული -18% დღგ' THEN sum(t.amount) * 18 / 100
			WHEN c.category = 'საბიუჯეტო -18% დღგ' THEN sum(t.amount) * 18 / 100
			WHEN c.category = 'კომერციული - ნულოვანი დღგ' THEN sum(t.amount)
			WHEN c.category = 'საბიუჯეტო - ნულოვანი დღგ' THEN sum(t.amount)
			WHEN c.category = 'კომერციული -განთავისუფლებული დღგ გადასახადისაგან' THEN sum(t.amount)
			WHEN c.category = 'საერთო სარგებლობის' THEN sum(t.amount)
			WHEN c.category = 'ლტოლვილები' THEN sum(t.amount)
			WHEN c.category = 'მოსახლეობა -18% დღგ' THEN sum(t.amount)
			WHEN c.category = 'მოსახლეობა - ნულოვანი დღგ' THEN sum(t.amount)
			ELSE 0
	     END AS "vat_amount"
	FROM prx_transaction t
	JOIN (SELECT rc.combination_id, 
			rc.group_code AS name
		FROM PRX_REP_CON_TURN_OVER_BY_MONTH rc
		WHERE rc.use_add32 = TRUE AND rc.deleted_by IS NULL) AS combi ON t.trans_type_combination_id = combi.combination_id
	JOIN prx_transaction_type_combinati ttc ON ttc.id = t.trans_type_combination_id
	JOIN prx_transaction_type tt ON tt.id = ttc.transaction_type_id
	JOIN prx_transaction_sub_type ts ON ts.id = ttc.transaction_sub_type_id
	JOIN prx_customer_contract_type cct ON cct.id = t.account_type_id
	LEFT OUTER JOIN prx_payment p ON p.transaction_id = t.id::TEXT
	JOIN (SELECT cc.customer_number AS customer_number, 
			cc.name AS customerName, 
			gt.name AS give_Type, 
			bc.name AS business_center, 
			cat.name AS category, 
			cc.id, 
			cat.vat_type, 
			cat.is_legal, 
			ca.name AS activity
		FROM prx_customer cc
		LEFT OUTER JOIN prx_give_type gt ON gt.id = cc.give_type_id
		LEFT OUTER JOIN prx_business_center bc ON bc.id = cc.business_center_id
		LEFT OUTER JOIN prx_customer_category cat ON cat.id = cc.category_id
		LEFT OUTER JOIN prx_category ca ON ca.id = cc.cust_category_id
		WHERE cc.deleted_by IS NULL AND gt.deleted_by IS NULL AND bc.deleted_by IS NULL AND cat.deleted_by IS NULL) c ON
												t.customer_id = c.id
	LEFT OUTER JOIN (SELECT met.code, 
					tl.start_killowat, 
					tl.end_killowat, 
					met.voltage, 
					tl.step_number AS Step
				FROM prx_counter met
				JOIN prx_tariff tr ON tr.id = met.tariff_id
				JOIN prx_tariff_line tl ON tl.tariff_id = tr.id
				WHERE met.deleted_by IS NULL AND tr.deleted_by IS NULL AND tl.deleted_by IS NULL
				ORDER BY met.code, 
					tl.start_killowat) AS st ON t.counter_number = st.code
	WHERE t.created_date BETWEEN $sDate::date AND $eDate::date AND t.trans_type_combination_id != 'df95642d-0f4c-cd63-7689-8b7d4fb80d41' AND t.deleted_by IS NULL
	GROUP BY c.give_type, 
		c.category, 
		t.step, 
		st.voltage, 
		vat, 
		cct.name, 
		tt.name, 
		c.is_legal, 
		t.tariff_number, 
		p.bank_account, 
		c.activity
	UNION
	SELECT t.section AS "section", 
		t.operation AS "operation", 
		c.activity AS "activity", 
		CASE
	           WHEN c.is_legal = TRUE THEN 'არასაყოფაცხოვრებო'
		ELSE 'საყოფაცხოვრებო'
	      END AS "category", 
	      t.tariff_number AS "tariff", 
	      sum(t.amount) AS amount, 
	      sum(t.kilowatt_hour) AS killowatt_hour, 
	      t.bank_account AS "bank_account", 
	      CASE
			WHEN c.category = 'კომერციული -18% დღგ' THEN 18
			WHEN c.category = 'საბიუჯეტო -18% დღგ' THEN 18
			WHEN c.category = 'კომერციული - ნულოვანი დღგ' THEN 0
			WHEN c.category = 'საბიუჯეტო - ნულოვანი დღგ' THEN 0
			WHEN c.category = 'კომერციული -განთავისუფლებული დღგ გადასახადისაგან' THEN 0
			WHEN c.category = 'საერთო სარგებლობის' THEN 0
			WHEN c.category = 'ლტოლვილები' THEN 0
			WHEN c.category = 'მოსახლეობა -18% დღგ' THEN 0
			WHEN c.category = 'მოსახლეობა - ნულოვანი დღგ' THEN 0
			ELSE 0
	      END AS "vat", 
	      c.category AS sector, 
	      st.voltage AS voltage, 
	      t.step AS step, 
	      CASE
			WHEN c.category = 'კომერციული -18% დღგ' THEN sum(t.amount) * 18 / 100
			WHEN c.category = 'საბიუჯეტო -18% დღგ' THEN sum(t.amount) * 18 / 100
			WHEN c.category = 'კომერციული - ნულოვანი დღგ' THEN sum(t.amount)
			WHEN c.category = 'საბიუჯეტო - ნულოვანი დღგ' THEN sum(t.amount)
			WHEN c.category = 'კომერციული -განთავისუფლებული დღგ გადასახადისაგან' THEN sum(t.amount)
			WHEN c.category = 'საერთო სარგებლობის' THEN sum(t.amount)
			WHEN c.category = 'ლტოლვილები' THEN sum(t.amount)
			WHEN c.category = 'მოსახლეობა -18% დღგ' THEN sum(t.amount)
			WHEN c.category = 'მოსახლეობა - ნულოვანი დღგ' THEN sum(t.amount)
			ELSE 0
	      END AS "vat_amount"
	FROM(SELECT t.amount, 
			t.kilowatt_hour, 
			t.customer_id, 
			t.counter_number, 
			t.created_date, 
			t.trans_type_combination_id, 
			t.deleted_by, 
			cct.name AS "section", 
			tt.name AS operation, 
			t.tariff_number, 
			p.bank_account, 
			t.step
		FROM prx_transaction t
		JOIN prx_transaction_type_combinati ttc ON ttc.id = t.trans_type_combination_id
		JOIN prx_transaction_type tt ON tt.id = ttc.transaction_type_id
		JOIN prx_transaction_sub_type ts ON ts.id = ttc.transaction_sub_type_id
		JOIN prx_customer_contract_type cct ON cct.id = t.account_type_id
		LEFT OUTER JOIN prx_payment p ON p.transaction_id = t.id::TEXT
		WHERE t.deleted_by IS NULL AND (t.kilowatt_hour != 0 AND t.kilowatt_hour IS NOT NULL) AND (t.amount != 0 AND t.amount IS 					NOT NULL)) t
	JOIN (SELECT cc.customer_number AS customer_number, 
			cc.name AS customerName, 
			gt.name AS give_Type, 
			bc.name AS business_center, 
			cat.name AS category, 
			cc.id, 
			cat.vat_type, 
			cat.is_legal, 
			ca.name AS activity
		FROM prx_customer cc
		LEFT OUTER JOIN prx_give_type gt ON gt.id = cc.give_type_id
		LEFT OUTER JOIN prx_business_center bc ON bc.id = cc.business_center_id
		LEFT OUTER JOIN prx_customer_category cat ON cat.id = cc.category_id
		LEFT OUTER JOIN prx_category ca ON ca.id = cc.cust_category_id
		WHERE cc.deleted_by IS NULL AND gt.deleted_by IS NULL AND bc.deleted_by IS NULL AND cat.deleted_by IS NULL) c ON 								t.customer_id = c.id
	LEFT OUTER JOIN (SELECT met.code, 
					tl.start_killowat, 
					tl.end_killowat, 
					met.voltage, 
					tl.step_number AS Step
				FROM prx_counter met
				JOIN prx_tariff tr ON tr.id = met.tariff_id
				JOIN prx_tariff_line tl ON tl.tariff_id = tr.id
				WHERE met.deleted_by IS NULL AND tr.deleted_by IS NULL AND tl.deleted_by IS NULL
				ORDER BY met.code, 
					tl.start_killowat) AS st ON t.counter_number = st.code AND abs(t.kilowatt_hour) > st.start_killowat AND
	                            abs(t.kilowatt_hour) <= st.end_killowat
	WHERE t.created_date BETWEEN ${sDate}::date AND ${eDate}::date AND t.deleted_by IS NULL
	GROUP BY c.give_type, 
		c.category, 
		t.step, 
		st.voltage, 
		vat, 
		t.section, 
		t.operation, 
		c.is_legal, 
		t.tariff_number, 
		t.bank_account, 
		c.activity;

END $$;
