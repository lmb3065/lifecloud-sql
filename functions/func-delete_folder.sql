
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
-- 2013-11-14 dbrown: Organization, Exception handling, More info in eventcodes
-- ---------------------------------------------------------------------------

create or replace function delete_folder(

    source_mid int, -- User making the change
    folderid   int  -- Folder that User wants to delete

) returns int as $$

declare
    EVENT_OK_DELETED_FOLDER       constant char(4) := '1077';
    EVENT_OK_OWNER_DELETED_FOLDER constant char(4) := '1078';
    EVENT_OK_ADMIN_DELETED_FOLDER constant char(4) := '1079';
    EVENT_AUTHERR_DELETING_FOLDER constant char(4) := '6077';
    EVENT_DEVERR_DELETING_FOLDER  constant char(4) := '9077';
    eventcode_out varchar;
    
    RETVAL_SUCCESS             constant int :=   1;
    RETVAL_ERR_FOLDER_NOTFOUND constant int := -13;
    RETVAL_ERR_EXCEPTION       constant int := -98;
    result int;
    
    source_cid      int; -- Account source_mid belongs to
    source_ulevel   int;
    source_isadmin  int;
    target_mid      int; -- User who actually owns targeted Folder
    target_cid      int; -- Account target_mid belongs to
    folder_name     text;
    
begin

    -- Ensure target-folder exists (and get its owner)
    SELECT mid, fdecrypt(x_name) INTO target_mid, folder_name
        FROM folders WHERE uid = folderid;
    if (folder_name is null) then
        perform log_event( source_cid, source_mid, EVENT_DEVERR_DELETING_FOLDER,
                    'Folder ['||folderid||'] does not exist');
        return RETVAL_ERR_FOLDER_NOTFOUND;
    end if;
    

    -- Check that user is allowed to touch folder-owner's stuff
    SELECT allowed, scid, slevel, sisadmin, tcid 
        INTO result, source_cid, source_ulevel, source_isadmin, target_cid
        FROM member_can_update_member(source_mid, target_mid);
    if (result < RETVAL_SUCCESS) then
        perform log_permissions_error( EC_PERMERR_DELETING_FOLDER, result, 
                    source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;

    
    -- Delete the Folder ----------------------------------------------------------
    
    declare
        errno text;
        errmsg text;
        errdetail text;
    begin
        delete from Files where folder_uid = folderid;
        delete from Folders where uid = folderid;
    
    exception when others then
        -- Couldn't delete the Folder!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        perform log_event(_cid, null, EVENT_DEVERR_DELETING_FOLDER, '['||errno||'] '||errmsg||' : '||errdetail);
        RETURN RETVAL_ERR_EXCEPTION;
    end;
        
    
    
    -- Success ---------------------------------------------------------------------
    
    if (source_mid = target_mid) then eventcode_out := EC_OK_DELETED_FOLDER;
    elsif (source_isadmin = 1)   then eventcode_out := EC_OK_ADMIN_DELETED_FOLDER;
    elsif (source_ulevel <= 1)   then eventcode_out := EC_OK_OWNER_DELETED_FOLDER;
    else                              eventcode_out := EC_OK_DELETED_FOLDER;
    end if;
    
    perform log_event( source_cid, source_mid, eventcode_out, 
        '['||folderid||'] '||folder_name, target_cid, target_mid );
    return RETVAL_SUCCESS;

end;
$$ language plpgsql;


