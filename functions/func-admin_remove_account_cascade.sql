
--===========================================================================
-- admin_remove_account_cascade()
-----------------------------------------------------------------------------
-- Entirely removes an account along with associated members, folders, events
-----------------------------------------------------------------------------
-- This is a convenience account for development and debugging 
--   and it should never be run on live data !!
-- 2013-10-24 dbrown: Also removes Session data
--===========================================================================

create or replace function admin_remove_account_cascade( _cid integer ) 
    returns int as $$

begin

    delete from Sessions where mid in
        (select mid from members where cid = _cid);

    delete from Folders  where cid = _cid;
    delete from Members  where cid = _cid;
    delete from Accounts where cid = _cid;
    perform log_event( _cid, null, '0011',
        'admin_remove_account_cascade()' );
    
    return 1;
end;
$$ language plpgsql;

