
--===========================================================================
-- function add_account
-----------------------------------------------------------------------------
-- Creates new Account record, and associated Member record for the owner
-----------------------------------------------------------------------------
-- returns > 0 : CID of newly created Account
-- returns   0 : ! Account already exists for this email address
-- returns  -1 : ! INSERT didn't work, database fail
-----------------------------------------------------------------------------
-- 2013-10-08 dbrown: Fixed outdated call to add_member; isAdmin defaults 0
-- 2013-10-09 dbrown: moved call to add_initial_folders into add_member
-- 2013-10-18 dbrown: Fixed outdated call to add_member (new 'profilepic')
-- 2013-10-24 dbrown: removed isAdmin argument
-----------------------------------------------------------------------------

create or replace function add_account
(
    _email      varchar(64),
    _passwd     varchar(64),
    _lname      varchar(64),
    _fname      varchar(64),
    _mi         char(1)      = '',
    _expires    timestamp    = null,
    _referrer   varchar(64)  = '',
    _address1   varchar(64)  = '',
    _address2   varchar(64)  = '',
    _city       varchar(64)  = '',
    _state      char(2)      = '',
    _postalcode varchar(16)  = '',
    _country    char(2)      = '',
    _phone      varchar(20)  = '',
    _status     int          = 0
 )   
    returns int as $$
    
declare

    C_QUOTA int = 100000000;
    arg_expires timestamp;
    
    fstatus int; fcid int; fmid int; -- "found" status, cid, mid
    newcid int; newmid int;
    nrows int = 0;
        
begin

    if (_expires is null) then
         arg_expires = current_date + interval '1 year';
    else arg_expires = _expires;
    end if;

    -- Check for any existing Accounts that match this one
    
    select a.status, a.cid, m.mid 
        into fstatus, fcid, fmid 
        from Accounts a join Members m on (a.owner_mid = m.mid)
        where _email = fdecrypt(m.x_email);
        
    if (fstatus = 9) then -- Temp signup account: use it
        return fcid;
    end if;

    if (fcid is not null) then -- Die 9001 'error adding account'
        perform log_event( fcid, fmid, '9001', 'email "' || _email || '" already in use' );
        return 0;
    end if;
    
    ---------------------------------------
    -- Passed tests, add Accounts record --

    insert into Accounts ( owner_mid, status, quota, referrer, expires )
        values ( -1, _status, C_QUOTA, _referrer, arg_expires );
    
    -- Error checking and logging
        
    get diagnostics nrows = row_count;
    select last_value into newcid from accounts_cid_seq;
    if (nrows = 1) then perform log_event( newcid, null, '0012', '' );
    else
        perform log_event( newcid, null, '9001', 'INSERT INTO ACCOUNTS failed' );
        return -1;
    end if;
    
    -- Create Owner Member record and add it to the account --      
    
    newmid := add_member( newcid, _fname, _lname, _mi, _passwd, _email, _email, NULL,  
        _address1, _address2, _city, _state, _postalcode, _country, _phone, 
        null, -- maxlogins = n/a
        0,   -- status = 0
        0,  --   pwstatus = OK,
        0,   --   userlevel = Owner
        1 );  --   tooltips
                    
    update Accounts set owner_mid = newmid where cid = newcid;
    
    return newcid;
    
end;
$$
language plpgsql;


