
-- =============================================================================
-- admin_create_demo_account()
-- -----------------------------------------------------------------------------
-- Creates a DEMONSTRATION account with two members.  It expires after 1 WEEK.
-- This function is run automatically by the database installation script.
-- Returns 1 on success, 0 if this account already exists.
-- -----------------------------------------------------------------------------
-- 2013-10-02 dbrown Created
-- 2013-10-16 dbrown Fixed outdated call to add_member()
-- 2013-10-24 dbrown Fixed outdated call to add_member() [h_profilepic]
-----------------------------------------------------------------------------

create or replace function admin_create_demo_account() returns int as $$

declare
    cid int;
    mid int;
    
    A_EMAIL      varchar := 'demo@lifecloud.info';
    A_PWORD      varchar := 'demo';
    A_FNAME      varchar := 'Demo';
    A_MI         varchar := 'A';
    A_LNAME      varchar := 'Owner';
    A_EXP      timestamp := current_date + interval '1 week';
    A_REFERRER   varchar := '';
    A_ADDRESS1   varchar := '800 Building Ave';
    A_ADDRESS2   varchar := 'Suite 165';
    A_CITY       varchar := 'New York';
    A_STATE      varchar := 'NY';
    A_POSTALCODE varchar := '10010';
    A_COUNTRY    varchar := 'US';
    A_PHONE      varchar := '800-235-8332';
    
    M_USERID     varchar := 'demo';
    M_EMAIL      varchar := 'user@lifecloud.info';
    M_PWORD      varchar := 'demo';
    M_FNAME      varchar := 'Demo';
    M_MI         varchar := 'M';
    M_LNAME      varchar := 'User';
    M_ADDRESS1   varchar := '12345 Some Street';
    M_ADDRESS2   varchar := 'Apt 444';
    M_CITY       varchar := 'Chicago';
    M_STATE      varchar := 'IL';
    M_POSTALCODE varchar := '55555';
    M_COUNTRY    varchar := 'US';
    M_PHONE      varchar := '123-456-7890';
    
begin

    cid := add_account( 
        A_EMAIL, A_PWORD, A_LNAME, A_FNAME, A_MI, A_EXP, A_REFERRER, 
        A_ADDRESS1, A_ADDRESS2, A_CITY, A_STATE, A_POSTALCODE, A_COUNTRY, A_PHONE );
    
    if (cid < 1) then return 0; end if; -- Demo account already exists
    
    -- Add an extra (non-admin) member
    
    mid := add_member( cid,
        M_FNAME, M_LNAME, M_MI, M_PWORD, M_USERID, M_EMAIL, null,
        M_ADDRESS1, M_ADDRESS2, M_CITY, M_STATE, M_POSTALCODE, M_COUNTRY, M_PHONE );
        
    return 1;
    
end;
$$ language plpgsql;


