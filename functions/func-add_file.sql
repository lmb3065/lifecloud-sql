
-- -----------------------------------------------------------------------------
--  add_file()
-- -----------------------------------------------------------------------------
--  returns  > 0 : UID of new file created
--  returns   -1 : Filename already exists in that folder
--  returns   -5 : Can't find specified folder
--  -80 thru -98 : Permissions error
-----------------------------------------------------------------------------
-- 2013-10-29 dbrown: created
-- 2013-10-30 dbrown: new Name and Description fields
-- 2013-11-01 dbrown: update event codes, disallow dup filenames in a folder
-- 2013-11-01 dbrown: change fid to folder_uid
-- 2013-11-06 dbrown: put source_mid into new Files column 'modified_by'
-- 2013-11-06 dbrown: fixed broken 'disallow dup filenames' change
-- 2013-11-06 dbrown: Updated return values and lots of cleanup
--                    Replaced all magic codes and numbers with constants
--                    Removed unnecessary INSERT sanity check
--                    Added requirement that File must have a name
-- -----------------------------------------------------------------------------

create or replace function add_file(

    source_mid        int, -- Member making the change
    parent_folder_uid int, -- Parent folder which will own the file
    _name         varchar, -- \   Attributes of
    _desc         varchar  -- /   the new file
    
) returns int as $$

declare
    RETVAL_ERR_ARG_MISSING      constant int := 0;
    RETVAL_ERR_FOLDER_NOTFOUND  constant int := -12;
    RETVAL_ERR_FILE_EXISTS      constant int := -26;
    EC_OK_ADDED_FILE            constant varchar := '1080';
    EC_USERERR_ADDING_FILE      constant varchar := '4080';
    EC_DEVERR_ADDING_FILE       constant varchar := '9080';
    EC_DEVERR_ARGS_MISSING      constant varchar := '9500';

    result int;
    source_cid int = NULL;
    target_mid int = NULL;
    target_cid int = NULL;
    newfileuid int;
        
begin

    -- Validate arguments
    
    if (_name is null) or (length(_name) = 0) then
        perform log_event( null, source_mid, EC_DEVERR_ARGS_MISSING, 'No file name was given' );
        return RETVAL_ERR_ARG_MISSING;
    end if;


    -- Get folder's owner
    
    select mid into target_mid from folders where uid = parent_folder_uid;
    if (target_mid is null) then
        perform log_event( source_cid, source_mid, EC_DEVERR_ADDING_FILE, 
                   'Folder does not exist', target_cid, target_mid );
        return RETVAL_ERR_FOLDER_NOTFOUND; 
    end if;

    
    -- Check relations between user and folder's owner

    select allowed, scid, tcid into result, source_cid, target_cid
        from member_can_update_member(source_mid, target_mid);
        
    if (result < 1) then 
        perform log_permissions_error( EC_DEVERR_ADDING_FILE,
                    result, source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;
    
    
    -- Ensure file doesn't already exist in folder 
    
    if exists (select uid from Files
                    where folder_uid = parent_folder_uid
                    and lower(fdecrypt(x_name)) = lower(_name) ) then
        perform log_event( source_cid, source_mid, EC_USERERR_ADDING_FILE,
                    'File already exists in folder', target_cid, target_mid);
        return RETVAL_ERR_FILE_EXISTS;
    end if;
    
    
    -- Insert the new file
    
    insert into Files ( folder_uid, mid, x_name, x_desc, modified_by )
        values ( parent_folder_uid, target_mid, fencrypt(_name), fencrypt(_desc), source_mid );
    

    perform log_event( source_cid, source_mid, EC_OK_ADDED_FILE, null, target_cid, target_mid );
    select last_value into newfileuid from files_uid_seq;
    return newfileuid;
    
end
$$ language plpgsql;
    

