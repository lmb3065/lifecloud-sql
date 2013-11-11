
--===========================================================================
-- function add_account
-----------------------------------------------------------------------------
-- Creates new Account record, and associated Member record for the owner
-----------------------------------------------------------------------------
-- returns  > 0 : CID of newly created Account
-- returns  -20 : Account (e-mail) already exists
-----------------------------------------------------------------------------
-- 2013-10-08 dbrown: Fixed outdated call to add_member; isAdmin defaults 0
-- 2013-10-09 dbrown: moved call to add_initial_folders into add_member
-- 2013-10-18 dbrown: Fixed outdated call to add_member (new 'profilepic')
-- 2013-10-24 dbrown: removed isAdmin argument
-- 2013-11-01 dbrown: Updated EventCodes
-- 2013-11-06 dbrown: Updated return values and lots of cleanup,
--       Replaced all magic codes and numbers with constants,
--       Null '_expires' arg now OK; default value is assigned by table,
--       E-mail is forced to lowercase before insert,
--       Removed unnecessary INSERT sanity check, add success logging
-----------------------------------------------------------------------------

create or replace function add_account(

    -- All of this data actually goes into the Member object 
    -- representing the account owner, except where noted.

    -- Required arguments
    _email      varchar(64),
    _passwd     varchar(64),
    _lname      varchar(64),
    _fname      varchar(64),
    
    -- Optional arguments
    _mi         char(1)      default  '',
    _expires    timestamp    default  current_date + interval '1 year', -- goes into Account
    _referrer   varchar(64)  default  '',   -- goes into Account
    _address1   varchar(64)  default  '',
    _address2   varchar(64)  default  '',
    _city       varchar(64)  default  '',
    _state      char(2)      default  '',
    _postalcode varchar(16)  default  '',
    _country    char(2)      default  '',
    _phone      varchar(20)  default  '',
    _status     int          default  0     -- goes into Account

) returns int as $$
    
declare
    EC_OK_ADDED_ACCOUNT       constant varchar := '1020';
    EC_USERERR_ADDING_ACCOUNT constant varchar := '4020';
    RETVAL_ERR_ACCOUNT_EXISTS constant int := -20;
    
    fstatus int; fcid int; fmid int; -- "found" status, cid, mid
    newcid int; newmid int;
    C_QUOTA constant int := 100000000;
        
begin

    -- Process arguments
    
    _email := lower(_email);

    
    -- Check for any existing Accounts that match this one

    select a.status, a.cid, m.mid 
        into fstatus, fcid, fmid 
        from Accounts a join Members m on (a.owner_mid = m.mid)
        where _email = fdecrypt(m.x_email);
        
    if (fstatus = 9) then
        -- Found a temp signup account: Return that
        return fcid;
    elsif (fcid is not null) then 
        -- Found an active account: Return error
        perform log_event( fcid, fmid, EC_USERERR_ADDING_ACCOUNT, 
                           'Account "' || _email || '" already exists' );
        return RETVAL_ERR_ACCOUNT_EXISTS;
    end if;
   
    
    -- Passed tests, add Accounts record
    --     (owner_mid will get a real value after the Member 
    --      is created; for now it is 0, not a valid MID)

    insert into Accounts ( owner_mid, status, quota, referrer, expires )
        values ( 0, _status, C_QUOTA, _referrer, _expires );
        
    select last_value into newcid from accounts_cid_seq;
    perform log_event( newcid, null, EC_OK_ADDED_ACCOUNT );     


    -- Create Owner Member record and add it to the account --      
    
    newmid := add_member( newcid, _fname, _lname, _mi, _passwd, _email, _email, null,  
        _address1, _address2, _city, _state, _postalcode, _country, _phone, 
        null, 0, 0, 0, 1 );
    update Accounts set owner_mid = newmid where cid = newcid;

    return newcid;
    
end;
$$
language plpgsql;


