/*
    2015-03-31 dbrown: Created
*/

create or replace function get_ipn_range
(
    _from  timestamp default date_trunc('day',now()),  -- 12:00 am today
    _to    timestamp default now(),
    _pagesize int default 100,
    _page     int default 0
)
returns table
(
    UID             integer,
    IPNReceived     timestamp,
    business        text,
    receiver_email  text,    
    item_name       text,
    item_number     text,
    quantity        int,
    invoice         text,
    custom          text,
    memo            text,
    tax             money,
    payment_status  text,
    pending_reason  text,
    reason_code     text,
    payment_date    text,
    txn_id          text,
    txn_type        text,
    payment_type    text,
    mc_gross        money,
    mc_fee          money,
    mc_currency     char(3),
    settle_amount   money,
    settle_currency varchar(50),
    exchange_rate   double precision,
    payment_gross   money,
    payment_fee     money,
    subscr_date     varchar(50),
    subscr_effective varchar(50),
    period1         varchar(50),
    period2         varchar(50),
    period3         varchar(50),
    amount1         money,
    amount2         money,
    amount3         money,
    mc_amount1      money,
    mc_amount2      money,
    mc_amount3      money,
    recurring       char(1),
    reattempt       char(1),
    retry_at        varchar(50),
    recur_times     int,
    username        text,
    password        text,
    subscr_id       text,
    first_name      text,
    last_name       text,
    address_name    text,
    address_street  text,
    address_city    text,
    address_state   text,
    address_zip     text,
    address_country text,
    address_status  text,
    payer_email     text,
    payer_id        text,
    payer_status    text,
    notify_version  varchar(8),
    verify_sign     varchar(200),
    post_status     varchar(50),
    post_response   varchar(50),
    HAStatus        varchar(8),
    nrows           int,
    npages          int
) as $$

declare
    _nrows int;
    _npages int;

begin

    if (_from is null) then _from := date_trunc('day',now()); end if;
    if (_to   is null) then _to   := now();                   end if;

    create temporary table ipn_out on commit drop as
        select  ipn.UID,
            ipn.IPNReceived,
            fdecrypt(ipn.x_business)        as business,
            fdecrypt(ipn.x_receiver_email)  as receiver_email,
            fdecrypt(ipn.x_item_name)       as item_name,
            fdecrypt(ipn.x_item_number)     as item_number,
            ipn.quantity,
            fdecrypt(ipn.x_invoice)         as invoice,
            fdecrypt(ipn.x_custom)          as custom,
            fdecrypt(ipn.x_memo)            as memo,
            ipn.tax,
            fdecrypt(ipn.x_payment_status)  as payment_status,
            fdecrypt(ipn.x_pending_reason)  as pending_reason,
            fdecrypt(ipn.x_reason_code)     as reason_code,
            fdecrypt(ipn.x_payment_date)    as payment_date,
            fdecrypt(ipn.x_txn_id)          as txn_id,
            fdecrypt(ipn.x_txn_type)        as txn_type,
            fdecrypt(ipn.x_payment_type)    as payment_type,
            ipn.mc_gross,
            ipn.mc_fee,
            ipn.mc_currency,
            ipn.settle_amount,
            ipn.settle_currency,
            ipn.exchange_rate,
            ipn.payment_gross,
            ipn.payment_fee,
            ipn.subscr_date,
            ipn.subscr_effective,
            ipn.period1,
            ipn.period2,
            ipn.period3,
            ipn.amount1,
            ipn.amount2,
            ipn.amount3,
            ipn.mc_amount1,
            ipn.mc_amount2,
            ipn.mc_amount3,
            ipn.recurring,
            ipn.reattempt,
            ipn.retry_at,
            ipn.recur_times,
            fdecrypt(ipn.x_username)        as username,
            fdecrypt(ipn.x_password)        as password,
            fdecrypt(ipn.x_subscr_id)       as subscr_id,  
            fdecrypt(ipn.x_first_name)      as first_name,
            fdecrypt(ipn.x_last_name)       as last_name,
            fdecrypt(ipn.x_address_name)    as address_name,
            fdecrypt(ipn.x_address_street)  as address_street,
            fdecrypt(ipn.x_address_city)    as address_city,
            fdecrypt(ipn.x_address_state)   as address_state,
            fdecrypt(ipn.x_address_zip)     as address_zip,
            fdecrypt(ipn.x_address_country) as address_country,
            fdecrypt(ipn.x_address_status)  as address_status,
            fdecrypt(ipn.x_payer_email)     as payer_email,
            fdecrypt(ipn.x_payer_id)        as payer_id,       
            fdecrypt(ipn.x_payer_status)    as payer_status,
            ipn.notify_version,
            ipn.verify_sign,
            ipn.post_status,
            ipn.post_response,
            ipn.HAStatus,
            0 as nrows, 0 as npages
        from ipn
        where ipn.IPNReceived between _from and _to;

        -- Calculate paging
        select count(*) into _nrows from ipn_out;
    if (coalesce(_pagesize, 0) = 0) then -- No paging = 1 page
        _pagesize := null;
        _npages   := 1;
    else   -- Calculate actual # of pages
        _npages   := _nrows / _pagesize;
        if (_nrows % _pagesize > 0) then _npages := _npages + 1; end if;
    end if;

    update ipn_out set nrows = _nrows, npages = _npages;

    return query select * from ipn_out 
        order by IPNReceived desc
        limit _pagesize offset (_page * _pagesize);

end;
$$ language plpgsql;
