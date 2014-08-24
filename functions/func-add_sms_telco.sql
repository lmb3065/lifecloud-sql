
-- 2014-08-24 dbrown: created

create or replace function add_sms_telco
(
    _telco text,
    _suffix text
) returns int as $$
declare

    RETVAL_SUCCESS              constant int :=   1;
    RETVAL_ERR_EXCEPTION        constant int := -98;

begin

    declare
        errno text;
        errmsg text;
        errdetail text;

    begin

        insert into sms_telcos (telco, suffix)
        values(_telco, _suffix);

    exception when others then

        -- Couldn't add File!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        perform log_event(_cid, null, EVENT_DEVERR_ADDING_FILE, '['||errno||'] '||errmsg||' : '||errdetail);
        RETURN RETVAL_ERR_EXCEPTION;

    end;

    return RETVAL_SUCCESS;

end
$$ language plpgsql;
