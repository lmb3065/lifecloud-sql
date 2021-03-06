
-- Update an existing registration code.
-- 2015-01-02 dbrown: create
-- 2015-01-15 dbrown: add new column/field 'discount'
-- 2015-03-23 dbrown: add new column/field 'paypal_button_id'
-- 2015-06-27 dbrown: add paypal columns PeriodN / AmountN
-- 2015-10-18 dbrown: Add 2nd set of PayPal fields
-- drop function update_regcode(text,text,int,int,timestamp,timestamp,timestamp,int,int,varchar,varchar,varchar,varchar,varchar,varchar,varchar);

create or replace function update_regcode
(
    _code text,
    _description text,
    _maxUses int,
    _uses int,
    _codeEffective timestamp,
    _codeExpires timestamp,
    _acctExpires timestamp,
    _acctLife int,
    _discount int,
    _paypal_button_id_1 varchar(16),
    _period1_1       varchar(4),
    _period2_1       varchar(4),
    _period3_1       varchar(4),
    _amount1_1       varchar(10),
    _amount2_1       varchar(10),
    _amount3_1       varchar(10),
    _paypal_button_id_2 varchar(16),
    _period1_2       varchar(4),
    _period2_2       varchar(4),
    _period3_2       varchar(4),
    _amount1_2       varchar(10),
    _amount2_2       varchar(10),
    _amount3_2       varchar(10)
) returns int as $$
declare

    EVENT_OK_UPDATED_REGCODE       constant varchar := '1123';
    EVENT_USERERR_UPDATING_REGCODE constant varchar := '4123';
    EVENT_DEVERR_UPDATING_REGCODE  constant varchar := '9123';
    RETVAL_SUCCESS                 constant int :=   1;
    RETVAL_ERR_INVALID_ARGS        constant int :=   0;
    RETVAL_ERR_REGCODE_INVALID     constant int := -17;
    RETVAL_ERR_EXCEPTION           constant int := -98;

    _eventcode_out varchar;
    _eventtext_out varchar;
    _retval int;
    _found boolean;

begin

    declare errno text; errmsg text; errdetail text;
    begin

        update reg_codes set
            maximum_uses = _maxUses,
            code_uses = _uses,
            description = _description,
            code_effective = _codeEffective,
            code_expires = _codeExpires,
            account_expires = _acctExpires,
            account_life = _acctLife,
            discount = _discount,
            paypal_button_id_1 = _paypal_button_id_1,
            period1_1     = _period1_1,
            period2_1     = _period2_1,
            period3_1     = _period3_1,
            amount1_1     = _amount1_1,
            amount2_1     = _amount2_1,
            amount3_1     = _amount3_1,
            paypal_button_id_2 = _paypal_button_id_2,
            period1_2     = _period1_2,
            period2_2     = _period2_2,
            period3_2     = _period3_2,
            amount1_2     = _amount1_2,
            amount2_2     = _amount2_2,
            amount3_2     = _amount3_2
        where code = _code;

        _found = FOUND;

    exception when others then

        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;

        case SQLSTATE
            when '23502' then -- NOT NULL constraint violation
                _retval = RETVAL_ERR_INVALID_ARGS; -- something was null
                _eventcode_out = EVENT_USERERR_UPDATING_REGCODE;
                _eventtext_out = 'A required argument was NULL';
            else
                _retval = RETVAL_ERR_EXCEPTION;
                _eventcode_out = EVENT_DEVERR_UPDATING_REGCODE; 
                _eventtext_out = '['||errno||'] '||errmsg||' : '||errdetail;
        end case;

        perform log_event(null, null, _eventcode_out, _eventtext_out);
        RETURN _retval;

    end;

    -- No exceptions ... Test for success
    if not _found then
        perform log_event(null, null, EVENT_USERERR_UPDATING_REGCODE, 'Code not found: '||_code);
        return RETVAL_ERR_REGCODE_INVALID;
    end if;

    -- Success
    perform log_event(null, null, EVENT_OK_UPDATED_REGCODE, 'code: ' || _code);
    return RETVAL_SUCCESS;

end
$$ language plpgsql;
