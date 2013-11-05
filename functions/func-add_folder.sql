
-- ==========================================================================
-- add_folder
-----------------------------------------------------------------------------
-- return values from member_can_update_member
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
-----------------------------------------------------------------------------

create or replace function add_folder(

    source_mid     int,
    target_mid     int,
    _foldername    varchar,
    _description   varchar,
    _itemtype      int      default 0,
    _logging       int      default 1
    
) returns int as $$

declare
    result int;
    nrows int; 

    source_cid int;
    source_level int;
    source_isadmin int;
    target_cid int;

begin

    -- Check permissions

    select allowed, scid, slevel, sisadmin, tcid 
        into result, source_cid, source_level, source_isadmin, target_cid
        from member_can_update_member(source_mid, target_mid);
    
    if result < 1 then -- 4070 = User error inserting folder
        perform log_permissions_error( '4070', result, source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;
    
    -- Add folder to database --
    
    insert into Folders (
        mid, cid, x_name, x_desc,
        itemtype )
    values (
        target_mid, target_cid, fencrypt(_foldername), fencrypt(_description), 
        _itemtype );

    -- Error-checking
        
    get diagnostics nrows = row_count;    
    if (nrows <> 1) then
        -- Log error regardless of _logging argument
        -- 9070 = database error inserting folder
        perform log_event( source_cid, source_mid, '9070', 'insert into Folders failed', target_cid, target_mid );
        return -10;
    end if;

    
    -- Success : 1070 new folder added
    
    if (_logging = 1) then
        if (source_isadmin = 1) then
            perform log_event( source_cid, source_mid, '1072', '', target_cid, target_mid );
        elsif (source_level = 0) then
            perform log_event( source_cid, source_mid, '1071', '', target_cid, target_mid );
        else
            perform log_event( source_cid, source_mid, '1070', '', target_cid, target_mid );
        end if;
    end if;
    
    return result;
    
end;
$$ language plpgsql;


