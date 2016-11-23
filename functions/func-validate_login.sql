
-- ======================================================================
-- validate_login
--     arg_userid text : Decrypted and compared to members.userid
--     arg_passw  text : Hashed    and compared to members.userpw
-- ----------------------------------------------------------------------
-- example:
--     select * from validate_login('admin@cypress.com','admin');
-- ----------------------------------------------------------------------
-- Returns MID (positive) or Error Code (negative, from ref_retvals)
-- ----------------------------------------------------------------------
-- 2013-09-25 dbrown : Account/Member refactor (lots more result cols)
-- 2013-10-16 dbrown : UserID validation is case insensitive
-- 2013-11-01 dbrown : eventcodes revision
-- 2013-11-17 dbrown : Replaced magic eventcodes with constants
-- 2014-01-09 dbrown : Added checks for account status and expiry
-- 2016-11-23 dbrown : Return MID instead of entire member
-- ----------------------------------------------------------------------

create or replace function validate_login(

    arg_userid varchar(64),
    arg_passwd varchar(64)

) returns int as $$

declare

    -- from ref_eventcodes
    EVENT_LOGIN              constant char(4) := '1000';
    EVENT_NOLOGIN_USERPASS   constant char(4) := '4000';
    EVENT_NOLOGIN_EXPIRED    constant char(4) := '4001';
    EVENT_NOLOGIN_SUSPENDED  constant char(4) := '4002';
    EVENT_NOLOGIN_CLOSED     constant char(4) := '4003';
    EVENT_NOLOGIN_INCOMPLETE constant char(4) := '4004';
    EVENT_NOLOGIN_PERMISSION constant char(4) := '4005';
    -- from ref_retvals
    RETVAL_ERR_USERPASS      constant int := -10;
    RETVAL_ERR_EXPIRED       constant int := -9;
    RETVAL_ERR_SUSPENDED     constant int := -8;
    RETVAL_ERR_CLOSED        constant int := -7;
    RETVAL_ERR_INCOMPLETE    constant int := -6;
    RETVAL_ERR_PERMISSION    constant int := -5;

    _userid_c varchar(64)    := lower(arg_userid);
    _passwd_h text           := sha1( arg_passwd );
    _mid int;
    _cid int;
    _mstatus int;
    _cstatus int;
    _acctexpiry timestamp;

begin

    select m.mid, m.cid, m.status into _mid, _cid, _mstatus 
        from members m
        where lower(fdecrypt(x_userid)) = _userid_c
            and h_passwd = _passwd_h;

    if (_mid is null) then
        -- No match / Authorization failed
        perform log_event( null, null, EVENT_NOLOGIN_USERPASS, _userid_c );
        return RETVAL_ERR_USERPASS;
    end if;

    if (_mstatus > 0) then
        -- Member status disallows login
        perform log_event( _cid, _mid, EVENT_NOLOGIN_PERMISSION, _userid_c );
        return RETVAL_ERR_PERMISSION;
    end if;

    -- Check parent account's status
    select a.status, a.expires into _cstatus, _acctexpiry
        from accounts a where a.cid = _cid;

    case _cstatus
        when 1 then
            -- Account is suspended
            perform log_event( _cid, _mid, EVENT_NOLOGIN_SUSPENDED, _userid_c );
            return RETVAL_ERR_SUSPENDED;
        when 2 then
            -- Account is closed
            perform log_event( _cid, _mid, EVENT_NOLOGIN_CLOSED, _userid_c );
            return RETVAL_ERR_CLOSED;
        when 3, 9 then
            -- Account signup is incomplete
            perform log_event( _cid, _mid, EVENT_NOLOGIN_INCOMPLETE, _userid_c );
            return RETVAL_ERR_INCOMPLETE;
        else
    end case;

    if (_acctexpiry <= current_timestamp) then
        -- Account is expired
        perform log_event( _cid, _mid, EVENT_NOLOGIN_EXPIRED, _userid_c );
        return RETVAL_ERR_EXPIRED;
    end if;

    -- Auth succeeded
    perform log_event( _cid, _mid, EVENT_LOGIN, _userid_c );
    update members set logincount = logincount + 1 where mid = _mid;
    return _mid;

end;
$$ language plpgsql;

