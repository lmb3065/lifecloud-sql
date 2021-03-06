-- ==========================================================================
--  function add_member
-- -----------------------------------------------------------------------------
--  Add a Member to an Account
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
-- 2013-11-16 dbrown : Preserve case of UserID (but keep insensitive)
-- 2013-11-16 dbrown : Shortened error output
-- 2013-11-16 dbrown : TODO: Prevent NULLS from getting through and crashing table
-- 2013-11-24 dbrown : removed eventlog noise
-- 2014-01-09 dbrown : fixed typo _maxlogins
-- 2014-03-24 dbrown : new input fields alerttype, alertphone, alertemail
-- 2014-08-09 dbrown : new members are now assigned the default app selection
-- 2015-02-26 dbrown : Fixed string typos
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
    _country      char(2)       default 'US',
    _phone        varchar(20)   default '',

    _maxlogins    int  default 32767,
    _status       int  default 0,
    _pwstatus     int  default 0,
    _userlevel    int  default 4,
    _tooltips     int  default 1,
    
    _alerttype    int  default 0,
    _alertphone   varchar(20)   default '',
    _alertemail   varchar(64)   default ''

) returns int as $$

declare
    EVENT_OK_ADDED_MEMBER           constant varchar := '1030';
    EVENT_USERERR_ADDING_MEMBER     constant varchar := '4030';
    EVENT_DEVERR_ADDING_MEMBER      constant varchar := '9030';

    RETVAL_ERR_ACCOUNT_NOTFOUND     constant int := -10;
    RETVAL_ERR_MEMBER_EXISTS_EMAIL  constant int := -21;
    RETVAL_ERR_MEMBER_EXISTS_USERID constant int := -22;
    RETVAL_ERR_MEMBER_EXISTS_NAME   constant int := -23;
    RETVAL_ERR_MEMBER_EXISTS_FULL   constant int := -24;
    RETVAL_ERR_EXCEPTION            constant int := -98;

    MAGIC_DEFAULT_APPS_STRING constant varchar =
        '0010000000010000100000000011000010000000011000000000000000000000';

    nrows       int;
    newmid      int;

begin

    -- Ensure destination account exists
    if not exists (SELECT cid FROM Accounts WHERE cid = _cid) then
        perform log_event( _cid, null, EVENT_DEVERR_ADDING_MEMBER,
                    'Account ['||_cid||'] does not exist');
        return RETVAL_ERR_ACCOUNT_NOTFOUND;
    end if;

    -- Ensure email address is unique
    _email := lower(_email); -- Case insensitive
    if (length(_email) > 0) then
        if exists (SELECT mid FROM Members WHERE fdecrypt(x_email) = _email) then
            perform log_event( _cid, null, EVENT_USERERR_ADDING_MEMBER,
                        'E-mail <'||_email||'> is already in use');
            return RETVAL_ERR_MEMBER_EXISTS_EMAIL;
        end if;
    end if;

    -- Ensure UserID is unique if provided
    if (length(_userid) > 0) then
        if exists (SELECT mid FROM Members WHERE lower(fdecrypt(x_userid)) = lower(_userid)) then
            perform log_event( _cid, null, EVENT_USERERR_ADDING_MEMBER,
                        'UserID "'||_userid||'" is already in use');
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
                    _fname||' '||_mi||' '||_lname||' is already in this account');
        return RETVAL_ERR_MEMBER_EXISTS_NAME;
    end if;

    -- Ensure we won't create more than MaxLogins members
    SELECT count(*) INTO nrows FROM Members WHERE cid = _cid;
    if (nrows >= _maxlogins) then
        perform log_event( _cid, null, EVENT_USERERR_ADDING_MEMBER,
                    'Would exceed maximum members ('||_maxlogins||')');
        return RETVAL_ERR_MEMBER_EXISTS_FULL;
    end if;


    -- Add the Member record

    declare
        errno  text;
        errmsg text;
        errdetail text;
    begin
        INSERT INTO Members ( cid, h_profilepic, h_passwd, x_userid, x_email,
            x_fname, x_mi, x_lname, x_address1, x_address2, x_city, x_state,
            x_postalcode, x_country, x_phone,
            alerttype, x_alertphone, x_alertemail,
            status, pwstatus, userlevel,
            tooltips, isadmin )
        VALUES ( _cid, _h_profilepic, sha1(_passwd), fencrypt(_userid),
            fencrypt(_email), fencrypt(_fname), fencrypt(_mi), fencrypt(_lname),
            fencrypt(_address1), fencrypt(_address2), fencrypt(_city),
            fencrypt(_state), fencrypt(_postalcode), fencrypt(_country),
            fencrypt(_phone),
            _alerttype, fencrypt(_alertphone), fencrypt(_alertemail),
            _status, _pwstatus, _userlevel, _tooltips, 0 );
        select last_value into newmid from members_mid_seq;

    exception when others then
        -- Couldn't add Member!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        perform log_event(_cid, null, EVENT_DEVERR_ADDING_MEMBER, '['||errno||'] '||errmsg);
        RETURN RETVAL_ERR_EXCEPTION;
    end;


    -- Success

    perform add_initial_folders( newmid );
    perform update_member_apps( newmid, MAGIC_DEFAULT_APPS_STRING );

    perform log_event( _cid, newmid, EVENT_OK_ADDED_MEMBER, null );
    return newmid;

end
$$ language plpgsql;
