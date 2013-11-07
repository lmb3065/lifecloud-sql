-- ==========================================================================
-- function admin_create_admin_account
-- --------------------------------------------------------------------------
-- Creates the GOD ACCOUNT.  If it detects that one already exists, 
--      it will delete it using admin_remove_account_cascade().
-- This function is run automatically by the database installation script.
-- Returns 1 OK, 0 FAIL
-- --------------------------------------------------------------------------
-- 2013-10-15 dbrown: now checks and whacks ALL MEMBERS with the admin flag
--                      before creating a new one
-- 2013-10-24 dbrown: now actually makes the member admin
-- 2013-11-01 dbrown: revised event codes
-- --------------------------------------------------------------------------

create or replace function admin_create_admin_account( ) returns int as $$

declare

    _cid int;
    _mid int;
    newcid int;
    newmid int;
    cur refcursor;
    expiration  timestamp := current_date + interval '5 years';
    
    C_ADMIN_EMAIL constant varchar := 'admin@lifecloud.info';
    C_ADMIN_PWORD constant varchar := 'admin';
    C_ADMIN_FNAME constant varchar := 'Administrator';
    C_ADMIN_LNAME constant varchar := 'User';
    C_ADMIN_MI    constant varchar := 'J';
    
begin

    -- Get rid of any existing admin users, their folders & members
    -- Possible overkill, but more secure
    
    open cur for 
        (select a.cid, m.mid 
            from Accounts a join Members m on (a.cid = m.cid) 
            where m.isAdmin = 1);
            
    fetch first from cur into _cid, _mid;
    loop
        exit when _cid is null;
        perform log_event( _cid, _mid, '1029', 'old admin/root account deleted');
        perform admin_remove_account_cascade( _cid );
        fetch next from cur into _cid, _mid;
    end loop;
        
    
    -- Create the Account record
    
    newcid := add_account( 
        C_ADMIN_EMAIL, C_ADMIN_PWORD, C_ADMIN_LNAME, C_ADMIN_FNAME, C_ADMIN_MI, expiration,
        '', '', '', '', '', '', 'US' );  -- referrer, addr1, addr2, city, state, postcode, country
    
    if (newcid < 1) then -- Error
        -- add_account() will have logged the error event 
        return 0; end if;

        
    -- Mark new account's owner member as the Administrator
    
    select owner_mid into newmid from Accounts where cid = newcid;
    update Members set isadmin = 1 where mid = newmid;     
        
    return 1; 
    
end;
$$ language plpgsql;


