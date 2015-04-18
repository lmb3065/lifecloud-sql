
--
-- 2015-03-21 dbrown : Created (ported from MS=SQL)
-- 2015-03-31 dbrown : Added encryption of PII fields
-- 2015-04-18 dbrowm : Force incoming email addresses to lowecase

create or replace function insert_ipn
(
    _business          varchar(50)  default NULL, 
    _receiver_email    varchar(50)  default NULL,
    _item_name         varchar(50)  default NULL,     
    _item_number       varchar(50)  default NULL,     
    _quantity          int          default NULL, 
    _invoice           varchar(50)  default NULL,  
    _custom            varchar(50)  default NULL,  
    _memo              varchar(50)  default NULL, 
    _tax               money        default NULL, 
    _payment_status    varchar(50)  default NULL, 
    _pending_reason    varchar(50)  default NULL, 
    _reason_code       varchar(50)  default NULL, 
    _payment_date      varchar(50)  default NULL, 
    _txn_id            varchar(50)  default NULL,
    _txn_type          varchar(50)  default NULL, 
    _payment_type      varchar(50)  default NULL, 
    _mc_gross          money        default NULL, 
    _mc_fee            money        default NULL, 
    _mc_currency       char(3)      default NULL, 
    _settle_amount     money        default NULL,
    _settle_currency   varchar(50)  default NULL, 
    _exchange_rate     float        default NULL,  
    _payment_gross     money        default NULL, 
    _payment_fee       money        default NULL, 
    _subscr_date       varchar(50)  default NULL, 
    _subscr_effective  varchar(50)  default NULL, 
    _period1           varchar(50)  default NULL, 
    _period2           varchar(50)  default NULL, 
    _period3           varchar(50)  default NULL, 
    _amount1           money        default NULL, 
    _amount2           money        default NULL, 
    _amount3           money        default NULL,
    _mc_amount1        money        default NULL, 
    _mc_amount2        money        default NULL, 
    _mc_amount3        money        default NULL, 
    _recurring         char(1)      default NULL, 
    _reattempt         char(1)      default NULL, 
    _retry_at          varchar(50)  default NULL,
    _recur_times       int          default NULL, 
    _username          varchar(50)  default NULL, 
    _password          varchar(50)  default NULL,  
    _subscr_id         varchar(50)  default NULL, 
    _first_name        varchar(50)  default NULL, 
    _last_name         varchar(50)  default NULL,
    _address_name      varchar(50)  default NULL, 
    _address_street    varchar(50)  default NULL, 
    _address_city      varchar(50)  default NULL, 
    _address_state     varchar(50)  default NULL, 
    _address_zip       varchar(50)  default NULL,
    _address_country   varchar(50)  default NULL, 
    _address_status    varchar(50)  default NULL, 
    _payer_email       varchar(50)  default NULL, 
    _payer_id          varchar(50)  default NULL, 
    _payer_status      varchar(50)  default NULL,
    _notify_version    varchar(8)   default NULL, 
    _verify_sign       varchar(200) default NULL, 
    _post_status       varchar(50)  default NULL, 
    _post_response     varchar(50)  default NULL
) returns int as $$

declare

    EVENT_DEVERR_ADDING_IPN constant char(4) = '9140';
    RETVAL_ERR_EXCEPTION int = -98;

begin

    _receiver_email := lower(_receiver_email);
    _payer_email := lower(_payer_email);

    declare errno text; errmsg text; errdetail text;
    begin -- 'Try'

        insert into ipn ( IPNReceived, 
            x_business, x_receiver_email, x_item_name, x_item_number, quantity,
            x_invoice, x_custom, x_memo, tax, x_payment_status, x_pending_reason, x_reason_code,
            x_payment_date, x_txn_id, x_txn_type, x_payment_type, mc_gross, mc_fee, mc_currency,
            settle_amount, settle_currency, exchange_rate, payment_gross, payment_fee,
            subscr_date, subscr_effective, period1, period2, period3, amount1, amount2, amount3,
            mc_amount1, mc_amount2, mc_amount3, recurring, reattempt, retry_at, recur_times, 
            x_username, x_password, x_subscr_id, x_first_name, x_last_name, x_address_name,
            x_address_street, x_address_city, x_address_state, x_address_zip, x_address_country,
            x_address_status, x_payer_email, x_payer_id, x_payer_status, 
            notify_version, verify_sign, post_status, post_response
        ) values ( cast( now() as timestamp ),
            fencrypt(_business), fencrypt(_receiver_email), fencrypt(_item_name), fencrypt(_item_number), _quantity, 
            fencrypt(_invoice), fencrypt(_custom), fencrypt(_memo), _tax, fencrypt(_payment_status), fencrypt(_pending_reason), fencrypt(_reason_code), 
            fencrypt(_payment_date), fencrypt(_txn_id), fencrypt(_txn_type), fencrypt(_payment_type), _mc_gross, _mc_fee, _mc_currency, 
            _settle_amount, _settle_currency, _exchange_rate, _payment_gross, _payment_fee, 
            _subscr_date, _subscr_effective, _period1, _period2, _period3, _amount1, _amount2, _amount3,
            _mc_amount1, _mc_amount2, _mc_amount3, _recurring, _reattempt, _retry_at, _recur_times, 
            fencrypt(_username), fencrypt(_password), fencrypt(_subscr_id), fencrypt(_first_name), fencrypt(_last_name), fencrypt(_address_name), 
            fencrypt(_address_street), fencrypt(_address_city), fencrypt(_address_state), fencrypt(_address_zip), fencrypt(_address_country), 
            fencrypt(_address_status), fencrypt(_payer_email), fencrypt(_payer_id), fencrypt(_payer_status), 
            _notify_version, _verify_sign, _post_status, _post_response
        );

    exception when others then

            get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
            perform log_event(null, null, EVENT_DEVERR_ADDING_IPN, '['||errno||'] '||errmsg||' : '||errdetail );   
            return RETVAL_ERR_EXCEPTION;
    end;

    return lastval(); 
end;
$$ language plpgsql;

