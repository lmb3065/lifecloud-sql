
-- Adds a new registration code to the database.
-- 2015-01-02 dbrown: create
-- 2015-01-15 dbrown: add new column/field 'discount'
-- 2015-03-23 dbrown: add new column/field 'paypal_button_id'
-- 2015-06-27 dbrown: add new columns/fields periodN / amountN
-- 2015-10-24 dbrown: add new columns/fields for 2nd Paypal button

-- drop function add_regcode(text,int,timestamp,timestamp,timestamp,int,int,text,int,varchar,varchar,varchar,varchar,varchar,varchar,varchar)
create or replace function add_regcode
(
    _code               text,
    _maxuses            int,
    _codeEff            timestamp,
    _codeExp            timestamp,
    _acctExp            timestamp,
    _acctLife           int,
    _discount           integer,
    _description        text        default '',
    _uses               int         default 0,
    _paypal_button_id_1   varchar(16) default '',
    _period1_1            varchar(4)  default '',
    _period2_1            varchar(4)  default '',
    _period3_1            varchar(4)  default '',
    _amount1_1            varchar(10) default '',
    _amount2_1            varchar(10) default '',
    _amount3_1            varchar(10) default '',
    _paypal_button_id_2   varchar(16) default '',
    _period1_2            varchar(4)  default '',
    _period2_2            varchar(4)  default '',
    _period3_2            varchar(4)  default '',
    _amount1_2            varchar(10) default '',
    _amount2_2            varchar(10) default '',
    _amount3_2            varchar(10) default ''
) returns int as $$
declare

    EVENT_OK_ADDED_REGCODE       constant varchar := '1120';
    EVENT_USERERR_ADDING_REGCODE constant varchar := '4120';
    EVENT_DEVERR_ADDING_REGCODE  constant varchar := '9120';
    RETVAL_SUCCESS               constant int :=   1;
    RETVAL_ERR_INVALID_ARGS      constant int :=   0;
    RETVAL_ERR_REGCODE_EXISTS    constant int := -28;
    RETVAL_ERR_EXCEPTION         constant int := -98;

    _eventcode_out varchar;
    _eventtext_out varchar;
    _retval int;

begin

    declare errno text; errmsg text; errdetail text;
    begin

        insert into reg_codes (
            code, maximum_uses, code_uses, description, code_effective,
            code_expires, account_expires, account_life, discount, 
            paypal_button_id_1, period1_1, period2_1, period3_1, amount1_1, amount2_1, amount3_1,
            paypal_button_id_2, period1_2, period2_2, period3_2, amount1_2, amount2_2, amount3_2 )
        values ( 
            _code, _maxuses, _uses, _description, _codeEff,
            _codeExp, _acctExp, _acctLife, _discount, 
            _paypal_button_id_1, _period1_1, _period2_1, _period3_1, _amount1_1, _amount2_1, _amount3_1,
            _paypal_button_id_2, _period1_2, _period2_2, _period3_2, _amount1_2, _amount2_2, _amount3_2 );

    exception when others then

        -- Couldn't insert row!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;

        case errno
            when '23505' then -- UNIQUE constraint violation
                _retval = RETVAL_ERR_REGCODE_EXISTS; 
                _eventcode_out = EVENT_USERERR_ADDING_REGCODE;
                _eventtext_out = 'Registration code already exists: ' || _code;

            when '23502' then -- NOT NULL constraint violation
                _retval = RETVAL_ERR_INVALID_ARGS; -- something was null
                _eventcode_out = EVENT_USERERR_ADDING_REGCODE;
                _eventtext_out = 'A required argument was NULL';

            else
                _retval = RETVAL_ERR_EXCEPTION;
                _eventcode_out = EVENT_DEVERR_ADDING_REGCODE; 
                _eventtext_out = '['||errno||'] '||errmsg||' : '||errdetail;
        end case;

        perform log_event(null, null, _eventcode_out, _eventtext_out);
        return _retval;

    end;

    -- Success
    perform log_event(null, null, EVENT_OK_ADDED_REGCODE, 'code: ' || _code);
    return RETVAL_SUCCESS;

end
$$ language plpgsql;
