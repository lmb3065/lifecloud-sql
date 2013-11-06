
-- -----------------------------------------------------------------------------
--  add_file()
-- -----------------------------------------------------------------------------
--  returns > 0 : UID of new file created
--  returns   0 : Can't find specified folder
--   -1 thru -9 : Permissions error codes from member_can_update_member()
--  returns -10 : A file with that name already exists in that folder
--  returns -11 : INSERT didn't work, database fail
-----------------------------------------------------------------------------
-- 2013-10-29 dbrown: created
-- 2013-10-30 dbrown: new Name and Description fields
-- 2013-11-01 dbrown: update event codes, disallow dup filenames in a folder
-- 2013-11-01 dbrown: change fid to folder_uid
-- 2013-11-06 dbrown: put source_mid into new Files column 'modified_by'
-- 2013-11-06 dbrown: fixed broken 'disallow dup filenames' change
-- -----------------------------------------------------------------------------

create or replace function add_file(

    source_mid int, -- Member making the change
    parent_folder_uid int, -- Parent folder which will own the file
    _name varchar,
    _desc varchar
    
) returns int as $$

declare
    result int;
    source_cid int = NULL;
    target_mid int = NULL;
    target_cid int = NULL;
    nrows int;
    newfileuid int;
    
    _ext_name varchar;
begin
    
    -- Get folder's owner
    select mid into target_mid from folders where uid = parent_folder_uid;
    if (target_mid is null) then -- 9024 = "error adding item"
        perform log_event( source_cid, source_mid, '9080', 'no such parent folder', target_cid, target_mid );
        return 0; 
    end if;

    -- Check relations between user and folder's owner
    select allowed, scid, tcid into result, source_cid, target_cid
        from member_can_update_member(source_mid, target_mid);

    if (result < 1) then 
        perform log_permissions_error( '4080', result, source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;
    
    if exists (select uid from Files
                    where folder_uid = parent_folder_uid
                    and lower(fdecrypt(x_name)) = lower(_name) ) then
        perform log_event( source_cid, source_mid, '4080', 'Name collision', target_cid, target_mid);
        return -10;
    end if;
    
    -- Insert the new file
    insert into Files ( folder_uid, mid, x_name, x_desc, modified_by )
        values ( parent_folder_uid, target_mid, fencrypt(_name), fencrypt(_desc), source_mid );
    
    -- Error checking
    get diagnostics nrows = row_count;
    select last_value into newfileuid from files_uid_seq;
    if (nrows <> 1) then
        perform log_event( source_cid, source_mid, '9080', 'insert into Files failed',
                target_cid, target_mid );
        return -11;
    end if;
    
    -- Success
    perform log_event( source_cid, source_mid, '1080', '', target_cid, target_mid );
    return newfileuid;
    
end
$$ language plpgsql;
    

