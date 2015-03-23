/* 
    2015-03-22 dbrown: Created (ported from MS-SQL)
 */

create or replace function get_ipn_details
(
    _ipnuid int
)
returns table
(
    UID             integer,
    IPNReceived     timestamp,
    business        varchar(50),
    receiver_email  varchar(50),    
    item_name       varchar(127),
    item_number     varchar(127),
    quantity        int,
    invoice         varchar(50),
    custom          varchar(50),
    memo            varchar(50),
    tax             money,
    payment_status  varchar(50),
    pending_reason  varchar(50),
    reason_code     varchar(50),
    payment_date    varchar(50),
    txn_id          varchar(50),
    txn_type        varchar(50),
    payment_type    varchar(50),
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
    username        varchar(50),
    password        varchar(50),
    subscr_id       varchar(50),
    first_name      varchar(50),
    last_name       varchar(50),
    address_name    varchar(50),
    address_street  varchar(50),
    address_city    varchar(50),
    address_state   varchar(50),
    address_zip     varchar(50),
    address_country varchar(50),
    address_status  varchar(50),
    payer_email     varchar(50),
    payer_id        varchar(50),
    payer_status    varchar(50),
    notify_version  varchar(8),
    verify_sign     varchar(200),
    post_status     varchar(50),
    post_response   varchar(50),
    HAStatus        varchar(8)
) as $$

begin

    if _ipnuid is null then return; end if;

    return query
    select * from ipn where ipn.uid = _ipnuid;

end;
$$ language plpgsql;

