
-- Adds a new registration code to the database.
-- 2015-01-02 dbrown: create

create or replace function add_regcode
(
    _code        text,
    _maxuses     int,
    _codeEff     timestamp,
    _codeExp     timestamp,
    _acctExp     timestamp,
    _acctLife    int,
    _description text   default '',
    _uses        int    default 0
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
            code_expires, account_expires, account_life )
        values ( 
            _code, _maxuses, _uses, _description, _codeEff,
            _codeExp, _acctExp, _acctLife);

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
