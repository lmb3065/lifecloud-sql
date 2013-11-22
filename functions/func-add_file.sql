-- ===========================================================================
--  add_file()
-- ---------------------------------------------------------------------------
--  Add a File to a Folder
-- ---------------------------------------------------------------------------
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
-- 2013-11-12 dbrown : add filename to failure event log too, raise notices,
--                     simplified user-level eventcode logging
-- 2013-11-13 dbrown : Organization, Exception Handling, More info in events
-- 2013-11-14 dbrown : Trusted (lvl 1) should have same rights as Owner (lvl 0)
-- 2013-11-14 dbrown : Updated eventcode constants
-- 2013-11-16 dbrown : Added argument/field _content_type varchar
-- ---------------------------------------------------------------------------

create or replace function add_file
(
    source_mid        int, -- Member making the change
    parent_folder_uid int, -- Parent folder which will own the file
    _name         varchar, -- \
    _desc         varchar, --  >  Attributes of the new file
    _content_type varchar  -- /

) returns int as $$

declare
    EVENT_OK_ADDED_FILE            constant varchar := '1080';
    EVENT_OK_OWNER_ADDED_FILE      constant varchar := '1081';
    EVENT_OK_ADMIN_ADDED_FILE      constant varchar := '1082';
    EVENT_USERERR_ADDING_FILE      constant varchar := '4080';
    EVENT_AUTHERR_ADDING_FILE      constant varchar := '6080';
    EVENT_DEVERR_ADDING_FILE       constant varchar := '9080';
    eventcode_out   varchar;

    RETVAL_SUCCESS              constant int :=   1;
    RETVAL_ERR_ARG_INVALID      constant int :=   0;
    RETVAL_ERR_FOLDER_NOTFOUND  constant int := -13;
    RETVAL_ERR_FILE_EXISTS      constant int := -26;
    result          int;

    source_cid int; source_level int; source_isadmin int;
    target_mid int; target_cid int;
    existing_uid int;
    newfileuid int;

begin

    -- Ensure a name was supplied
    if (_name is null) or (length(_name) = 0) then
        perform log_event( null, source_mid, EVENT_DEVERR_ADDING_FILE, 'Name is required' );
        return RETVAL_ERR_ARG_INVALID;
    end if;


    -- Ensure destination folder exists (and get its owner)
    select mid into target_mid from folders where uid = parent_folder_uid;
    if (target_mid is null) then
        perform log_event( null, source_mid, EVENT_DEVERR_ADDING_FILE,
                    'Folder '||parent_folder_uid||' does not exist' );
        return RETVAL_ERR_FOLDER_NOTFOUND;
    end if;


    -- Ensure user is allowed to modify Folder Owner's Stuff
    select allowed, scid, slevel, sisadmin, tcid
        into result, source_cid, source_level, source_isadmin, target_cid
        from member_can_update_member(source_mid, target_mid);
    if (result < RETVAL_SUCCESS) then
        perform log_permissions_error( EVENT_AUTHERR_ADDING_FILE, result,
                  source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;


    -- Ensure folder doesn't already contain this file
    select uid into existing_uid from Files
        where folder_uid = parent_folder_uid
        and lower(fdecrypt(x_name)) = lower(_name);
    if (existing_uid is not null) then
        perform log_event( source_cid, source_mid, EVENT_USERERR_ADDING_FILE, 'File ['
            ||existing_uid||'] named "'||_name||'" already exists in folder ['
            ||parent_folder_uid||']', target_cid, target_mid);
        return RETVAL_ERR_FILE_EXISTS;
    end if;



    -- Add file to database

    declare
        errno text;
        errmsg text;
        errdetail text;

    begin

        INSERT INTO Files ( folder_uid, mid, x_name, x_desc, content_type, modified_by )
        VALUES ( parent_folder_uid, target_mid, fencrypt(_name), fencrypt(_desc),
            _content_type, source_mid );
        select last_value into newfileuid from files_uid_seq;

    exception when others then

        -- Couldn't add File!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        perform log_event(_cid, null, EVENT_DEVERR_ADDING_FILE, '['||errno||'] '||errmsg||' : '||errdetail);
        RETURN RETVAL_ERR_EXCEPTION;

    end;



    -- Success

    if (source_mid = target_mid) then eventcode_out := EVENT_OK_ADDED_FILE;
    elsif (source_isadmin = 1)   then eventcode_out := EVENT_OK_ADMIN_ADDED_FILE;
    elsif (source_level  <= 1)   then eventcode_out := EVENT_OK_OWNER_ADDED_FILE;
    else eventcode_out := EVENT_OK_ADDED_FILE;
    end if;

    perform log_event( source_cid, source_mid, eventcode_out,
                '['||newfileuid||'] '||_name, target_cid, target_mid );
    return newfileuid;

end
$$ language plpgsql;
