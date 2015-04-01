
/* 
   IPN : PayPal Instant Payment Records
   2015-02-21 dbrown Ported from MS-SQL
   2015-03-31 dbrown Changed lots of columns to type 'bytea' for encryption
   2015-04-01 dbrown Fix permissions err (add permission for UID column)
*/

create table IPN
(
    UID             serial          not null primary key,
    IPNReceived     timestamp,
    x_business          bytea,
    x_receiver_email    bytea,
    x_item_name         bytea,
    x_item_number       bytea,
    quantity        int,
    x_invoice           bytea,
    x_custom            bytea,
    x_memo              bytea,
    tax             money,
    x_payment_status    bytea,
    x_pending_reason    bytea,
    x_reason_code       bytea,
    x_payment_date      bytea,
    x_txn_id            bytea,
    x_txn_type          bytea,
    x_payment_type      bytea,
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
    x_username          bytea,
    x_password          bytea,
    x_subscr_id         bytea,
    x_first_name        bytea,
    x_last_name         bytea,
    x_address_name      bytea,
    x_address_street    bytea,
    x_address_city      bytea,
    x_address_state     bytea,
    x_address_zip       bytea,
    x_address_country   bytea,
    x_address_status    bytea,
    x_payer_email       bytea,
    x_payer_id          bytea,
    x_payer_status      bytea,
    notify_version  varchar(8),
    verify_sign     varchar(200),
    post_status     varchar(50),
    post_response   varchar(50),
    HAStatus        varchar(8)
);

alter table ipn owner to pgsql;
grant all on ipn_uid_seq to delphi;
grant all on ipn to delphi;
