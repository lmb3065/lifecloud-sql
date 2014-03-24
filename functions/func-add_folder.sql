-- ==========================================================================
--  add_folder()
-----------------------------------------------------------------------------
--  Add a Folder to a Member
-----------------------------------------------------------------------------
-- 2013-10-10 dbrown: created
-- 2013-10-11 dbrown: removed parentfid
-- 2013-10-11 dbrown: added error checking and logging
-- 2013-10-12 dbrown: insure against passed NULLs
-- 2013-10-12 dbrown: track trans-user folder changes (for logging)
-- 2013-10-13 dbrown: perms/retvals moved into member_can_update_member()
-- 2013-10-15 dbrown: removed _complete and _vieworder
-- 2013-10-29 dbrown: folders no longer have 'deleted' field
-- 2013-11-01 dbrown: revised EventCodes, removed Logging arg
-- 2013-11-01 dbrown: replaced Logging arg
-- 2013-11-06 dbrown: Disallow folder name collision, returns new folder UID
-- 2013-11-06 dbrown: changed return values and lots of cleanup
--                     disallows empty folder name
--                     removed unnecessary INSERT sanity check
--                     replaced magic numbers and codes with constants
-- 2013-11-10 dbrown: updated to latest eventcodes, add name to success event
-- 2013-11-13 dbrown: organized, more information in eventlog details
-- 2013-11-14 dbrown: TRUSTED (1) should have the same rights as Owner (0)
-- 2013-12-11 dbrown: replaced itemtype with app_uid
-----------------------------------------------------------------------------

create or replace function add_folder(

    source_mid     int,                 -- Member performing the action
    target_mid     int,                 -- Owner of the new folder
    _foldername    varchar,             -- \
    _description   varchar,             --  > Attributes of the new folder
    _app_uid       int,                 -- /
    _logsuccess    int      default 1   -- Add successes to the eventlog?

) returns int as $$

declare
    EVENT_OK_ADDED_FOLDER         constant varchar := '1070';
    EVENT_OK_OWNER_ADDED_FOLDER   constant varchar := '1071';
    EVENT_OK_ADMIN_ADDED_FOLDER   constant varchar := '1072';
    EVENT_USERERR_ADDING_FOLDER   constant varchar := '4070';
    EVENT_AUTHERR_ADDING_FOLDER   constant varchar := '6070';
    EVENT_DEVERR_ADDING_FOLDER    constant varchar := '9070';

    RETVAL_SUCCESS             constant int :=  1;
    RETVAL_ERR_ARG_INVALID     constant int :=  0;
    RETVAL_ERR_FOLDER_EXISTS   constant int := -25;
    RETVAL_ERR_EXCEPTION       constant int := -98;

    result int;
    newfolderuid int;

    source_cid int;
    source_level int;
    source_isadmin int;
    target_cid int;
    existing_uid int;
    eventcode_out varchar;

begin


    -- Check arguments --------------------------------------------------------


    -- Ensure we have a Name to give the folder
    if (_foldername is null) or (length(_foldername) = 0) then
        perform log_event( null, source_mid, EVENT_DEVERR_ADDING_FOLDER,
                    'FolderName is required' );
        return RETVAL_ERR_ARG_INVALID;
    end if;


    -- Ensure User-Member is allowed to modify Target-Member's Stuff
    select allowed, scid, slevel, sisadmin, tcid
        into result, source_cid, source_level, source_isadmin, target_cid
        from member_can_update_member(source_mid, target_mid);
    if (result < RETVAL_SUCCESS) then
        perform log_permissions_error( EVENT_AUTHERR_ADDING_FOLDER, result,
                    source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;


    -- Ensure user doesn't already have this folder
    select uid into existing_uid from folders
        where mid = target_mid
        and lower(fdecrypt(x_name)) = lower(_foldername); -- case insensitive
    if (existing_uid is not null) then
        perform log_event( source_cid, source_mid, EVENT_USERERR_ADDING_FOLDER,
                    'Member already has folder '||_foldername, target_cid, target_mid );
        return RETVAL_ERR_FOLDER_EXISTS;
    end if;



    -- Passed tests, add the Folder -------------------------------------------

    declare errno text; errmsg text; errdetail text;
    begin
        insert into Folders ( mid, cid, x_name, x_desc, app_uid )
            values ( target_mid, target_cid, fencrypt(_foldername),
                        fencrypt(_description), _app_uid );

    exception when others then
        -- Couldn't add Folder!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        perform log_event(source_cid, source_mid, EVENT_DEVERR_ADDING_FOLDER, '['||errno||'] '||errmsg||' : '||errdetail, target_cid, target_mid);
        RETURN RETVAL_ERR_EXCEPTION;
    end;



    -- Success ----------------------------------------------------------------


    -- Log if requested
    select last_value into newfolderuid from folders_uid_seq;

    if (_logsuccess > 0) then
        if (source_mid = target_mid) then eventcode_out := EVENT_OK_ADDED_FOLDER;
        elsif (source_isadmin = 1)   then eventcode_out := EVENT_OK_ADMIN_ADDED_FOLDER;
        elsif (source_level  <= 1)   then eventcode_out := EVENT_OK_OWNER_ADDED_FOLDER;
        else eventcode_out := EVENT_OK_ADDED_FOLDER;
        end if;

        perform log_event( source_cid, source_mid, eventcode_out,
                    '['||newfolderuid||'] '||_foldername, target_cid, target_mid );
    end if;

    return newfolderuid;

end
$$ language plpgsql;
