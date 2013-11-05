
-- =============================================================================
-- update_account()
-- -----------------------------------------------------------------------------
-- Pass a CID to specify which account to update.
--      NULL arguments are preserved, non-null arguments are updated
-- Returns 0 on failure, 1 on success
-- -----------------------------------------------------------------------------
-- 2013-10-04 dbrown created
-- -----------------------------------------------------------------------------

create or replace function update_account(

    _cid      int,
    _status   int         default null,
    _quota    bigint      default null,
    _referrer varchar(64) default null,
    _expires  timestamp   default null 
   
) returns int as $$

declare

    nrows integer;

begin

    update Accounts a
    set status   = coalesce(_status,   a.status),
        quota    = coalesce(_quota,    a.quota),
        referrer = coalesce(_referrer, a.referrer),
        expires  = coalesce(_expires,  a.expires),
        updated  = clock_timestamp()
    where cid = _cid;
    
    get diagnostics nrows = row_count;  
    if (nrows = 1) then
         perform log_event( _cid, null, '0015', '' );
    else perform log_event( _cid, null, '9002', 'UPDATE ACCOUNTS failed');
    end if;

    return nrows;
    
end;
$$ language plpgsql;

