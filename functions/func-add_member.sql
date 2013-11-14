
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
-- 2013-11-13 dbrown : Organized, more info in eventlog details 
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
    EVENT_OK_ADDED_MEMBER           constant varchar := '1030';
    EVENT_USERERR_ADDING_MEMBER     constant varchar := '4030';
    EVENT_DEVERR_ADDING_MEMBER      constant varchar := '9030';
    
    RETVAL_ERR_ACCOUNT_NOTFOUND     constant int := -10;
    RETVAL_ERR_MEMBER_EXISTS_EMAIL  constant int := -21;
    RETVAL_ERR_MEMBER_EXISTS_USERID constant int := -22;
    RETVAL_ERR_MEMBER_EXISTS_NAME   constant int := -23;
    RETVAL_ERR_MEMBER_EXISTS_FULL   constant int := -24;

    nrows       int;
    newmid      int;

begin

    -- Check arguments --------------------------------------------------------
  
    _userid := lower(_userid);
    _email := lower(_email);
    
    
    -- Ensure destination account exists
    if not exists (SELECT cid FROM Accounts WHERE cid = _cid) then
        perform log_event( _cid, null, EVENT_DEVERR_ADDING_MEMBER, 
                    'Account ['||_cid||'] does not exist');
        return RETVAL_ERR_ACCOUNT_NOTFOUND;
    end if;

    
    -- Ensure email address is unique    
    if (length(_email) > 0) then
        if exists (SELECT mid FROM Members WHERE lower(fdecrypt(x_email)) = _email) then
            perform log_event( _cid, null, EVENT_USERERR_ADDING_MEMBER,
                        'E-mail <'||_email||'> is already in use');
            return RETVAL_ERR_MEMBER_EXISTS_EMAIL;
        end if;
    end if;
    
    
    -- Ensure UserID is unique if provided   
    if (length(_userid) > 0) then
        if exists (SELECT mid FROM Members WHERE lower(fdecrypt(x_userid)) = _userid) then
            perform log_event( _cid, null, EVENT_USERERR_ADDING_MEMBER,
                        'UserID "'||_userid||'" already in use');
            return RETVAL_ERR_MEMBER_EXISTS_USERID;
        end if;
    end if;
     
    
    -- Ensure full name is unique within its account
    if exists (
        SELECT mid FROM members
        WHERE cid = _cid 
            AND lower(fdecrypt(x_fname)) = lower(_fname) 
            AND lower(fdecrypt(x_mi))    = lower(_mi)
            AND lower(fdecrypt(x_lname)) = lower(_lname)
    ) then
        perform log_event( _cid, null, EVENT_USERERR_ADDING_MEMBER,
                    ||_fname||' '||_mi||' '||_lname' is already in this account');
        return RETVAL_ERR_MEMBER_EXISTS_NAME;
    end if;

    
    -- Ensure we won't create more than MaxLogins members     
    SELECT count(*) INTO nrows FROM Members WHERE cid = _cid;
    if (nrows >= _maxlogins) then
        perform log_event( _cid, null, EVENT_USERERR_ADDING_MEMBER,
                    'Would exceed maximum members ('||maxlogins||')');
        return RETVAL_ERR_MEMBER_EXISTS_FULL;
    end if;

    
    
    -- Passed tests, add the Member -------------------------------------------
    
    declare
        errno  text;
        errmsg text;
        errdetail text;
    begin        
        INSERT INTO Members ( cid, h_profilepic, h_passwd, x_userid, x_email, 
            x_fname, x_mi, x_lname, x_address1, x_address2, x_city, x_state, 
            x_postalcode, x_country, x_phone, status, pwstatus, userlevel,
            tooltips, isadmin )          
        VALUES ( _cid, _h_profilepic, sha1(_passwd), fencrypt(_userid), 
            fencrypt(_email), fencrypt(_fname), fencrypt(_mi), fencrypt(_lname),
            fencrypt(_address1), fencrypt(_address2), fencrypt(_city),
            fencrypt(_state), fencrypt(_postalcode), fencrypt(_country),
            fencrypt(_phone), _status, _pwstatus, _userlevel, _tooltips, 0 );
            
    exception when others then
        -- Couldn't add Member!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;                
        perform log_event(_cid, null, EVENT_DEVERR_ADDING_MEMBER, '['||errno||'] '||errmsg||' : '||errdetail);
        RETURN RETVAL_ERR_EXCEPTION;
    end;

    
    -- Success ----------------------------------------------------------------
    
    -- Add the starting folders to the new Member
    SELECT last_value into newmid from members_mid_seq; 
    perform add_initial_folders( newmid );        
    
    -- Log it
    perform log_event( _cid, newmid, EVENT_OK_ADDED_MEMBER, 
        '['||newmid||'] '||_fname||' '||_lname|| ' <' ||_email||'>');
    return newmid;
    
 end;
 $$ language plpgsql;
 
