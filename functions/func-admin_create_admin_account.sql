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
--
-- FIXME :eventcodes, retvals, give up if admin exists
-- --------------------------------------------------------------------------

create or replace function admin_create_admin_account( ) returns void as $$

declare
    EC_OK_ADDED_ACCOUNT       constant char := '1020';
    EC_DEVERR_ADDING_ACCOUNT  constant char := '9020';

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
    select count(*) into n from members where isAdmin = 1;
    if (n = 1) then
        perform log_event( null, null, EC_DEVERR_ADDING_ACCOUNT, 'Admin account already exists' );
        return;
    end if;
    
    if (n > 1) then
        -- More than one admin member? Something has gone wrong. Kill their accounts
        declare c cursor for select cid from members where isAdmin = 1;
        for r in c loop
            perform admin_delete_account_cascade( r.cid );
        end loop;
        -- Fall through to create a new Admin account
    end if; 
        
    
    -- Create the Account record
    
    newcid := add_account( 
        C_ADMIN_EMAIL, C_ADMIN_PWORD, C_ADMIN_LNAME, C_ADMIN_FNAME, C_ADMIN_MI, expiration,
        '', '', '', '', '', '', 'US' );  -- referrer, addr1, addr2, city, state, postcode, country
    
    if (newcid < 1) then -- Error
        raise error 'FAILED to create Administrator account!';
        -- add_account() will have logged the error event 
        return RETVAL_ERR_; end if;

        
    -- Mark new account's owner member as the Administrator
    
    select owner_mid into newmid from Accounts where cid = newcid;
    update Members set isadmin = 1 where mid = newmid;     
    
    raise warning 'Administrator account created';    
    return newmid; 
    
end;
$$ language plpgsql;


