
-- -----------------------------------------------------------------------------
--  add_file()
-- -----------------------------------------------------------------------------
--  returns  > 0 : SUCCESS.  UID of new file created
--  returns    0 : A required argument (_name) was NULL
--  returns  -11 : Source Member does not exist
--  returns  -13 : Destination folder does not exist
--  returns  -27 : Filename already exists in that folder
--  returns  -80 : Source Member has insufficient permissions
--  returns  -82 : Source outranked by Target
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
--                    added source level logging
-- 2013-11-10 dbrown : update to latest revision of eventcodes/retvals
--                    add filename to success event log
-- 2013-11-12 dbrown : add filename to failure event log too; raise warnings
-- -----------------------------------------------------------------------------

create or replace function add_file(

    source_mid        int, -- Member making the change
    parent_folder_uid int, -- Parent folder which will own the file
    _name         varchar, -- \   Attributes of
    _desc         varchar  -- /   the new file
    
) returns int as $$

declare
    EC_OK_ADDED_FILE            constant varchar := '1080';
    EC_OK_OWNER_ADDED_FILE      constant varchar := '1081';
    EC_OK_ADMIN_ADDED_FILE      constant varchar := '1082';
    EC_USERERR_ADDING_FILE      constant varchar := '4080';
    EC_PERMERR_ADDING_FILE      constant varchar := '6080';
    EC_DEVERR_ADDING_FILE       constant varchar := '9080';

    RETVAL_ERR_ARG_MISSING      constant int :=   0;
    RETVAL_ERR_FOLDER_NOTFOUND  constant int := -13;
    RETVAL_ERR_FILE_EXISTS      constant int := -27;

    result          int;
    source_cid      int;
    source_level    int;
    source_isadmin  int;
    target_mid      int;
    target_cid      int;
    existing_uid    int;
    newfileuid      int;
    eventcode_out   varchar;
        
begin

    -- Make sure source user exists
    
    if not exists (select mid from members where mid = source_mid)
        raise notice 'add_file(): Fail - Source MID [%] does not exist', source_mid;
        perform log_event( null, null, EC_DEVERR_ADDING_FILE,
                    'Source MID '||source_mid||' does not exist' );
    
    -- Get folder's owner
    
    select mid into target_mid from folders where uid = parent_folder_uid;
    if (target_mid is null) then
        raise notice 'add_file(): Fail - Folder [%] does not exist', parent_folder_uid; 
        perform log_event( null, source_mid, EC_DEVERR_ADDING_FILE,
                    'Folder '||parent_folder_uid||' does not exist' );
        return RETVAL_ERR_FOLDER_NOTFOUND; 
    end if;

    
    -- Check relations between user and folder's owner

    select allowed, scid, slevel, sisadmin, tcid 
        into result, source_cid, source_level, source_isadmin, target_cid
        from member_can_update_member(source_mid, target_mid);
    if (result < 1) then 
        perform log_permissions_error( EC_PERMERR_ADDING_FILE, result,
                  source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;
    
    -- Validate arguments
    
    if (_name is null) or (length(_name) = 0) then
        raise notice 'add_file(): Fail - Name is required';
        perform log_event( null, source_mid, EC_DEVERR_ADDING_FILE, 'Name is required' );
        return RETVAL_ERR_ARG_MISSING;
    end if;
    
    -- Ensure file doesn't already exist in folder 
    
    select uid into existing_uid from Files
        where folder_uid = parent_folder_uid
        and lower(fdecrypt(x_name)) = lower(_name);
    if (existing_uid is not null) then
        raise notice 'add_file(): Fail - A file named "%" already exists in folder [%]', _name, parent_folder_uid;
        perform log_event( source_cid, source_mid, EC_USERERR_ADDING_FILE,
            'A file named "'||_name||'" already exists in folder "'||parent_folder_uid, target_cid, target_mid);
        return RETVAL_ERR_FILE_EXISTS;
    end if;
    
    
    -- Add file to database
    
    insert into Files ( folder_uid, mid, x_name, x_desc, modified_by )
        values ( parent_folder_uid, target_mid, 
            fencrypt(_name), fencrypt(_desc), source_mid );


    -- Success
    
    if (source_isadmin = 1) then
        eventcode_out := EC_OK_ADMIN_ADDED_FILE;
    elsif (source_level = 0) and (source_mid <> target_mid) then
        eventcode_out := EC_OK_OWNER_ADDED_FILE;
    else
        eventcode_out := EC_OK_ADDED_FILE;
    end if;
    
    perform log_event( source_cid, source_mid, eventcode_out, _name, target_cid, target_mid );
    
    select last_value into newfileuid from files_uid_seq;
    raise notice 'add_file(): Success - File [%] created in Folder [%]', newfileuid, parent_folder_uid;
    return newfileuid;
    
end
$$ language plpgsql;
    

