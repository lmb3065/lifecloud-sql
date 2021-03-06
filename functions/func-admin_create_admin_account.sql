-- ==========================================================================
-- function admin_create_admin_account
-- --------------------------------------------------------------------------
-- Creates the GOD ACCOUNT.  If it detects that one already exists,
--      it will delete it using admin_remove_account_cascade().
-- This function is run automatically by the database installation script.
-- --------------------------------------------------------------------------
-- 2013-10-24 dbrown: now actually makes the member admin
-- 2013-11-01 dbrown: revised event codes
-- 2013-11-13 dbrown: Organized, more information in eventlog
-- 2013-11-14 dbrown: Communicates by returning text
-- --------------------------------------------------------------------------

create or replace function admin_create_admin_account() returns text
as $$

declare
    EVENT_DEVERR_ADDING_ACCOUNT  constant char(4) := '9020';
    RETVAL_SUCCESS               constant int     := 1;

    n int;

    _cid int; _mid int;
    newcid int; newmid int;
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
        return 'Administrator account already exists!';
    end if;

    -- Create Admin Account
    newcid := add_account(
        C_ADMIN_EMAIL, C_ADMIN_PWORD, C_ADMIN_LNAME, C_ADMIN_FNAME,
        C_ADMIN_MI, expiration, '', '', '', '', '', '', 'US' );
    if (newcid < RETVAL_SUCCESS) then
        return 'Couldn''t create Administrator account! ('||newcid||')';
    end if;

    -- Mark new account's owner member as the Administrator
    select last_value into newmid from members_mid_seq;
    update Members set isadmin = 1 where mid = newmid;

    -- Done
    return 'Administrator account [#'||newcid||'] and login [#'||newmid||'] created.';

end;
$$ language plpgsql;
