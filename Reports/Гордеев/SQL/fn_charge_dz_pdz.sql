create or replace function "LK".fn_charge_dz_pdz(IN p_period text)
    returns TABLE
            ( cust character varying,
              kwt      numeric,
              charge_amount   numeric,
              dz       numeric,
              pdz      numeric)
    language plpgsql
as
$$
BEGIN
    drop table if exists ch_dz;

    create temporary table ch_dz
            ( cust_num character varying,
              ch_kwt      numeric,
              ch_amount   numeric,
              deb_zad       numeric,
              p_deb_zad      numeric) on commit drop;

    with dz as (select customer_number,
                       amount_31_91 + amount_92_182 + amount_183_273 + amount_274_365 + amount_366_731 +
                       amount_732_1097 + amount_1098 pdz,
                       amount as   dz
                from prx_aging_report
                where period_ = p_period),
         dt_range as (select min(bl.read_date) min_dt,
                             max(bl.read_date) max_dt
                      from prx_block_schedule bl
                      where to_char(bl.read_date, 'YYYY-MM') = p_period and deleted_by is null),
         charge as (select tr.customer_number    cust,
                           sum(tr.kilowatt_hour) as kwt,
                           sum(tr.amount)       as  amount
                    from prx_transaction tr
                    join dt_range on 1 = 1
                    where tr.kilowatt_hour >= 0
                      and tr.deleted_by is null
                      and tr.trans_date between min_dt and max_dt
                    group by tr.customer_number)

    insert into ch_dz
    select dz.customer_number,
           coalesce(ch.kwt, 0) kwt,
           coalesce(ch.amount, 0) amount,
           coalesce(dz.dz, 0) dz,
           coalesce(dz.pdz, 0) pdz
    from charge ch
    right join dz on dz.customer_number = ch.cust; --right იმიტოა, რო dz-ში უფრო მეტი ინფორმაციაა აბონენტზე, ვიდრე ტრანზაქციებში ერთიდაიგივე პერიოდისთვის

     RETURN QUERY
        select cust_num,
              ch_kwt,
              ch_amount,
              deb_zad,
              p_deb_zad
        from ch_dz;

    exception
    when others then
--         rollback;
    raise notice 'fn_charge_dz_pdz Exception %', SQLERRM;
END ;
$$;

alter function "LK".fn_charge_dz_pdz(text) owner to "Billing";

