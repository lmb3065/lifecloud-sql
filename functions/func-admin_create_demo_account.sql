
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
-- 2013-11-14 dbrown Communicates by returning text
-----------------------------------------------------------------------------

create or replace function admin_create_demo_account() returns text as $$

declare
    RETVAL_SUCCESS constant int := 1;
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

    if (cid < RETVAL_SUCCESS) then
        return 'FAILED to create Demonstration account! ('||cid||')';
    end if;

    -- Add an extra (non-admin) member.  This account now has TWO members.
    -- (Dup-checking, logging, etc is done within add_member)
    mid := add_member( cid, M_FNAME, M_LNAME, '', M_PWORD, M_USERID, M_EMAIL, null );

    if (mid < RETVAL_SUCCESS) then
        return 'FAILED to create Demonstration member! ('||mid||')';
    end if;

    -- Success
    return 'Demonstration account [#'||mid||'] created.';

end;
$$ language plpgsql;


