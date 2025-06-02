create or replace procedure "LK".prc_bill_delete(in p_cust_num text, in p_bill_date date, out p_upd_id smallint,
                                                 out p_upd_opn_id smallint)
    language plpgsql
as
$$
declare
    v_rec_bill record   = null;
    v_rec_tran record   = null;
    v_cnt      smallint = 1;
/*    v_upd_id     smallint = 0;
    v_upd_opn_id smallint = 0;*/
begin
    p_upd_id = 0;
    p_upd_opn_id = 0;

    for v_rec_bill in select bl.id,
                             bl.customer_id,
                             bl.counter_id,
                             bl.generation_id,
                             bl.amount,
                             bl.counter_serial_number
                      from prx_bill bl
                      where customer_number = p_cust_num
                        and cast(bl.created_date as date) = p_bill_date
                        and deleted_by is null
        loop
            raise notice 'prx_bill. metter serial: %  amount: % bill id: % cust id: % generation id:%  metter id: % ', v_rec_bill.counter_serial_number, v_rec_bill.amount, v_rec_bill.id, v_rec_bill.customer_id, v_rec_bill.generation_id, v_rec_bill.counter_id;

            raise notice 'Start update bill % #%', v_rec_bill.id, v_cnt;

            update prx_bill
            set deleted_by   = 'lgaprindashvili',
                deleted_date = now()
            where id = v_rec_bill.id;

            raise notice 'End update bill % #%', v_rec_bill.id, v_cnt;

            v_cnt = v_cnt + 1;
            raise notice '---- next bill № % ----', v_cnt;

        end loop;

    raise notice '-----------------------------------------------------------------------------';

    for v_rec_tran in
        select *
        from prx_bill_used_transaction
        where customer_id = v_rec_bill.customer_id
--                       and counter_number = v_rec_bill.counter_serial_number
          and generation_id = v_rec_bill.generation_id
          and cast(created_date as date) = p_bill_date
        loop
            raise notice 'prx_bill_used_transaction id: %  transaction id: %', v_rec_tran.id, v_rec_tran.transaction_id;

            raise notice 'Start update trans %' , v_rec_tran.transaction_id;

            update public.prx_transaction
            set used_in_bill       = null,
                last_modified_by   = 'lgaprindashvili',
                last_modified_date = now()
            where id = v_rec_tran.transaction_id;
            p_upd_id = p_upd_id + 1;
            raise notice 'Updated trans %', p_upd_id::text;

            update public.prx_open_transaction
            set used_in_bill       = null,
                last_modified_by   = 'lgaprindashvili',
                last_modified_date = now()
            where transaction_id = v_rec_tran.transaction_id;
            p_upd_opn_id = p_upd_opn_id + 1;
            raise notice 'Updated open trans %', p_upd_opn_id::text;

            raise notice 'End update trans %' , v_rec_tran.transaction_id;
        end loop;

exception
    when others then
--             rollback;
        raise exception 'Outer Exception % %', SQLSTATE, SQLERRM;
end;
$$;
alter procedure "LK".prc_bill_delete(text, date, smallint, smallint) owner to "Billing";



/*lgaprindashvili*/
/*
select bl.created_date,
    bl.bill_number,
    bl.customer_number,
    bl.amount,
    deleted_by,
    bl.deleted_date,
    *
from prx_bill bl
where  bl.id in ('3c8d2887-bf6c-4bb4-810b-9d3c1c88f983'),
'1f8dc474-02f3-40e6-8f2c-2e5afe987922'),
'6966f2fa-7390-405e-9c79-4ac876a52f04',
'6afc5320-cb2e-4a09-a563-2d27542b9fb4',
'4468720b-dc93-4311-a71d-e2694a02e0a5',
'4d8f33fb-3b4f-45a6-8ba6-16769f2e7216',
'3f196bb3-4968-482f-9d4c-8e88853262ee',
'b4b9bb7a-6b62-4c83-8ab5-932195751584',
'af870acc-87a5-4da3-aa6b-25e9e99ca9a5',
'301c7716-c7eb-42d9-adde-6c7d75415974',
'28246754-9459-4d44-832a-5d889f673b2a'
);
----------------------------

select used_in_bill, created_date, customer_number, amount, *
from prx_transaction
where id in ('2f6e02e4-15ab-42e6-a103-e6e0d4929504',
'e96ffb96-dd76-46c7-a02f-372b6ee20796',
'ef68b96d-e023-4fa7-92fb-896875c489eb'),
'0c32aa04-fb79-45cc-a982-e7bb0a370ab7',
'0c8c5d15-1521-46ec-ac14-98325106324a',
'11464523-bb55-4f16-8302-5b30ae434919',
'1bfa1976-20d4-41b0-ad3c-e93c0e2845a8',
'25730635-4566-4302-ae6a-4abd2ac66272',
'25ed5620-786c-4ee6-bd48-e96de62d7821',
'262f980b-bed1-46a9-88fb-0fd96cc3616b',
'281c687b-da06-49c7-b1c6-2923bbbdf727',
'330b5b0d-96ac-4864-9494-9fd816177c77',
'338ff158-fb4b-404c-84fc-3614e8b8fbd6',
'37bba888-52d1-44b9-b7bc-0ce059280ec1',
'39fcaba1-99a1-4621-9bbc-d40da98b1e1e',
'3c4f5f24-bab3-458d-8afe-59589ab6a227',
'40a40555-2465-4194-913e-09de04086915',
'441abb1e-9c1c-40b7-8a9b-73594e9abe9e',
'4b6d5267-e7a9-4948-85bb-d995a65d5dcc',
'54939e81-8a3c-42d2-95e3-785c1f70a467',
'54a85888-0a39-471a-b7d3-2a6e1a66508b',
'55b29a49-27be-4895-8284-80cee98de948',
'5721b19e-18d0-4760-965e-84a5d9b63834',
'597f030b-0f8d-47ac-ba64-7c848f6335b1',
'606ed999-1653-41c3-8229-3d5f9f7d03a4',
'622e51df-b38b-4146-8c8b-a2d7f392213a',
'6f43bc67-030c-420c-99f3-44570e444902',
'7f5071e7-2807-40f8-8f7f-7b2389ce831f',
'83043650-a6c4-449e-9be7-cd44fdfe8ea8',
'831470c3-ffc3-422e-b504-ace0c24e9d26',
'8917775e-dd2f-4223-8dd4-d28ef20aab9e',
'8a5d8876-61c5-449e-ba57-13c98f4d4be9',
'8bd57054-08d6-47d7-9b67-20647d605c9b',
'92ac98e9-1b3e-4848-a4b4-512f31e8440f',
'9b1caaf6-19f4-4670-840d-0158dbf81a2c',
'a54dedea-70e4-4c84-8279-2f071410c0ab',
'abd5c22c-7718-4d96-96dd-294571fe36fa',
'ac723bae-6eed-43ab-b6d9-803a2ba356b9',
'b7e66b12-8572-4c6a-84f0-17e13bb17c54',
'bae04f2e-e25d-47f4-a464-92c1c19fc002',
'c1c931c8-040f-409a-8597-9ca33f4a0ef5',
'c2ddcaf8-1d2f-4c8f-8301-0f8dc58baa04',
'c85bb300-16ae-4e64-b143-9cabab8c0261',
'cc7bf12c-bb85-4026-a24c-f0302fa6374b',
'ce607f61-42e1-4024-821c-c5e5d7da6779',
'd4555469-8e0f-4d5f-b29f-01d71a203516',
'd8adefe5-972c-4167-b03f-c5a5c173d929',
'dc04b5e3-a7b1-1e11-37ac-70daa741c189',
'ed8a9259-8bd8-475b-8f2a-9da621fa2f35',
'e2ca9e11-17ed-476b-a04e-8b8fcce76153')


update prx_transaction
set used_in_bill = null
where id in ('0b1ef8ab-2ca5-4156-bded-92877aff8abe',
'11ed9712-7a60-47a6-b07e-870ddc4328d5',
'1bd2b99e-461f-40ce-96fb-e9b5b76ecf1b',
'25375dd7-d92a-43f1-8690-024d080eae9a',
'32e3d827-2906-400b-a971-3519c2171b59',
'3f955074-9050-4e12-a01b-c0bd52d130bc',
'439d4139-f87a-4347-82d2-5ba4641c0927',
'b0ada23e-dd33-451a-8daf-bb0e58105a32',
'c8fc8e12-92fc-47d6-af0b-80d7e84b0a75',
'0116c75b-410a-40b9-9b3c-8fc101972030')

--------------------------

select used_in_bill, *
from prx_open_transaction
where transaction_id in ('00ab19df-f11b-40ea-94ed-ead41710b126',
'039cc9b4-2479-456a-ba56-c3d33bca4318',
'0a97b413-f8d3-4c1f-9600-4c747741005e',
'0c32aa04-fb79-45cc-a982-e7bb0a370ab7',
'0c8c5d15-1521-46ec-ac14-98325106324a',
'11464523-bb55-4f16-8302-5b30ae434919',
'1bfa1976-20d4-41b0-ad3c-e93c0e2845a8',
'25730635-4566-4302-ae6a-4abd2ac66272',
'25ed5620-786c-4ee6-bd48-e96de62d7821',
'262f980b-bed1-46a9-88fb-0fd96cc3616b',
'281c687b-da06-49c7-b1c6-2923bbbdf727',
'330b5b0d-96ac-4864-9494-9fd816177c77',
'338ff158-fb4b-404c-84fc-3614e8b8fbd6',
'37bba888-52d1-44b9-b7bc-0ce059280ec1',
'39fcaba1-99a1-4621-9bbc-d40da98b1e1e',
'3c4f5f24-bab3-458d-8afe-59589ab6a227',
'40a40555-2465-4194-913e-09de04086915',
'441abb1e-9c1c-40b7-8a9b-73594e9abe9e',
'4b6d5267-e7a9-4948-85bb-d995a65d5dcc',
'54939e81-8a3c-42d2-95e3-785c1f70a467',
'54a85888-0a39-471a-b7d3-2a6e1a66508b',
'55b29a49-27be-4895-8284-80cee98de948',
'5721b19e-18d0-4760-965e-84a5d9b63834',
'597f030b-0f8d-47ac-ba64-7c848f6335b1',
'606ed999-1653-41c3-8229-3d5f9f7d03a4',
'622e51df-b38b-4146-8c8b-a2d7f392213a',
'6f43bc67-030c-420c-99f3-44570e444902',
'7f5071e7-2807-40f8-8f7f-7b2389ce831f',
'83043650-a6c4-449e-9be7-cd44fdfe8ea8',
'831470c3-ffc3-422e-b504-ace0c24e9d26',
'8917775e-dd2f-4223-8dd4-d28ef20aab9e',
'8a5d8876-61c5-449e-ba57-13c98f4d4be9',
'8bd57054-08d6-47d7-9b67-20647d605c9b',
'92ac98e9-1b3e-4848-a4b4-512f31e8440f',
'9b1caaf6-19f4-4670-840d-0158dbf81a2c',
'a54dedea-70e4-4c84-8279-2f071410c0ab',
'abd5c22c-7718-4d96-96dd-294571fe36fa',
'ac723bae-6eed-43ab-b6d9-803a2ba356b9',
'b7e66b12-8572-4c6a-84f0-17e13bb17c54',
'bae04f2e-e25d-47f4-a464-92c1c19fc002',
'c1c931c8-040f-409a-8597-9ca33f4a0ef5',
'c2ddcaf8-1d2f-4c8f-8301-0f8dc58baa04',
'c85bb300-16ae-4e64-b143-9cabab8c0261',
'cc7bf12c-bb85-4026-a24c-f0302fa6374b',
'ce607f61-42e1-4024-821c-c5e5d7da6779',
'd4555469-8e0f-4d5f-b29f-01d71a203516',
'd8adefe5-972c-4167-b03f-c5a5c173d929',
'dc04b5e3-a7b1-1e11-37ac-70daa741c189',
'ed8a9259-8bd8-475b-8f2a-9da621fa2f35',
'e2ca9e11-17ed-476b-a04e-8b8fcce76153')

update prx_open_transaction
set used_in_bill = null
where transaction_id in ('0b1ef8ab-2ca5-4156-bded-92877aff8abe',
'11ed9712-7a60-47a6-b07e-870ddc4328d5',
'1bd2b99e-461f-40ce-96fb-e9b5b76ecf1b',
'25375dd7-d92a-43f1-8690-024d080eae9a',
'32e3d827-2906-400b-a971-3519c2171b59',
'3f955074-9050-4e12-a01b-c0bd52d130bc',
'439d4139-f87a-4347-82d2-5ba4641c0927',
'b0ada23e-dd33-451a-8daf-bb0e58105a32',
'c8fc8e12-92fc-47d6-af0b-80d7e84b0a75',
'0116c75b-410a-40b9-9b3c-8fc101972030')








select * from prx_bill_operation
    where id='268b2b14-4e7e-4472-aa34-c7c63e5edce8'

generation_id='2024.03.30.13.24.54_BILL'
      and customer_id='9e89352d-f620-da3b-a66e-e3a6d935c044'
      and counter_id='b1772f8e-4834-4e92-8cb5-04513de932c8';

select * from prx_bill_prev_period
    where generation_id='2024.04.01.13.03.46_BILL'
      and customer_id='7a9947ee-c1bc-6cab-b938-e071253a13b3';

select * from prx_bill_subsidy
where generation_id='2024.02.28.15.21.02_BILL'
      and customer_id='cbd7f8af-d2ef-cd0e-7f27-b5b6fee3473a';


select * from prx_bill_used_transaction
where transaction_id in ('03efdf89-e7b4-4770-9020-e7d431dbd597',
'46fbde53-100c-4f70-9181-92511d3e81b9',
'b6731617-4284-4dba-b883-18885f45fc20')





*/
