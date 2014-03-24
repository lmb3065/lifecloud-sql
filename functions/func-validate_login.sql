
-- ======================================================================
-- validate_login
--     arg_userid text : Decrypted and compared to members.userid
--     arg_passw  text : Hashed    and compared to members.userpw
-- ----------------------------------------------------------------------
-- example:
--     select * from validate_login('admin@cypress.com','admin');
-- ----------------------------------------------------------------------
-- Returns 1 member_t record in cleartext
--     match:    incrememts matched members.logincount by 1
--     no match: all fields are null
-- ----------------------------------------------------------------------
-- 2013-09-25 dbrown : Account/Member refactor (lots more result cols)
-- 2013-10-16 dbrown : UserID validation is case insensitive
-- 2013-11-01 dbrown : eventcodes revision
-- 2013-11-17 dbrown : Replaced magic eventcodes with constants
-- 2014-01-09 dbrown : Added checks for account status and expiry
-- ----------------------------------------------------------------------

create or replace function validate_login(

    arg_userid varchar(64),
    arg_passwd varchar(64)

) returns member_t as $$

declare
    EVENT_LOGIN              constant char(4) := '1000';
    EVENT_NOLOGIN_USERPASS   constant char(4) := '4000';
    EVENT_NOLOGIN_OTHER      constant char(4) := '4001';

    _userid_c varchar(64) := lower(arg_userid);
    _passwd_h text        := sha1( arg_passwd );
    _mid int;
    _cid int;
    _acctstatus int;
    _acctexpiry timestamp;
    _failmsg text;

    r member_t;
    n int;

begin

    select mid, cid into _mid, _cid from members
        where lower(fdecrypt(x_userid)) = _userid_c
            and h_passwd = _passwd_h
            and status = 0;

    if (_mid is null) then
        -- No match / Auth failed : 4000 = 'failed login attempt'
        perform log_event( null, null, EVENT_NOLOGIN_USERPASS, _userid_c );
        return null;
    end if;

    -- Check account's status
    select a.status, a.expires into _acctstatus, _acctexpiry
        from accounts a where a.cid = _cid;
    if (_acctstatus > 0) then
        perform log_event( _cid, _mid, EVENT_NOLOGIN_OTHER, 'account is unavailable' );
        return null;
    elsif (_acctexpiry <= current_timestamp) then
        perform log_event( _cid, _mid, EVENT_NOLOGIN_OTHER, 'account is expired' );
        return null;
    end if;

    -- Auth succeeded: 0000 = 'user logged in'
    perform log_event( _cid, _mid, EVENT_LOGIN, _userid_c );

    -- ... increment login counter ...
    update members set logincount = logincount + 1 where mid = _mid;

    -- ... and return the matched member record
    r = get_members( _mid );
    return r;

end;
$$ language plpgsql;

