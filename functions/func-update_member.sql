
-- =============================================================================
-- function update_member
-- ----------------------------------------------------------------------------
-- returns 1 if successful, or error values from member_can_update_member
-- ----------------------------------------------------------------------------
-- 2009-09-03 lbrown : original version in T-SQL
-- 2013-09-26 dbrown : ported to PL/pgSQL
-- 2013-10-12 dbrown : source_userlevel restriction tightened to (0,1)
-- 2013-10-12 dbrown : added logging of target_cid target_mid
-- 2013-10-13 dbrown : perms/retvals moved into member_can_update_member()
-- 2013-10-16 dbrown : forced lowercase (insensitive) on userid and email
-- 2013-10-18 dbrown : new column 'profilepic', reordered args
-- 2013-11-01 dbrown : revised eventcodes
-- 2013-11-15 dbrown : EventCodes, RetVals, UserID preserved but insensitive,
--                     detects and prevents email/userid/name collisions
-- 2013-11-16 dbrown : Exempt target user from name/userid/email change scanning
--                     (fix error when updating values to what they already are)
-- 2013-11-16 dbrown : Logs different eventcodes by source-member role
-- 2013-03-24 dbrown : New optional fields alerttype, alertphone, alertemail
-- 2014-06-07 dbrown : Refactor: Now expects an entire structure as input
--                     Added error handling
-- -----------------------------------------------------------------------------

create or replace function update_member
(
    source_mid    int,     -- Member making the change
    target_mid    int,     -- Member being changed

    _fname        varchar(64),
    _lname        varchar(64),
    _mi           varchar(4),

    _passwd       varchar(64),
    _userid       varchar(64),
    _email        varchar(64),
    _profilepic   varchar(64),

    _address1     varchar(64),
    _address2     varchar(64),
    _city         varchar(64),
    _state        varchar(64),
    _postalcode   varchar(16),
    _country      varchar(64),
    _phone        varchar(16),

    _pwstatus     int,
    _status       int,
    _userlevel    int,
    _tooltips     int,
    
    _alerttype    int,
    _alertphone   varchar(20),
    _alertemail   varchar(64)
    
) returns integer

as $$

declare
    EVENT_OK_UPDATED_MEMBER        char(4) := '1033';
    EVENT_OK_OWNER_UPDATED_MEMBER  char(4) := '1034';
    EVENT_OK_ADMIN_UPDATED_MEMBER  char(4) := '1035';
    EVENT_USERERR_UPDATING_MEMBER  char(4) := '4033';
    EVENT_AUTHERR_UPDATING_MEMBER  char(4) := '6033';
    EVENT_DEVERR_UPDATING_MEMBER   char(4) := '9033';
    event_out char(4);
    event_msg text;

    RETVAL_SUCCESS                  constant int := 1;
    RETVAL_ERR_ARGUMENTS            constant int := 0;
    RETVAL_ERR_MEMBER_EXISTS_EMAIL  constant int := -21;
    RETVAL_ERR_MEMBER_EXISTS_USERID constant int := -22;
    RETVAL_ERR_MEMBER_EXISTS_NAME   constant int := -23;
    RETVAL_ERR_EXCEPTION            constant int := -98;
    result int;

    source_cid      int;
    source_level    int;
    source_isadmin  int;
    target_cid      int;
    target_fname    text;
    target_mi       text;
    target_lname    text;

    existing_mid    int;

begin


    -- Ensure Source-Member is allowed to update Target-Member

    SELECT allowed, scid, slevel, sisadmin, tcid
        INTO result, source_cid, source_level, source_isadmin, target_cid
        FROM member_can_update_member(source_mid, target_mid);

    if (result < RETVAL_SUCCESS) then
        event_out := EVENT_AUTHERR_UPDATING_MEMBER;
        perform log_permissions_error( event_out, result, source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;


    -- Ensure new e-mail is unique

    existing_mid := NULL;    

    _email := lower(_email);
    if (length(_email) > 0) then

        SELECT mid into existing_mid FROM members m
        WHERE (m.mid <> target_mid) 
            AND (fdecrypt(x_email) = _email);

        if (existing_mid is not null) then
            -- E-Mail is in use by some other account
            event_out := EVENT_USERERR_UPDATING_MEMBER;
            event_msg := 'E-mail <'||_email||'> is already in use';
            perform log_event( source_mid, target_mid, event_out, event_msg );
            return RETVAL_ERR_MEMBER_EXISTS_EMAIL;
        end if;
    end if;


    -- Ensure new UserID is unique

    existing_mid := NULL;
    if (length(_userid) > 0) then

        SELECT mid INTO existing_mid FROM members m
        WHERE (m.mid <> target_mid)
            AND (lower(fdecrypt(x_userid)) = lower(_userid));

        if (existing_mid is not null) then
            -- UserID is in use by some other account
            event_out := EVENT_USERERR_UPDATING_MEMBER;
            event_msg := 'UserID "'||_userid||'" is already in use';
            perform log_event( source_mid, target_mid, event_out, event_msg );
            return RETVAL_ERR_MEMBER_EXISTS_USERID;
        end if;
    end if;


    -- Ensure new Name is unique in this Account

    existing_mid := NULL;

    SELECT mid INTO existing_mid FROM members m
      WHERE m.mid <> target_mid
        AND m.cid = target_cid
        AND lower(fdecrypt(m.x_fname)) = lower(_fname)
        AND lower(fdecrypt(m.x_mi))    = lower(_mi)
        AND lower(fdecrypt(m.x_lname)) = lower(_lname);

    if (existing_mid is not null) then
        -- Found an existing member with the proposed name
        event_out := EVENT_USERERR_UPDATING_MEMBER;
        event_msg := initcap(_fname)||' '||initcap(target_mi)||' '||initcap(_lname)
                     ||' is already in this account';
        perform log_event( source_mid, target_mid, event_out, event_msg );
        return RETVAL_ERR_MEMBER_EXISTS_NAME;
    end if;


    -- Update Database

    declare errno text; errmsg text; errdetail text;
    begin

        UPDATE Members m SET
            h_passwd     = sha1(_passwd),
            h_profilepic = sha1(_profilepic),
            x_userid     = fencrypt(_userid),
            x_email      = fencrypt(_email),
            x_fname      = fencrypt(_fname),
            x_mi         = fencrypt(_mi),
            x_lname      = fencrypt(_lname),
            x_address1   = fencrypt(_address1),
            x_address2   = fencrypt(_address2),
            x_city       = fencrypt(_city),
            x_state      = fencrypt(_state),
            x_postalcode = fencrypt(_postalcode),
            x_country    = fencrypt(_country),
            x_phone      = fencrypt(_phone),
            status       = _status,
            pwstatus     = _pwstatus,
            userlevel    = _userlevel,
            tooltips     = _tooltips,
            alerttype    = _alerttype,
            x_alertphone = fencrypt(_alertphone),
            x_alertemail = fencrypt(_alertemail),
            updated      = clock_timestamp()
        WHERE mid = target_mid;

    exception when others then

        -- Couldn't update member!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        event_out := EVENT_DEVERR_UPDATING_MEMBER;
        perform log_event(source_cid, source_mid, event_out, '['||errno||'] '||errmsg||' : '||errdetail);
        return RETVAL_ERR_EXCEPTION;

    end;


    -- Success

    if (source_mid = target_mid) then event_out := EVENT_OK_UPDATED_MEMBER;
    elsif (source_isadmin = 1) then   event_out := EVENT_OK_ADMIN_UPDATED_MEMBER;
    elsif (source_level <= 1) then    event_out := EVENT_OK_OWNER_UPDATED_MEMBER;
    else event_out := EVENT_OK_UPDATED_MEMBER;
    end if;

    perform log_event( source_cid, source_mid, event_out, null, target_cid, target_mid );
    return result;

end;
$$ language plpgsql;

