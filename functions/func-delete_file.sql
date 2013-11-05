
-- -----------------------------------------------------------------------------
--  delete_file
-- -----------------------------------------------------------------------------

create or replace function delete_file(

    source_mid int, -- Member making the change
    file_uid   int  -- UID of the file to be deleted
    
) returns int as $$

declare
    result int;
    source_cid int = NULL;
    target_mid int = NULL;
    target_cid int = NULL;
    nrows int;

begin

    -- Get target file's owner
    select mid into target_mid from files f where f.uid = file_uid;
    if (target_mid is null) then -- 9026 = "error deleting item"
        perform log_event( source_cid, source_mid, '9026', 'No such item' );
        return 0;
    end if;
    
    -- Check relation between user and file's owner
    select allowed, scid, tcid into result, source_cid, target_cid
        from member_can_update_member(source_mid, target_mid);

    if (result < 1) then 
        perform log_permissions_error( '9026', result,
                    source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;
    
    
    -- Delete the file
    delete from files where files.uid = file_uid;
    
    
    -- Error checking
    get diagnostics nrows = row_count;
    if (nrows = 0) then
        perform log_event( source_cid, source_mid, '9026', 'No such item',
                    target_cid, target_mid );
        return 0;
    elsif (nrows > 1) then
        perform log_event( source_cid, source_mid, '9026', 'DATABASE INCONSISTENCY',
                    target_cid, target_mid );
        return -10;
    end if;
    
    -- Success
    perform log_event( source_cid, source_mid, '0026', '', target_cid, target_mid);
    return 1;
        
end;
$$ language plpgsql;


