do
$$
    declare v_cnt bigint :=0;

    begin
        select cust_num,
               bill_date
               from "LK".lk_bill_for_delete;

        call "LK".prc_bill_delete('8151288', '2025-05-05', null, null);
        commit;
    end;
$$ LANGUAGE plpgsql;