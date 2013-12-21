-- =============================================================================
-- update_folder()
-- ----------------------------------------------------------------------------
-- 2013-10-29 dbrown: created, based on stripped-down update_member()
-- 2013-10-29 dbrown: Fixed eventcodes, removed level-dependent logging/retval
-- 2013-11-01 dbrown: Update eventcodes
-- 2013-11-01 dbrown: change folder.fid to folder.uid
-- 2013-11-15 dbrown: Organization, eventcodes, retvals, more arg checking
-- 2013-12-14 dbrown: Fixed Error -25 when _folder_uid is already named _name
-- -----------------------------------------------------------------------------

create or replace function update_folder(

    source_mid    int,                       -- Member making the change
    _folder_uid   int,                       -- Folder being changed
    _name         varchar(64)  default null, -- Fields of the member record
    _desc         varchar      default null  --  that can be updated

) returns integer as $$

declare
    EVENT_OK_UPDATED_FOLDER         constant char(4) := '1073';
    EVENT_OK_OWNER_UPDATED_FOLDER   constant char(4) := '1074';
    EVENT_OK_ADMIN_UPDATED_FOLDER   constant char(4) := '1075';
    EVENT_USERERR_UPDATING_FOLDER   constant char(4) := '4073';
    EVENT_AUTHERR_UPDATING_FOLDER   constant char(4) := '6073';
    EVENT_DEVERR_UPDATING_FOLDER    constant char(4) := '9073';
    event_out char(4);

    RETVAL_SUCCESS              constant int := 1;
    RETVAL_ERR_ARGUMENTS        constant int := 0;
    RETVAL_ERR_FOLDER_NOTFOUND  constant int := -13;
    RETVAL_ERR_FOLDER_EXISTS    constant int := -25;
    RETVAL_ERR_EXCEPTION        constant int := -98;
    result int;

    source_cid int;
    source_level int;
    source_isadmin int;
    target_cid int;
    target_mid int;
    x_new_name bytea = null; -- Encrypted (x) versions
    x_new_desc bytea = null; --   of new-data fields
    nrows int;


begin

    -- Check Arguments -------------------------------------------------------

    if coalesce(_name, _desc) is null then
        -- no arguments; nothing to do
        return RETVAL_ERR_ARGUMENTS;
    end if;

    -- Ensure target folder exists (and get its owner)
    SELECT mid INTO target_mid FROM folders WHERE uid = _folder_uid;
    if (target_mid is null) then
        perform log_event( source_mid, null, EVENT_DEVERR_UPDATING_FOLDER,
                    'Folder UID ['||_folder_uid||'] does not exist' );
        return RETVAL_ERR_FOLDER_NOTFOUND;
    end if;

    -- Ensure we're not going to duplicate some other folder's name
    if exists (
        select uid from folders where mid = target_mid
            and lower(fdecrypt(x_name)) = lower(_name)
            and uid <> _folder_uid
    ) then
        perform log_event( source_mid, target_mid, EVENT_USERERR_UPDATING_FOLDER,
                    'Member already has a folder named '||_name );
        return RETVAL_ERR_FOLDER_EXISTS;
    end if;

    -- Encrypt any arguments we have
    if (_name is not null) then x_new_name := fencrypt(_name); end if;
    if (_desc is not null) then x_new_desc := fencrypt(_desc); end if;


    -- Check Authorization ---------------------------------------------------

    SELECT allowed, scid, slevel, sisadmin, tcid
        INTO result, source_cid, source_level, source_isadmin, target_cid
        FROM member_can_update_member(source_mid, target_mid);

    if (result < RETVAL_SUCCESS) then
        perform log_permissions_error( EVENT_AUTHERR_UPDATING_FOLDER, result,
                source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;


    -- Perform Update --------------------------------------------------------

    declare
        errno text;
        errmsg text;
        errdetail text;
    begin
        update Folders
        set x_name  = coalesce(x_new_name, folders.x_name),
            x_desc  = coalesce(x_new_desc, folders.x_desc),
            updated = clock_timestamp()
        where uid = _folder_uid;

    exception when others then
        -- Couldn't update Folder!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        perform log_event(_cid, null, EVENT_DEVERR_UPDATING_FOLDER, '['||errno||'] '||errmsg||' : '||errdetail);
        RETURN RETVAL_ERR_EXCEPTION;
    end;


    -- Success

    if (source_mid = target_mid) then event_out := EVENT_OK_UPDATED_FOLDER;
    elsif (source_isadmin = 1)   then event_out := EVENT_OK_ADMIN_UPDATED_FOLDER;
    elsif (source_level <= 1)    then event_out := EVENT_OK_OWNER_UPDATED_FOLDER;
    else event_out := EVENT_OK_UPDATED_FOLDER;
    end if;

    perform log_event( source_cid, source_mid, event_out, null, target_cid, target_mid );
    return RETVAL_SUCCESS;

end;
$$ language plpgsql;


