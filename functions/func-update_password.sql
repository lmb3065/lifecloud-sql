
-- -----------------------------------------------------------------------------
--  update_password()
-- -----------------------------------------------------------------------------
-- 2013-10-11 dbrown: Updated
-- 2013-10-11 dbrown: No longer requires old-password verification
-- 2013-10-12 dbrown: Added source-mid, extensive logging
-- 2013-10-13 dbrown : perms/retvals moved into member_can_update_member()
-----------------------------------------------------------------------------

create or replace function update_password(

        source_mid   int,         -- MID of the Member who is performing the update.
        target_mid   int,         -- MID of the intended target of the update.
        newpassword  varchar(64)
        
) returns int as $$
    
declare
    result      int;
    source_cid  int;
    source_level   int;
    source_isadmin int;
    target_cid  int;
    nrows       int;
    
begin

    -- Check permissions

    select allowed, scid, slevel, sisadmin, tcid 
        into result, source_cid, source_level, source_isadmin, target_cid
        from member_can_update_member(source_mid, target_mid);
        
    if (result < 1) then -- 9006 = error updating password
        perform log_permissions_error( '9006', result, source_cid, source_mid, target_cid, target_mid);
        return result;
    end if;
        
    
    -- Perform the update
    
    update Members set
            h_passwd = sha1(newpassword),
            updated  = clock_timestamp(),
            pwstatus = 0
        where mid = source_mid;

        
    -- Error-checking   
     
    get diagnostics nrows = row_count;
    if (nrows <> 1) then -- Fail
        perform log_event( source_cid, source_mid, '9006', 'UPDATE MEMBERS failed!', target_cid, target_mid );
        return -10; end if;

        
    -- Success must be logged according to who made the change ...
       
    if (source_isadmin = 1) then -- Admin made change
        if    (result = 3) then perform log_event( source_cid, source_mid, '0032', 'Admin password was changed', target_cid, target_mid );        
        elsif (result = 2) then perform log_event( source_cid, source_mid, '0032', '', target_cid, target_mid );
        else                    perform log_event( source_cid, source_mid, '0032', '', target_cid, target_mid );
        end if;
    elsif (source_level = 0) then -- Account Owner made change
        if    (result = 3) then perform log_event( source_cid, source_mid, '0031', 'Admin password changed by non-admin', target_cid, target_mid );        
        elsif (result = 2) then perform log_event( source_cid, source_mid, '0031', '', target_cid, target_mid );
        else                    perform log_event( source_cid, source_mid, '0031', '', target_cid, target_mid );
        end if;
    else
        if    (result = 3) then perform log_event( source_cid, source_mid, '0030', 'Admin password changed by luser', target_cid, target_mid );        
        elsif (result = 2) then perform log_event( source_cid, source_mid, '0030', 'Account Owner password changed by luser', target_cid, target_mid );
        else                    perform log_event( source_cid, source_mid, '0030', '', target_cid, target_mid );
        end if;
    end if;
                
    return result;
    
end
$$ language plpgsql;

