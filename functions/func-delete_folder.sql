
-- ===========================================================================
--  delete_folder
-- ---------------------------------------------------------------------------
-- 2013-10-13 dbrown: created
-- 2013-10-29 dbrown: Simply deletes rows instead of marking them deleted
-- 2013-10-29 dbrown: folderid must be owned by target_mid
-- 2013-10-29 dbrown: target_mid no longer accepted
-- 2013-11-01 dbrown: revised event codes, added source-level eventcodes
-- 2013-11-01 dbrown: changed folder.fid to folder.uid
-- 2013-11-11 dbrown: update retvals and eventcodes, remove magic, 
--               remove unnecessary sanity check
--               logs foldername in eventlog (or uid on error)
-- ---------------------------------------------------------------------------

create or replace function delete_folder(

    source_mid int, -- User making the change
    folderid   int  -- Folder that User wants to delete

) returns int as $$

declare
    EC_OK_DELETED_FOLDER       constant varchar := '1077';
    EC_OK_OWNER_DELETED_FOLDER constant varchar := '1078';
    EC_OK_ADMIN_DELETED_FOLDER constant varchar := '1079';
    EC_PERMERR_DELETING_FOLDER constant varchar := '6077';
    EC_DEVERR_DELETING_FOLDER  constant varchar := '9077';
    eventcode_out varchar;
    
    RETVAL_SUCCESS         constant int :=   1;
    RETVAL_FOLDER_NOTFOUND constant int := -13;
    result int;
    
    source_cid      int; -- Account source_mid belongs to
    source_ulevel   int;
    source_isadmin  int;
    target_mid      int; -- User who actually owns targeted Folder
    target_cid      int; -- Account target_mid belongs to
    folder_name     text;
    
begin

    -- Get folder's owner
    SELECT mid, fdecrypt(x_name) INTO target_mid, folder_name
        FROM folders
        WHERE uid = folderid;
        
    if (target_mid is null) then
        perform log_event( source_cid, source_mid, EC_DEVERR_DELETING_FOLDER,
                    'UID '||folderid||' does not exist');
        return RETVAL_FOLDER_NOTFOUND;
    end if;
    

    -- Check relations between user and folder's owner
    SELECT allowed, scid, slevel, sisadmin, tcid 
        INTO result, source_cid, source_ulevel, source_isadmin, target_cid
        FROM member_can_update_member(source_mid, target_mid);
        
    if result < 1 then
        perform log_permissions_error( EC_PERMERR_DELETING_FOLDER, result, 
                    source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;

    
    -- Delete folder (cascades to files)
    delete from Folders where uid = folderid;        
    
    
    -- Success
    if (source_mid = target_mid) then eventcode_out := EC_OK_DELETED_FOLDER;
    elsif (source_isadmin = 1)   then eventcode_out := EC_OK_ADMIN_DELETED_FOLDER;
    elsif (source_ulevel <= 1)   then eventcode_out := EC_OK_OWNER_DELETED_FOLDER;
    else                              eventcode_out := EC_OK_DELETED_FOLDER;
    end if;
    
    perform log_event( source_cid, source_mid, eventcode_out, folder_name, target_cid, target_mid );
    return RETVAL_SUCCESS;

end;
$$ language plpgsql;


