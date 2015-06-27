

-- -----------------------------------------------------------------------------
-- 1.1. Decrypt/Extract Members
-- -----------------------------------------------------------------------------
create or replace function etl1() returns integer as $$
begin

    raise notice 'Extracting Members';
    DROP TABLE IF EXISTS _ct_Members;

    CREATE TABLE _ct_Members AS SELECT
        mid,
        cid,
        h_passwd,
        fdecrypt(x_userid)      as userid,
        fdecrypt(x_email)       as email,
        h_profilepic,
        fdecrypt(x_fname)       as fname,
        fdecrypt(x_mi)          as mi,
        fdecrypt(x_lname)       as lname,
        fdecrypt(x_address1)    as address1,
        fdecrypt(x_address2)    as address2,
        fdecrypt(x_city)        as city,
        fdecrypt(x_state)       as state,
        fdecrypt(x_postalcode)  as postalcode,
        fdecrypt(x_country)     as country,
        fdecrypt(x_phone)       as phone,
        alerttype,
        fdecrypt(x_alertphone)  as alertphone,
        fdecrypt(x_alertemail)  as alertemail,
        status,
        pwstatus,
        userlevel,
        tooltips,
        isadmin,
        logincount,
        created,
        updated
    from Members;



-- -----------------------------------------------------------------------------
-- 1.2. Decrypt/Extract Folders
-- -----------------------------------------------------------------------------

    raise notice 'Extracting Folders';
    DROP TABLE IF EXISTS _ct_Folders;

    CREATE TABLE _ct_Folders AS SELECT
        uid,
        mid,
        cid,
        fdecrypt(x_name)    as name,
        fdecrypt(x_desc)    as desc,
        app_uid,
        created,
        updated
    from Folders;



-- -----------------------------------------------------------------------------
-- 1.3. Decrypt/Extract Files
-- -----------------------------------------------------------------------------
    raise notice 'Extracting Files';

    DROP TABLE IF EXISTS _ct_Files;

    CREATE TABLE _ct_Files AS SELECT
        uid,
        folder_uid,
        mid,
        item_uid,
        fdecrypt(x_name)        as name,
        fdecrypt(x_desc)        as desc,
        content_type,
        isprofile,
        category,
        fdecrypt(x_form_data)   as form_data,
        modified_by,
        created,
        updated
    from Files;




-- -----------------------------------------------------------------------------
-- 1.4. Decrypt/Extract Items
-- -----------------------------------------------------------------------------

    raise notice 'Extracting Itemss';

    DROP TABLE IF EXISTS _ct_Items;

    CREATE TABLE _ct_Items as SELECT
        uid,
        mid,
        cid,
        folder_uid,
        app_uid,
        itemtype,
        fdecrypt(x_name)    as name,
        fdecrypt(x_desc)    as desc,
        created,
        updated,
        modified_by
    from Items;




-- -----------------------------------------------------------------------------
-- 1.5. Decrypt/Extract IPN
-- -----------------------------------------------------------------------------

    raise notice 'Extracting IPNs';

    DROP TABLE IF EXISTS _ct_IPN;

    CREATE TABLE _ct_IPN AS SELECT
        UID,
        IPNReceived,
        fdecrypt(x_business)        as business,
        fdecrypt(x_receiver_email)  as receiver_email,
        fdecrypt(x_item_name)       as item_name,
        fdecrypt(x_item_number)     as item_number,
        quantity,
        fdecrypt(x_invoice)         as invoice,
        fdecrypt(x_custom)          as custom,
        fdecrypt(x_memo)            as memo,
        tax,
        fdecrypt(x_payment_status)  as payment_status,
        fdecrypt(x_pending_reason)  as pending_reason,
        fdecrypt(x_reason_code)     as reason_code,
        fdecrypt(x_payment_date)    as payment_date,
        fdecrypt(x_txn_id)          as txn_id,
        fdecrypt(x_txn_type)        as txn_type,
        fdecrypt(x_payment_type)    as payment_type,
        mc_gross,
        mc_fee,
        mc_currency,
        settle_amount,
        settle_currency,
        exchange_rate,
        payment_gross,
        payment_fee,
        subscr_date,
        subscr_effective,
        period1,
        period2,
        period3,
        amount1,
        amount2,
        amount3,
        mc_amount1,
        mc_amount2,
        mc_amount3,
        recurring,
        reattempt,
        retry_at,
        recur_times,
        fdecrypt(x_username)        as username,
        fdecrypt(x_password)        as password,
        fdecrypt(x_subscr_id)       as subscr_id,
        fdecrypt(x_first_name)      as first_name,
        fdecrypt(x_last_name)       as last_name,
        fdecrypt(x_address_name)    as address_name,
        fdecrypt(x_address_street)  as address_street,
        fdecrypt(x_address_city)    as address_city,
        fdecrypt(x_address_state)   as address_state,
        fdecrypt(x_address_zip)     as address_zip,
        fdecrypt(x_address_country) as address_country,
        fdecrypt(x_address_status)  as address_status,
        fdecrypt(x_payer_email)     as payer_email,
        fdecrypt(x_payer_id)        as payer_id,
        fdecrypt(x_payer_status)    as payer_status,
        notify_version,
        verify_sign,
        post_status,
        post_response,
        HAStatus
    from IPN;

    return 0;

end; $$ language plpgsql;
