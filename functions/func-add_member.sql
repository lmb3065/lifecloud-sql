
-- ==========================================================================
-- function add_member
-- --------------------------------------------------------------------------
-- Returns:
--    > 1: MemberID of the newly added member. 
--    -10: Can't find Account by given CID
--    -22: Member already exists with this e-mail address
--    -23: Member already exists with this UserID
--    -24: Member already exists with this Name in the Account
--    -25: Adding Member would exceed MAXLOGINS Members in the Account
-- -----------------------------------------------------------------------------
-- 2013-09-25 dbrown : Members/Accounts refactor, added members.userid
-- 2013-10-08 dbrown : added CID/Name dup-check as alt to UserID dup-check 
-- 2013-10-09 dbrown : added call to add_initial_folders()
-- 2013-10-16 dbrown : Convert all UserIDs/Emails into lowercase.
-- 2013-10-16 dbrown : Names are case-preserved but case-insensitive
-- 2013-10-18 dbrown : new column 'profilepic', reordered args
-- 2013-10-24 dbrown : isAdmin is now 0 for all new members
-- 2013-11-01 dbrown : update eventcodes and return values
--                     replaced magic retvale/eventcodes with constants 
--                     removed unnecessary INSERT sanity check
--                     made name-dup check independent of userid-dup check
-------------------------------------------------------------------------------

create or replace function add_member
( 
    _cid          int,
    
    _fname        varchar(64),
    _lname        varchar(64),
    
    _mi           char(1)       default '',
    _passwd       varchar(64)   default '',
    _userid       varchar(64)   default '',
    _email        varchar(64)   default '',
    _h_profilepic varchar(64)   default null,
    _address1     varchar(64)   default '',
    _address2     varchar(64)   default '',
    _city         varchar(64)   default '',
    _state        char(2)       default '',
    _postalcode   varchar(16)   default '',
    _country      char(2)       default '',
    _phone        varchar(20)   default '',
    
    _maxlogins    int  default 32767,
    _status       int  default 0,
    _pwstatus     int  default 0,
    _userlevel    int  default 4,  -- Lowest access level
    _tooltips     int  default 1 )
    returns int as $$

declare
    EC_OK_ADDED_MEMBER              constant varchar := '1030';
    EC_USERERR_ADDING_MEMBER        constant varchar := '4030';
    EC_DEVERR_ADDING_MEMBER         constant varchar := '9030';
    RETVAL_ERR_ACCOUNT_NOTFOUND     constant int := -10;
    RETVAL_ERR_MEMBER_EXISTS_EMAIL  constant int := -22;
    RETVAL_ERR_MEMBER_EXISTS_USERID constant int := -23;
    RETVAL_ERR_MEMBER_EXISTS_NAME   constant int := -24;
    RETVAL_ERR_MEMBER_EXISTS_FULL   constant int := -25;

    _userid_c  varchar(64) := lower(_userid);
    _email_c   varchar(64) := lower(_email);
    
    nrows       int;
    newmid      int;

begin

    ---------------------
    -- Argument checks --

  
    -- Find account which will be this member's parent
    SELECT count(*) INTO nrows FROM Accounts
        WHERE cid = _cid;
    
    if (nrows < 1) then
        perform log_event( _cid, null, EC_DEVERR_ADDING_MEMBER, 'Parent Account does not exist');
        return RETVAL_ERR_ACCOUNT_NOTFOUND;
    end if;

    
    -- Make sure email isn't already in use
    if length(_email) > 0 then
    
      SELECT count(*) INTO nrows FROM Members
        WHERE lower(fdecrypt(x_email)) = _email_c;
      
      if (nrows > 0) then
          perform log_event( _cid, null, EC_USERERR_ADDING_MEMBER, 'E-mail '||_email_c||' already in use');
          return RETVAL_ERR_MEMBER_EXISTS_EMAIL;
      end if;
    end if;

    
    -- Make sure we're not going to create more than MaxLogins members 
    
    SELECT count(*) INTO nrows FROM Members
        WHERE cid = _cid;
    
    if (nrows >= _maxlogins) then
        perform log_event( _cid, null, EC_USERERR_ADDING_MEMBER, 'Would exceed MAXLOGINS members');
        return RETVAL_ERR_MEMBER_EXISTS_FULL;
    end if;

    
    -- UserID is optional, but we want to ensure this is not a duplicate   
    
    if length(_userid) > 0 then    
        
        SELECT count(*) INTO nrows FROM Members
            WHERE lower(fdecrypt(x_userid)) = _userid_c;
        
        if (nrows > 0) then
            perform log_event( _cid, null, EC_USERERR_ADDING_MEMBER, 'UserID '||_userid_c||' already in use');
            return RETVAL_ERR_MEMBER_EXISTS_USERID;
        end if;
    end if;
     
    
     -- Check that we don't already have their name in this account
         
    SELECT count(*) INTO nrows FROM Members 
        WHERE cid = _cid 
            AND lower(fdecrypt(x_fname)) = lower(_fname) 
            AND lower(fdecrypt(x_mi))    = coalesce(lower(_mi), '')
            AND lower(fdecrypt(x_lname)) = lower(_lname);
                
    if (nrows > 0) then
        perform log_event( _cid, null, EC_USERERR_ADDING_MEMBER, 'Name already exists in this account');
        return RETVAL_ERR_MEMBER_EXISTS_NAME;
    end if;

    
    -----------------------------------------   
    -- Passed tests, add the member record --
    
    INSERT INTO Members
        ( cid, h_profilepic, h_passwd, x_userid, x_email,
            x_fname, x_mi, x_lname, x_address1, 
            x_address2, x_city, x_state, x_postalcode,
            x_country, x_phone, 
            status, pwstatus, userlevel, tooltips, isadmin )          
    VALUES
        ( _cid, _h_profilepic, sha1(_passwd), fencrypt(_userid_c), fencrypt(_email_c),
            fencrypt(_fname), fencrypt(_mi), fencrypt(_lname), fencrypt(_address1), 
            fencrypt(_address2), fencrypt(_city), fencrypt(_state), fencrypt(_postalcode), 
            fencrypt(_country), fencrypt(_phone), 
            _status, _pwstatus, _userlevel, _tooltips, 0 );

    
    -- Log it
    SELECT last_value into newmid from members_mid_seq; 
    perform log_event( _cid, newmid, EC_OK_ADDED_MEMBER, _fname||' '||_lname|| ' (' ||_email_c||')');

    
    -- Add the starting folders for this member
    perform add_initial_folders( newmid );        
    return newmid;
    
 end;
 $$ language plpgsql;
 
