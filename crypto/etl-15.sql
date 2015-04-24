
-- -----------------------------------------------------------------------------
-- 1.5. Decrypt/Extract IPN
-- -----------------------------------------------------------------------------

create or replace function ETL_15() returns integer as $$
declare
    _nrows integer;
begin

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

    select count(*) into _nrows from _ct_IPN;
    return _nrows;

end;
$$ language plpgsql;
