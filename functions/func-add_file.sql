
-- -----------------------------------------------------------------------------
--  add_file()
-- -----------------------------------------------------------------------------
--  returns > 0 : UID of new file created
--  returns   0 : Can't find specified folder
--   -1 thru -9 : Permissions error codes from member_can_update_member()
--  returns -10 : INSERT didn't work, database fail
-----------------------------------------------------------------------------
-- 2013-10-29 dbrown: created
-- 2013-10-30 dbrown: new Name and Description fields
-- -----------------------------------------------------------------------------

create or replace function add_file(

    source_mid int, -- Member making the change
    parent_fid int, -- Parent folder which will own the file
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
    
begin
    
    -- Get folder's owner
    select mid into target_mid from folders where fid = parent_fid;
    if (target_mid is null) then -- 9024 = "error adding item"
        perform log_event( source_cid, source_mid, '9024',
                    'No such folder', target_cid, target_mid );
        return 0; 
    end if;

    -- Check relations between user and folder's owner
    select allowed, scid, tcid into result, source_cid, target_cid
        from member_can_update_member(source_mid, target_mid);

    if (result < 1) then 
        perform log_permissions_error( '9024', result,
                    source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;
    
    -- Insert the new file
    insert into Files ( fid, mid, x_name, x_desc )
        values ( parent_fid, target_mid, fencrypt(_name), fencrypt(_desc) );
    
    -- Error checking
    get diagnostics nrows = row_count;
    select last_value into newfileuid from files_uid_seq;
    if (nrows <> 1) then
        perform log_event( source_cid, source_mid, '9024', 'INSERT INTO FILES failed',
                target_cid, target_mid );
        return -10;
    end if;
    
    -- Success
    perform log_event( source_cid, source_mid, '0024', '', target_cid, target_mid );
    return newfileuid;
    
end;
$$ language plpgsql;
    

