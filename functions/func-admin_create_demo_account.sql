
-- =============================================================================
-- admin_create_demo_account()
-- -----------------------------------------------------------------------------
-- Creates a DEMONSTRATION account with two members.  It expires after 1 WEEK.
-- This function is run automatically by the database installation script.
--    > 1: MID of newly created Member
--    -20: Member (Account owner) exists with this e-mail address
--    -22: Member already exists with this e-mail address
--    -23: Member already exists with this UserID
--    -24: Member already exists with this Name in the Account
-- -----------------------------------------------------------------------------
-- 2013-10-02 dbrown Created
-- 2013-10-16 dbrown Fixed outdated call to add_member()
-- 2013-10-24 dbrown Fixed outdated call to add_member() [h_profilepic]
-- 2013-11-09 dbrown Updated retvals, eventcodes, replaced magic with constants
--                   Returns new add_member or add_account result directly
-- 2013-11-10 dbrown Returns void, communicates by RAISE WARNING
-- 2013-11-14 dbrown More info in eventcodes
-----------------------------------------------------------------------------

create or replace function admin_create_demo_account() returns void as $$

declare
    cid int; mid int;

    A_EMAIL      varchar := 'demo@lifecloud.info';
    A_PWORD      varchar := 'demo';
    A_FNAME      varchar := 'Demo';
    A_MI         varchar := 'A';
    A_LNAME      varchar := 'Owner';
    A_EXP      timestamp := current_date + interval '1 week';

    M_USERID     varchar := 'demo';
    M_EMAIL      varchar := 'user@lifecloud.info';
    M_PWORD      varchar := 'demo';
    M_FNAME      varchar := 'Demo';
    M_LNAME      varchar := 'User';

begin

    -- Add an account.  This automagically creates an Owner member.
    -- (Dup-checking, logging, etc is done within add_account)
    cid := add_account( A_EMAIL, A_PWORD, A_LNAME, A_FNAME, A_MI, A_EXP );

    if (cid < 1) then
        raise warning 'FAILED to create Demonstration account [%]', cid;
        return;
    end if;

    -- Add an extra (non-admin) member.  This account now has TWO members.
    -- (Dup-checking, logging, etc is done within add_member)
    mid := add_member( cid, M_FNAME, M_LNAME, M_MI, M_PWORD, M_USERID, M_EMAIL, null );

    if (mid < 1) then
        raise warning 'FAILED to create Demonstration member [%]', mid;
        return;
    end if;

    -- Success
    raise notice 'Demonstration account [#%] created.', mid;
    return;

end;
$$ language plpgsql;


