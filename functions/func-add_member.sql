
-- ==========================================================================
-- function add_member
-- --------------------------------------------------------------------------
-- Returns a row consisting of (status, memberid)
--   returns > 1: MemberID of the newly added member. 
--   returns   0: ! No such Account (CID)
--   returns  -1: ! This email already in use
--   returns  -2: ! This userID, or CID/Name combo, already in use 
--   returns  -3: ! Too many members present (members = maxlogins)
--   returns  -4: ? INSERT INTO Members failed! CRITICAL DATABASE FAIL
-- -----------------------------------------------------------------------------
-- 2013-09-25 dbrown : Members/Accounts refactor, added members.userid
-- 2013-10-08 dbrown : added CID/Name dup-check as alt to UserID dup-check 
-- 2013-10-09 dbrown : added call to add_initial_folders()
-- 2013-10-16 dbrown : Convert all UserIDs/Emails into lowercase.
-- 2013-10-16 dbrown : Names are case-preserved but case-insensitive
-- 2013-10-18 dbrown : new column 'profilepic', reordered args
-- 2013-10-24 dbrown : isAdmin is now 0 for all new members
-- 2013-11-01 dbrown : update eventcodes
-------------------------------------------------------------------------------

create or replace function add_member
( 
    _cid          int,
    
    _fname        varchar(64),
    _lname        varchar(64),
    _mi           varchar(4)  = '',
    
    _passwd       varchar(64) = '',
    _userid       varchar(64) = '',
    _email        varchar(64) = '',
    _h_profilepic varchar(64) = null,
  
    _address1     varchar(64) = '',
    _address2     varchar(64) = '',
    _city         varchar(64) = '',
    _state        varchar(64) = '',
    _postalcode   varchar(16) = '',
    _country      varchar(64) = '',
    _phone        varchar(16) = '',
    
    _maxlogins    int = 32767,
    _status       int = 0,
    _pwstatus     int = 0,
    _userlevel    int = 4,
    _tooltips     int = 1 )
    returns int as $$

declare
    _userid_c  varchar(64) = lower(_userid);
    _email_c   varchar(64) = lower(_email);
    
    nrows       int;
    newmid      int;

begin

    ---------------------
    -- Argument checks --

  
    -- Find account which will be this member's parent
    SELECT count(*) into nrows from Accounts WHERE CID = _CID;
    if (nrows < 1) then
        perform log_event( _cid, null, '9030', 'unknown account [cid]');
        return 0;
    end if;

    -- Make sure email isn't already in use
    if length(_email) > 0 then
      SELECT count(*) into nrows from Members WHERE lower(fdecrypt(x_email)) = _email_c;
      if (nrows > 0) then
          perform log_event( _CID, null, '4030', 'email '||_email_c||' already in use');
          return -1;
      end if;
    end if;

    -- Make sure we're not going to create more than MaxLogins members 
    SELECT count(*) into nrows from Members WHERE CID = _CID;
    if (nrows >= _maxlogins) then
        perform log_event( _CID, null, '4030', 'too many ( > maxlogins ) members');
        return -3;
    end if;

    -- UserID is optional, but we want to ensure this is not a duplicate member...    
    if length(_userid) > 0 then    
        -- Ensure userid is not already in use
        SELECT count(*) into nrows from Members WHERE lower(fdecrypt(x_userid)) = _userid_c;
        if (nrows > 0) then
            perform log_event( _cid, null, '4030', 'userid '||_userid_c||' already in use');
            return -2;
        end if;
        
    else -- If member has no login, at least check that we at
         -- least don't already have their name in this account        
        SELECT count(*) into nrows from Members 
            WHERE cid = _cid 
                and lower(fdecrypt(x_fname)) = lower(_fname) 
                and lower(fdecrypt(x_mi))    = lower(_mi)
                and lower(fdecrypt(x_lname)) = lower(_lname);
        if (nrows > 0) then
            perform log_event( _cid, null, '4030', 'duplicate CID-Name combination');
            return -2;
        end if;

    end if;
    
    -----------------------------------------   
    -- Passed tests, add the member record --
    
    insert into Members
        ( cid, h_profilepic, h_passwd, x_userid, x_email,
            x_fname, x_mi, x_lname, x_address1, 
            x_address2, x_city, x_state, x_postalcode,
            x_country, x_phone, 
            status, pwstatus, userlevel, tooltips, isadmin )          
    values
        ( _cid, _h_profilepic, sha1(_passwd), fencrypt(_userid_c), fencrypt(_email_c),
            fencrypt(_fname), fencrypt(_mi), fencrypt(_lname), fencrypt(_address1), fencrypt(_address2), fencrypt(_city), fencrypt(_state), fencrypt(_postalcode), fencrypt(_country), fencrypt(_phone), 
            _status, _pwstatus, _userlevel, _tooltips, 0 );
    
    -- Error checking and logging
          
    get diagnostics nrows = row_count;
    if (nrows <> 1) then
        perform log_event( _cid, null, '9030', 'insert into members failed'); 
        return -4;
    end if;
    
    SELECT last_value into newmid from members_mid_seq; 
    perform log_event( _cid, newmid, '1030', _fname||' '||_lname|| ' (' ||_email_c||')');
        -- user login added    


    -- Add the starting folders for this member
    
    perform add_initial_folders( newmid );        
    return newmid;
    
 end;
 $$ language plpgsql;
 
