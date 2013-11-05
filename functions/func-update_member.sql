
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

    result int;
    source_cid int;
    target_cid int;
    
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
    
    
begin -----------------------------------------------------------------------------

    -- Check permissions

    select allowed, scid, tcid
        into result, source_cid, target_cid 
        from member_can_update_member(source_mid, target_mid);
        
    if (result < 1) then -- 9004 = 'error updating member'
        perform log_permissions_error( '9004', result, source_cid, source_mid, target_cid, target_mid ); 
        return result;
    end if;
    
    
    -- Hash / Encrypt any data we might have
    
    if (_fname      is not null) then x_new_fname      := fencrypt(_fname);      end if;
    if (_lname      is not null) then x_new_lname      := fencrypt(_lname);      end if;
    if (_mi         is not null) then x_new_mi         := fencrypt(_mi);         end if;
    if (_passwd     is not null) then h_new_passwd     := sha1(_passwd);         end if;
    if (_userid     is not null) then x_new_userid     := fencrypt(lower(_userid));     end if;
    if (_email      is not null) then x_new_email      := fencrypt(lower(_email));      end if;
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
        status      = coalesce(_status,         m.status),
        pwstatus    = coalesce(_pwstatus,        m.pwstatus),
        userlevel   = coalesce(_userlevel,       m.userlevel),
        tooltips    = coalesce(_tooltips,        m.tooltips),
        updated     = clock_timestamp()
    where mid = target_mid;
    
    
    -- Error checking
    
    get diagnostics nrows = row_count;
    if (nrows <> 1) then -- You had permission but something went wrong
        perform log_event( source_cid, source_mid, '9004', 'UPDATE MEMBERS failed!', target_cid, target_mid );
        return -10; end if;

        
    -- Success
    
    if (result = 3) then
          perform log_event( source_cid, source_mid, '0016', 'Admin Member was updated', target_cid, target_mid );        
    else  perform log_event( source_cid, source_mid, '0016', '', target_cid, target_mid );
    end if;

    return result;
    
end;
$$ language plpgsql;


