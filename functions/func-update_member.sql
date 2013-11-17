
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
-- -----------------------------------------------------------------------------

create or replace function update_member
(
    source_mid    int,     -- Member making the change
    target_mid    int,     -- Member being changed

    _fname        varchar(64)  default null, -- Fields of the member record
    _lname        varchar(64)  default null, --    that can be updated.  NULL
    _mi           varchar(4)   default null, --    is interpreted as "leave this

    _passwd       varchar(64)  default null, --    field alone".
    _userid       varchar(64)  default null,
    _email        varchar(64)  default null,
    _h_profilepic varchar(64)  default null,

    _address1     varchar(64)  default null,
    _address2     varchar(64)  default null,
    _city         varchar(64)  default null,
    _state        varchar(64)  default null,
    _postalcode   varchar(16)  default null,
    _country      varchar(64)  default null,
    _phone        varchar(16)  default null,

    _pwstatus     int          default null,
    _status       int          default null,
    _userlevel    int          default null,
    _tooltips     int          default null
)
    returns integer as $$

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
--  RETVAL_ERR_MEMBER_NOTFOUND      = -11; -- (from member_can_update_member)
--  RETVAL_ERR_MEMBER2_NOTFOUND     = -12; -- (from member_can_update_member)
    RETVAL_ERR_MEMBER_EXISTS_EMAIL  constant int := -21;
    RETVAL_ERR_MEMBER_EXISTS_USERID constant int := -22;
    RETVAL_ERR_MEMBER_EXISTS_NAME   constant int := -23;
--  RETVAL_ERR_NOT_ALLOWED          = -80; -- (from member_can_update_member)
    RETVAL_ERR_EXCEPTION            constant int := -98;
    result int;

    proposed_fname text;
    proposed_mi text;
    proposed_lname text;
    existing_mid text;
    source_cid int;
    source_level int;
    source_isadmin int;

    target_cid int;
    target_fname text;
    target_mi text;
    target_lname text;

    h_new_passwd     text;  -- Hashed (h) and encrypted (x) versions
    x_new_userid     bytea; --   of new-data fields
    x_new_email      bytea;
    x_new_fname      bytea;
    x_new_mi         bytea;
    x_new_lname      bytea;
    x_new_address1   bytea;
    x_new_address2   bytea;
    x_new_city       bytea;
    x_new_state      bytea;
    x_new_postalcode bytea;
    x_new_country    bytea;
    x_new_phone      bytea;
    nrows int;


begin

    -- Check arguments -------------------------------------------------------

    -- Ensure Source-Member is allowed to update Target-Member
    SELECT allowed, scid, slevel, sisadmin, tcid
        INTO result, source_cid, source_level, source_isadmin, target_cid
        FROM member_can_update_member(source_mid, target_mid);
    if (result < RETVAL_SUCCESS) then
        event_out := EVENT_AUTHERR_UPDATING_MEMBER;
        perform log_permissions_error( event_out, result, source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;

    -- If E-mail is changing, ensure new one is unique
    if (_email is not null) and (length(_email) > 0) then
        _email := lower(_email); -- Smash all e-mails to lowercase

        if exists (
            SELECT mid FROM members
            WHERE (mid <> target_mid) and (fdecrypt(x_email) = _email)
        ) then
                event_out := EVENT_USERERR_UPDATING_MEMBER;
                event_msg := 'E-mail <'||_email||'> is already in use';
                perform log_event( source_mid, target_mid, event_out, event_msg );
                return RETVAL_ERR_MEMBER_EXISTS_EMAIL;
        end if;
    end if;

    -- If UserID is changing, ensure new one is unique
    if (_userid is not null) and (length(_userid) > 0) then
        if exists (
            SELECT mid FROM members
                WHERE mid <> target_mid and lower(fdecrypt(x_userid)) = lower(_userid)
        ) then
            event_out := EVENT_USERERR_UPDATING_MEMBER;
            event_msg := 'UserID "'||_userid||'" is already in use';
            perform log_event( source_mid, target_mid, event_out, event_msg );
            return RETVAL_ERR_MEMBER_EXISTS_USERID;
        end if;
    end if;


    -- If Name fields are changing, ensure new Name is unique to the Account
    existing_mid := NULL;
    if coalesce(_fname, _mi, _lname) is not null then

        -- Grab the target member's existing name ...
        --   (All names are smashed to uppercase in this block
        --    to make comparisons case-Insensitive)
        select upper(fdecrypt(x_fname)),
               upper(fdecrypt(x_mi)),
               upper(fdecrypt(x_lname)) from members
        into proposed_fname, proposed_mi, proposed_lname
        where mid = target_mid;

        -- ... patch in the desired changes ...
        if _fname is not null then proposed_fname := upper(_fname); end if;
        if _mi    is not null then proposed_mi    := upper(_mi);    end if;
        if _lname is not null then proposed_lname := upper(_lname); end if;

        -- ... and search for the resulting "proposed" name
        select mid into existing_mid from members
        where cid = target_cid and mid <> target_mid
            and (_fname is null or (upper(fdecrypt(x_fname)) = proposed_fname))
            and (_mi    is null or (upper(fdecrypt(x_mi))    = proposed_mi))
            and (_lname is null or (upper(fdecrypt(x_lname)) = proposed_lname))
        limit 1;

        if (existing_mid is not null) then
            -- Found an existing member with the proposed name
            event_out := EVENT_USERERR_UPDATING_MEMBER;
            event_msg := initcap(_fname)||' '||initcap(target_mi)||' '||initcap(_lname)
                         ||' is already in this account';
            perform log_event( source_mid, target_mid, event_out, event_msg );
            return RETVAL_ERR_MEMBER_EXISTS_NAME;
        end if;

    end if;


    -- Hash / Encrypt any data we might have

    if (_fname      is not null) then x_new_fname      := fencrypt(_fname);      end if;
    if (_lname      is not null) then x_new_lname      := fencrypt(_lname);      end if;
    if (_mi         is not null) then x_new_mi         := fencrypt(_mi);         end if;
    if (_passwd     is not null) then h_new_passwd     := sha1(_passwd);         end if;
    if (_userid     is not null) then x_new_userid     := fencrypt(_userid);     end if;
    if (_email      is not null) then x_new_email      := fencrypt(_email);      end if;
    if (_address1   is not null) then x_new_address1   := fencrypt(_address1);   end if;
    if (_address2   is not null) then x_new_address2   := fencrypt(_address2);   end if;
    if (_city       is not null) then x_new_city       := fencrypt(_city);       end if;
    if (_state      is not null) then x_new_state      := fencrypt(_state);      end if;
    if (_postalcode is not null) then x_new_postalcode := fencrypt(_postalcode); end if;
    if (_country    is not null) then x_new_country    := fencrypt(_country);    end if;
    if (_phone      is not null) then x_new_phone      := fencrypt(_phone);      end if;


    -- Perform the update, only touching columns
    -- where our argument is NOT NULL

    update Members m set
        h_passwd    = coalesce(h_new_passwd,     m.h_passwd),
        x_userid    = coalesce(x_new_userid,     m.x_userid),
        x_email     = coalesce(x_new_email,      m.x_email),
        h_profilepic= coalesce(_h_profilepic,    m.h_profilepic),
        x_fname     = coalesce(x_new_fname,      m.x_fname),
        x_mi        = coalesce(x_new_mi,         m.x_mi),
        x_lname     = coalesce(x_new_lname,      m.x_lname),
        x_address1  = coalesce(x_new_address1,   m.x_address1),
        x_address2  = coalesce(x_new_address2,   m.x_address2),
        x_city      = coalesce(x_new_city,       m.x_city),
        x_state     = coalesce(x_new_state,      m.x_state),
        x_postalcode= coalesce(x_new_postalcode, m.x_postalcode),
        x_country   = coalesce(x_new_country,    m.x_country),
        x_phone     = coalesce(x_new_phone,      m.x_phone),
        status      = coalesce(_status,          m.status),
        pwstatus    = coalesce(_pwstatus,        m.pwstatus),
        userlevel   = coalesce(_userlevel,       m.userlevel),
        tooltips    = coalesce(_tooltips,        m.tooltips),
        updated     = clock_timestamp()
    where mid = target_mid;


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


