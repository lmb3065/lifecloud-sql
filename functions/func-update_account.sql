-- =============================================================================
-- update_account()
-- -----------------------------------------------------------------------------
-- Pass a CID to specify which account to update.
--      NULL arguments are preserved, non-null arguments are updated
-- -----------------------------------------------------------------------------
-- 2013-10-04 dbrown created
-- 2013-11-15 dbrown revised event codes, exception handling, retvals
-- 2013-11-15 dbrown Handle non-existent account cleanly
-- 2016-01-29 dbrown Add field payment_type
-- -----------------------------------------------------------------------------

drop function update_account(int,int,bigint,varchar,timestamp);

create or replace function update_account
(
    _cid      int,
    _status   int         default null,
    _quota    bigint      default null,
    _referrer varchar(64) default null,
    _payment_type varchar(16) default null,
    _expires  timestamp   default null

) returns int as $$

declare
    EVENT_OK_UPDATED_ACCOUNT       constant char(4) := '1023';
    EVENT_DEVERR_UPDATING_ACCOUNT  constant char(4) := '9023';
    event_out char(4);

    RETVAL_SUCCESS                 constant int :=   1;
    RETVAL_ERR_ARGUMENTS           constant int :=   0;
    RETVAL_ERR_ACCOUNT_NOTFOUND    constant int := -10;
    RETVAL_ERR_EXCEPTION           constant int := -98;
    result int;

    nrows integer;

begin

    -- Check Arguments ---------------------------------------------------

    if not exists(select cid from Accounts where cid = _cid) then
        -- target Account doesn't exist
        perform log_event(null, null, EVENT_DEVERR_UPDATING_ACCOUNT,
                    'CID '||_cid||' does not exist' );
        return RETVAL_ERR_ACCOUNT_NOTFOUND;
    end if;


    -- Perform the update ------------------------------------------------

    declare
        errno text;
        errmsg text;
        errdetail text;
    begin
        UPDATE Accounts a
        SET status   = coalesce(_status,   a.status),
            quota    = coalesce(_quota,    a.quota),
            referrer = coalesce(_referrer, a.referrer),
            payment_type = coalesce(_payment_type, a.payment_type),
            expires  = coalesce(_expires,  a.expires),
            updated  = clock_timestamp()
        WHERE cid = _cid;

    exception when others then
        -- Couldn't update Account!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        perform log_event(_cid, null, EVENT_DEVERR_UPDATING_ACCOUNT, '['||errno||'] '||errmsg||' : '||errdetail);
        RETURN RETVAL_ERR_EXCEPTION;
    end;


    -- Done --------------------------------------------------------------

    perform log_event( _cid, null, EVENT_OK_UPDATED_ACCOUNT );
    return RETVAL_SUCCESS;
end;
$$ language plpgsql;
