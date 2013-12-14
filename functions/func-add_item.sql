-- ===========================================================================
--  function add_item
-- ---------------------------------------------------------------------------
--  add an Item.  Returns UID of the item created (+), or an error code (-).
-- ---------------------------------------------------------------------------
--  2013-12-12 dbrown: created
--  2013-12-14 dbrown: fixed typo
-- ---------------------------------------------------------------------------

create or replace function add_item(

    source_mid int,     -- Member (MID) making this change
    _folder_uid int,     -- Folder which will contain this Item
    _item_name text,             --  \  Attributes of
    _item_desc text default '',  --   >  the new file
    _app_uid int default null    --  /

) returns int as $$

declare
    EVENT_OK_ADDED_ITEM         constant varchar := '1100';
    EVENT_OK_OWNER_ADDED_ITEM   constant varchar := '1101';
    EVENT_OK_ADMIN_ADDED_ITEM   constant varchar := '1102';
    EVENT_USERERR_ADDING_ITEM   constant varchar := '4100';
    EVENT_AUTHERR_ADDING_ITEM   constant varchar := '6100';
    EVENT_DEVERR_ADDING_ITEM    constant varchar := '9100';
    eventcode_out varchar;

    RETVAL_SUCCESS              constant int := 1;
    RETVAL_ERR_ARG_INVALID      constant int := 0;
    RETVAL_ERR_FOLDER_NOTFOUND  constant int := -13;
    RETVAL_ERR_ITEM_EXISTS      constant int := -27;
    result int;

    source_cid int; source_level int; source_isadmin int;
    target_mid int; target_cid int;
    existing_uid int;
    newuid int;

begin

    -- Ensure Name was supplied
    if (length(_item_name)=0) then
        perform log_event( null, source_mid, EVENT_DEVERR_ADDING_ITEM, 'Item_Name is required' );
        return RETVAL_ERR_ARG_INVALID;
    end if;

    -- If app_uid was supplied, ensure it is valid
    if (_app_uid is not null)
    and (_app_uid not in (select uid from ref_apps)) then
        perform log_event( null, source_mid, EVENT_DEVERR_ADDING_ITEM, 'App_UID '|| _app_uid ||' is not in ref_apps' );
        return RETVAL_ERR_ARG_INVALID;
    end if;

    -- Ensure destination folder exists (and get its owner)
    select mid into target_mid from folders where uid = _folder_uid;
    if (target_mid is null) then
        perform log_event( null, source_mid, EVENT_DEVERR_ADDING_ITEM, 'Folder UID' || _folder_uid ||' does not exist' );
        return RETVAL_ERR_ARG_INVALID;
    end if;

    -- Ensure user is allowed to modify Folder Owner's Stuff
    select allowed, scid, slevel, sisadmin, tcid
        into result, source_cid, source_level, source_isadmin, target_cid
        from member_can_update_member(source_mid, target_mid);
    if (result < RETVAL_SUCCESS) then
        perform log_permissions_error( EVENT_AUTHERR_ADDING_ITEM, result,
                  source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;

    -- Ensure folder doesn't already contain an Item with this name
    select uid into existing_uid from Items
        where folder_uid = _folder_uid
        and lower(fdecrypt(x_name)) = lower(_item_name);
    if (existing_uid is not null) then
        perform log_event( source_cid, source_mid, EVENT_USERERR_ADDING_ITEM, 'Item ['
            ||existing_uid||'] named "'||_item_name||'" already exists in folder ['
            ||_folder_uid||']', target_cid, target_mid );
        return RETVAL_ERR_ITEM_EXISTS;
    end if;


    -- ADD ITEM TO DATABASE

    declare errno text; errmsg text; errdetail text;
    begin

        INSERT INTO Items( mid, cid, folder_uid, app_uid, x_name, x_desc )
        VALUES ( source_mid, source_cid, _folder_uid, _app_uid,
                    fencrypt(_item_name), fencrypt(_item_desc));
        select last_value into newuid from items_uid_seq;

    exception when others then

        -- Couldn't insert file!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        perform log_event(_cid, null, EVENT_DEVERR_ADDING_ITEM, '['||errno||'] '||errmsg||' : '||errdetail);
        RETURN RETVAL_ERR_EXCEPTION;

    end;


    -- Success

    if (source_mid = target_mid) then eventcode_out := EVENT_OK_ADDED_ITEM;
    elsif (source_isadmin = 1)   then eventcode_out := EVENT_OK_ADMIN_ADDED_ITEM;
    elsif (source_level  <= 1)   then eventcode_out := EVENT_OK_OWNER_ADDED_ITEM;
    else eventcode_out := EVENT_OK_ADDED_ITEM;
    end if;

    perform log_event( source_cid, source_mid, eventcode_out, null, target_cid, target_mid );
    return newuid;

end
$$ language plpgsql;

