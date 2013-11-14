-- ==========================================================================
-- function admin_create_admin_account
-- --------------------------------------------------------------------------
-- Creates the GOD ACCOUNT.  If it detects that one already exists, 
--      it will delete it using admin_remove_account_cascade().
-- This function is run automatically by the database installation script.
--      Returns information via RAISE instead of return value.
-- --------------------------------------------------------------------------
-- 2013-10-15 dbrown: now checks and whacks ALL MEMBERS with the admin flag
--                      before creating a new one
-- 2013-10-24 dbrown: now actually makes the member admin
-- 2013-11-01 dbrown: revised event codes
-- 2013-11-13 dbrown: Organized, more information in eventlog
-- --------------------------------------------------------------------------

create or replace function admin_create_admin_account( ) returns void as $$

declare
    EVENT_DEVERR_ADDING_ACCOUNT  constant char := '9020';
    RETVAL_SUCCESS               constant int := 1;
    
    n int;
    
    _cid int;
    _mid int;
    newcid int;
    newmid int;
    expiration  timestamp := current_date + interval '5 years';
    
    C_ADMIN_EMAIL constant varchar := 'admin@lifecloud.info';
    C_ADMIN_PWORD constant varchar := 'admin';
    C_ADMIN_FNAME constant varchar := 'Administrator';
    C_ADMIN_LNAME constant varchar := 'User';
    C_ADMIN_MI    constant varchar := 'J';
    
begin

    -- Check for existing admin accounts
    if exists( select mid from members where isAdmin = 1) then
        perform log_event( null, null, EVENT_DEVERR_ADDING_ACCOUNT,
            'Admin Account already exists!' );
        return ;
    end if;
        
    -- Create Admin Account
    newcid := add_account(
        C_ADMIN_EMAIL, C_ADMIN_PWORD, C_ADMIN_LNAME, C_ADMIN_FNAME, C_ADMIN_MI, expiration,
        '', '', '', '', '', '', 'US' );  -- referrer, addr1, addr2, city, state, postcode, country
    if (newcid < RETVAL_SUCCESS) then
        -- newcid < 1 is an error code
        return newcid;
    end if;
        
    -- Mark new account's owner member as the Administrator
    update Members set isadmin = 1 where mid = newmid;     
    
    -- Done
    return newmid; 
    
end;
$$ language plpgsql;


