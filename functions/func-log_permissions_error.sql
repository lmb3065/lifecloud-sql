-- ==============================================================================================
-- log_permissions_error()
-- ----------------------------------------------------------------------------------------------
-- Logs a permissions error using standardized messages
-- ----------------------------------------------------------------------------------------------
-- 2013-10-13 dbrown Created
-- 2013-10-16 dbrown returns void now
-- 2013-11-06 dbrown Updated result code meanings, function now returns result code
-- 2013-11-12 dbrown Replaced specific retvals with NOT_ALLOWED
-- 2013-11-15 dbrown Corrected RETVAL_ERR_NOT_ALLOWED, added message for Success
-- ----------------------------------------------------------------------------------------------

create or replace function log_permissions_error(

    code char(4),
    result int,
    scid int,
    smid int,
    tcid int,
    tmid int

) returns int as $$

declare
    RETVAL_SUCCESS              constant int :=   1;
    RETVAL_ERR_ARG_MISSING      constant int :=   0;
    RETVAL_ERR_MEMBER_NOTFOUND  constant int := -11;
    RETVAL_ERR_TARGET_NOTFOUND  constant int := -12;
    RETVAL_ERR_NOT_ALLOWED      constant int := -80;

    msg text;

begin

    case result
        when RETVAL_SUCCESS             then msg := 'Success';
        when RETVAL_ERR_ARG_MISSING     then msg := 'A required argument was null';
        when RETVAL_ERR_MEMBER_NOTFOUND then msg := 'Source Member does not exist';
        when RETVAL_ERR_TARGET_NOTFOUND then msg := 'Target Member does not exist';
        when RETVAL_ERR_NOT_ALLOWED     then msg := 'Source Member is not allowed to do that';
        else                                 msg := '(Unrecognized permissions error code!)';
    end case;

    perform log_event( scid, smid, code, msg, tcid, tmid );
    return result;
end;
$$ language plpgsql;
