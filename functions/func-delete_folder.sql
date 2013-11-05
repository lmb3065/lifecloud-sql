
-- ===========================================================================
--  delete_folder
-- ---------------------------------------------------------------------------
--  Returns 1 on success
--  Returns 0 if the folder didn't exist
--  Returns a value from member_can_update_member on permissions error
--  Returns -10 under database inconsistency condition (>1 folder deleted)
-- ---------------------------------------------------------------------------
-- 2013-10-13 dbrown: created
-- 2013-10-29 dbrown: Simply deletes rows instead of marking them deleted
-- 2013-10-29 dbrown: folderid must be owned by target_mid
-- 2013-10-29 dbrown: target_mid no longer accepted
-- 2013-11-01 dbrown: revised event codes, added source-level logging
-- 2013-11-01 dbrown: changed folder.fid to folder.uid
-- ---------------------------------------------------------------------------

create or replace function delete_folder(

    source_mid int, -- User making the change
    folderid   int  -- Folder that User wants to delete

) returns int as $$

declare

    result int;
    source_cid int = null; -- Account source_mid belongs to
    source_level int = null;
    source_isadmin int = null;
    target_mid int = null; -- User who actually owns targeted Folder
    target_cid int = null; -- Account target_mid belongs to
    nrows int; -- Rows affected by database command. OK iff == 1.
    
begin

    -- Get folder's owner
    select mid into target_mid from folders where uid = folderid;

    -- Check relations between user and folder's owner
    select allowed, scid, slevel, sisadmin, tcid 
        into result, source_cid, source_level, source_isadmin, target_cid
        from member_can_update_member(source_mid, target_mid);
        
    if result < 1 then -- 9022 = 'error marking folder deleted'
        perform log_permissions_error( '4078', result, 
                    source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;

    
    -- Delete folder (cascades to files)
    delete from Folders cascade where uid = folderid;        
    
    
    -- Error checking
    get diagnostics nrows = row_count;
    if (nrows = 0) then -- 9023 = 'error purging deleted folder'
        perform log_event( source_cid, source_mid, '9079',
                    'No such folder', target_cid, target_mid );
        return 0;
    end if;
        
    -- Success : 1078-9 Folder deleted
    if (source_isadmin = 1) then
        perform log_event( source_cid, source_mid, '1079', '', target_cid, target_mid );
    elsif (source_level <= 1) then
        perform log_event( source_cid, source_mid, '1078', '', target_cid, target_mid );
    else
        perform log_event( source_cid, source_mid, '1077', '', target_cid, target_mid );
    end if;
    
    return 1;

end;
$$ language plpgsql;


