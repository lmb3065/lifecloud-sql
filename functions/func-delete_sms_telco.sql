
-- 2014-08-24 dbrown: created

create or replace function delete_sms_telco
(
   _telco text

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

        DELETE FROM sms_telcos
        WHERE telco = _telco;

    exception when others then

        -- Couldn't add File!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        perform log_event(_cid, null, null, '['||errno||'] '||errmsg||' : '||errdetail);
        RETURN RETVAL_ERR_EXCEPTION;

    end;

    return RETVAL_SUCCESS;

end
$$ language plpgsql;
