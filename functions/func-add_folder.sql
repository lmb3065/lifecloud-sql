
-- ==========================================================================
-- add_folder()
-----------------------------------------------------------------------------
-- returns > 0 : SUCCESS. Retval is the UID of new Folder created
-- returns   0 : A required argument (_foldername) was NULL
-- returns -11 : Source Member does not exist
-- returns -12 : Target Member does not exist
-- returns -25 : Member already has folder with that name
-- returns -80 : Source Member has insufficient permissions
-- returns -81 : Source and Target are in different Accounts
-- returns -82 : Source outranked by Target
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
-----------------------------------------------------------------------------

create or replace function add_folder(

    source_mid     int,                 -- Member performing the action
    target_mid     int,                 -- Owner of the new folder
    _foldername    varchar,             -- \
    _description   varchar,             --  > Attributes of the new folder
    _itemtype      int      default 0,  -- /
    _logsuccess    int      default 1   -- Add successes to the eventlog?
    
) returns int as $$

declare
    EC_OK_ADDED_FOLDER         constant varchar := '1070';
    EC_OK_OWNER_ADDED_FOLDER   constant varchar := '1071';
    EC_OK_ADMIN_ADDED_FOLDER   constant varchar := '1072';
    EC_USERERR_ADDING_FOLDER   constant varchar := '4070';
    EC_DEVERR_ADDING_FOLDER    constant varchar := '9070';
    RETVAL_ERR_ARG_MISSING     constant int :=  0;
    RETVAL_ERR_MEMBER_NOTFOUND constant int := -11;
    RETVAL_ERR_FOLDER_EXISTS   constant int := -25;

    result int;
    newfolderuid int;

    source_cid int;
    source_level int;
    source_isadmin int;
    target_cid int;
    
    existing_uid int;

begin

    -- Validate arguments
    
    if (_foldername is null) or (length(_foldername) = 0) then
        perform log_event( null, source_mid, EC_USERERR_ADDING_FOLDER,
                    'Required argument _foldername was null' );
        return RETVAL_ERR_ARG_MISSING;
    end if;

    
    -- Check relations between source and target members

    select allowed, scid, slevel, sisadmin, tcid 
        into result, source_cid, source_level, source_isadmin, target_cid
        from member_can_update_member(source_mid, target_mid);
    if (result < 1) then
        return log_permissions_error( EC_DEVERR_ADDING_FOLDER, result,
                                      source_cid, source_mid, target_cid, target_mid );
    end if;
    
    
    -- Ensure the member doesn't already have a folder with this name
    
    select uid into existing_uid from folders
        where mid = target_mid
        and lower(fdecrypt(x_name)) = lower(_foldername);
    if (existing_uid is not null) then
        perform log_event( source_cid, source_mid, EC_USERERR_ADDING_FOLDER,
                           'Member already has folder with that name',
                           target_cid, target_mid );
        return RETVAL_ERR_FOLDER_EXISTS;
    end if;
    
    
    -- Add folder to database --
    
    insert into Folders ( mid, cid, x_name, x_desc, itemtype )
        values ( target_mid, target_cid, fencrypt(_foldername), fencrypt(_description), _itemtype );
    select last_value into newfolderuid from folders_uid_seq;

    -- Success
    
    if (_logsuccess = 0) then return newfolderuid; end if;
            
    if (source_isadmin = 1) then 
        perform log_event( source_cid, source_mid, EC_OK_ADMIN_ADDED_FOLDER, null, target_cid, target_mid );
    elsif (source_level = 0) then
        perform log_event( source_cid, source_mid, EC_OK_OWNER_ADDED_FOLDER, null, target_cid, target_mid );
    else
        perform log_event( source_cid, source_mid, EC_OK_ADDED_FOLDER, null, target_cid, target_mid );
    end if;

    return newfolderuid;
    
end;
$$ language plpgsql;


