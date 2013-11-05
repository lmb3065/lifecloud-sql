
-- =============================================================================
-- update_folder()
-- ----------------------------------------------------------------------------
-- returns 1 if successful
-- returns 0 if folder doesn't exist
-- returns -1...-9 from member_can_update_member() on permissions error
-- returns -10 if no changes specified (_name and _desc both empty)
-- returns -11 under database inconsistency condition (>1 folder updated)
-- ----------------------------------------------------------------------------
-- 2013-10-29 dbrown: created, based on stripped-down update_member()
-- 2013-10-29 dbrown: Fixed eventcodes, removed level-dependent logging/retval
-- -----------------------------------------------------------------------------

create or replace function update_folder(

    source_mid    int,                       -- Member making the change
    folderid      int,                       -- Folder being changed
    _name         varchar(64)  default null, -- Fields of the member record
    _desc         varchar      default null  --  that can be updated
    
) returns integer as $$

declare

    result int;
    owner_mid int;
    source_cid int;
    target_cid int;    
    target_mid int;
    x_new_name       bytea = null; -- Encrypted (x) versions
    x_new_desc       bytea = null; --   of new-data fields
    nrows int;
    
    
begin

    -- Nothing to change? Don't waste our time doing anything
    if ( length(_name) = 0 and length(_desc) = 0 ) then return -10; end if;

    -- Get folder's owner    
    select mid into target_mid from folders where fid = folderid;
    if (target_mid is null) then -- 9021 = 'error updating folder'
        perform log_event( source_cid, source_mid, '9021',
                    'No such folder', target_cid, target_mid );
        return 0; 
    end if;
    
    -- Check relations between user and folder's owner
    select allowed, scid, tcid into result, source_cid, target_cid 
        from member_can_update_member(source_mid, target_mid);
        
    if (result < 1) then 
        perform log_permissions_error( '9021', result, 
                source_cid, source_mid, target_cid, target_mid ); 
        return result;
    end if;
    
    -- Hash / Encrypt any data we might have
    if (_name is not null) then x_new_name := fencrypt(_name); end if;
    if (_desc is not null) then x_new_desc := fencrypt(_desc); end if;    

    
    -- Perform the update, only touching columns    
    -- where our argument is NOT NULL
    update Folders set
        x_name  = coalesce(x_new_name, folders.x_name),
        x_desc  = coalesce(x_new_desc, folders.x_desc),
        updated = clock_timestamp()
    where fid = folderid;
    
    
    -- Error checking    
    get diagnostics nrows = row_count;
    if (nrows <> 1) then 
        perform log_event( source_cid, source_mid, '9021',
                    'DATABASE INCONSISTENCY', target_cid, target_mid );
        return -11;
    end if;
    
    -- Success    
    perform log_event( source_cid, source_mid, '0016', '', target_cid, target_mid );
    return 1;
    
end;
$$ language plpgsql;


