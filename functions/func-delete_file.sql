
-- -----------------------------------------------------------------------------
--  delete_file
-- -----------------------------------------------------------------------------
--  returns:
--      1  : Success
--    -14  : File not found
-- -----------------------------------------------------------------------------
-- 2013-11-01 dbrown: update event codes, changed all "item" to "file"
-- 2013-11-10 dbrown: update retvals, replace magic with constants,
--               removed unnecessary sanity check, source-level eventcodes
-- -----------------------------------------------------------------------------

create or replace function delete_file(

    source_mid int, -- Member making the change
    file_uid   int  -- UID of the file to be deleted
    
) returns int as $$

declare
    EC_OK_DELETED_FILE          constant varchar := '1087';
    EC_OK_OWNER_DELETED_FILE    constant varchar := '1088';
    EC_OK_ADMIN_DELETED_FILE    constant varchar := '1089';
    EC_DEVERR_DELETING_FILE     constant varchar := '9089';
    RETVAL_SUCCESS              constant int :=   1;
    RETVAL_ERR_FILE_NOTFOUND    constant int := -14;
    
    result int;
    source_cid int;
    source_ulevel int;
    source_isadmin int;
    target_mid int;
    target_cid int;
    eventcode_out varchar;
    nrows int;

begin

    -- Get target file's owner
    select mid into target_mid from files f where f.uid = file_uid;
    
    if (target_mid is null) then
        perform log_event( source_cid, source_mid, EC_DEVERR_DELETING_FILE, 'File does not exist' );
        return RETVAL_ERR_FILE_NOTFOUND;
    end if;
    
    
    -- Check relation between this user and the file's owner
    select allowed, scid, slevel, sisadmin, tcid 
        into result, source_cid, source_ulevel, source_isadmin, target_cid
        from member_can_update_member(source_mid, target_mid);

    if (result < 1) then 
        return log_permissions_error( DEVERR_DELETING_FILE, result,
                    source_cid, source_mid, target_cid, target_mid );
    end if;
    
    
    -- Delete the file
    delete from files where files.uid = file_uid;
    
    -- Success
    if (source_isadmin > 0) then 
        eventcode_out := EC_OK_ADMIN_DELETED_FILE;
    elsif (source_isowner > 0) and (source_mid <> target_mid) then 
        eventcode_out := EC_OK_OWNER_DELETED_FILE;
    else
        eventcode_out := EC_OK_DELETED_FILE;
    end if
    

    
    perform log_event( source_cid, source_mid, eventcode_out, null, target_cid, target_mid);
    return RETVAL_SUCCESS;
        
end;
$$ language plpgsql;


