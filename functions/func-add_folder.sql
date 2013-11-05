
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
    target_cid int;

begin

    -- Check permissions

    select allowed, scid, tcid into result, source_cid, target_cid
        from member_can_update_member(source_mid, target_mid);
    
    if result < 1 then -- 9020 = Error inserting folder
        perform log_permissions_error( '9020', result, source_cid, source_mid, target_cid, target_mid );
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
        perform log_event( source_cid, source_mid, '9020', 'INSERT INTO Folders failed!', target_cid, target_mid );
        return -10;
    end if;

    
    -- Success
    
    if (_logging > 0) then
        perform log_event( source_cid, source_mid, '0020', '', target_cid, target_mid );
    end if;
    
    return result;
    
end;
$$ language plpgsql;


