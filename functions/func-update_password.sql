
-- -----------------------------------------------------------------------------
--  update_password()
-- -----------------------------------------------------------------------------
-- 2013-10-11 dbrown: Updated
-- 2013-10-11 dbrown: No longer requires old-password verification
-- 2013-10-12 dbrown: Added source-mid, extensive logging
-- 2013-10-13 dbrown : perms/retvals moved into member_can_update_member()
-- 2013-11-01 dbrown : update eventcodes, remove target-level logging
-- 2013-11-12 dbrown : update to spec with constants, simplification
-- 2013-11-13 dbrown : Fixed: was updating source-user instead of target-user
-- 2013-11-13 dbrown : Fixed: reverse 'password cannot contain spaces' logic
-----------------------------------------------------------------------------

create or replace function update_password(

        source_mid   int,         -- MID of the Member who is performing the update.
        target_mid   int,         -- MID of the intended target of the update.
        newpassword  varchar(64)
        
) returns int as $$
    
declare
    EC_OK_UPDATED_PASSWORD        constant char(4) := '1043';
    EC_OK_OWNER_UPDATED_PASSWORD  constant char(4) := '1044';
    EC_OK_ADMIN_UPDATED_PASSWORD  constant char(4) := '1045';
    EC_USERERR_UPDATING_PASSWORD  constant char(4) := '4043';
    EC_AUTHERR_UPDATING_PASSWORD  constant char(4) := '6093';
    EC_DEVERR_UPDATING_PASSWORD   constant char(4) := '9043';

    RETVAL_SUCCESS  constant int := 1;
    RETVAL_ERR_ARG_INVALID constant int := -1;
    
    result          int;
    source_cid      int;
    source_level    int;
    source_isadmin  int;
    target_cid      int;
    nrows           int;
    eventcode_out   char(4);
begin

    -- Check permissions

    SELECT allowed, scid, slevel, sisadmin, tcid 
        INTO result, source_cid, source_level, source_isadmin, target_cid
        FROM member_can_update_member(source_mid, target_mid);
        
    if (result <> RETVAL_SUCCESS) then
        perform log_permissions_error( EC_AUTHERR_UPDATING_PASSWORD, 
                    result, source_cid, source_mid, target_cid, target_mid);
        return result;
    end if;        
    
    -- Check new data for validity
    
    newpassword := coalesce(newpassword, '');
    
    if (position(' ' in newpassword) > 0) then
        perform log_event( source_cid, source_mid, EC_USERERR_UPDATING_PASSWORD,
             'Password cannot contain spaces', target_cid, target_mid );
        return RETVAL_ERR_ARG_INVALID;
        
    elsif (length(newpassword) < 6) then
        perform log_event( source_cid, source_mid, EC_USERERR_UPDATING_PASSWORD,
             'Password must be at least 6 characters', target_cid, target_mid );
        return RETVAL_ERR_ARG_INVALID;
    end if;
    
    
    -- Perform the update
    
    UPDATE Members
        SET h_passwd = sha1(newpassword),
            updated  = clock_timestamp(),
            pwstatus = 0
        WHERE mid = target_mid;
        
        
    -- Success

    if (source_mid = target_mid) then  eventcode_out := EC_OK_UPDATED_PASSWORD;
    elsif (source_isadmin = 1) then    eventcode_out := EC_OK_ADMIN_UPDATED_PASSWORD;
    elsif (source_level   = 0) then    eventcode_out := EC_OK_OWNER_UPDATED_PASSWORD;        
    else eventcode_out := EC_OK_UPDATED_PASSWORD;
    end if;

    perform log_event( source_cid, source_mid, eventcode_out, null, target_cid, target_mid );        
    return result;
    
end
$$ language plpgsql;

