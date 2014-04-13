
-- -----------------------------------------------------------------------------
--  delete_file
-- -----------------------------------------------------------------------------
--  returns:
--      1  : Success
--    -14  : File not found
-- -----------------------------------------------------------------------------
-- 2013-11-01 dbrown: update event codes, changed all "item" to "file"
-- 2013-11-10 dbrown: update retvals, replace magic with constants,
--               removed unnecessary sanity check, source-level eventcodes
-- 2013-11-11 dbrown: logs filename (or uid on error)
-- 2013-11-14 dbrown: Organization, Exception handling, More info in eventcodes
-- 2013-11-24 dbrown: Removed eventlog noise
-- 2013-12-12 dbrown: Fixed some bugs
-- 2014-04-12 dbrown: Fixed another bug
-- -----------------------------------------------------------------------------

create or replace function delete_file(

    source_mid int, -- Member making the change
    file_uid   int  -- UID of the file to be deleted

) returns int as $$

declare
    EVENT_OK_DELETED_FILE       constant char(4) := '1087';
    EVENT_OK_OWNER_DELETED_FILE constant char(4) := '1088';
    EVENT_OK_ADMIN_DELETED_FILE constant char(4) := '1089';
    EVENT_AUTHERR_DELETING_FILE constant char(4) := '6087';
    EVENT_DEVERR_DELETING_FILE  constant char(4) := '9087';
    eventcode_out varchar;

    RETVAL_SUCCESS              constant int :=   1;
    RETVAL_ERR_FILE_NOTFOUND    constant int := -14;
    RETVAL_ERR_EXCEPTION        constant int := -98;
    result int;

    source_cid      int;
    source_ulevel   int;
    source_isadmin  int;
    target_mid      int;
    target_cid      int;
    file_name       text;

begin

    -- Ensure target-file exists (and get its owner)
    SELECT mid INTO target_mid FROM files WHERE uid = file_uid;
    if (target_mid is null) then
        perform log_event( null, source_mid, EVENT_DEVERR_DELETING_FILE,
                    'File ['||file_uid||'] does not exist' );
        return RETVAL_ERR_FILE_NOTFOUND;
    end if;

    -- Check that user is allowed to touch file-owner's stuff
    SELECT allowed, scid, slevel, sisadmin, tcid
        INTO result, source_cid, source_ulevel, source_isadmin, target_cid
        FROM member_can_update_member(source_mid, target_mid);
    if (result < RETVAL_SUCCESS) then
        perform log_permissions_error( EVENT_AUTHERR_DELETING_FILE, result,
                    source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;


    -- Delete the file -------------------------------------------------------------

    declare
        errno text;
        errmsg text;
        errdetail text;
    begin
        delete from Files where uid = file_uid;

    exception when others then
        -- Couldn't delete File!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        perform log_event( source_cid, source_mid, EVENT_DEVERR_DELETING_FILE, '['||errno||'] '||errmsg||' : '||errdetail);
        RETURN RETVAL_ERR_EXCEPTION;
    end;


    -- Success ---------------------------------------------------------------------

    if (source_mid = target_mid) then eventcode_out := EVENT_OK_DELETED_FILE;
    elsif (source_isadmin = 1)   then eventcode_out := EVENT_OK_ADMIN_DELETED_FILE;
    elsif (source_ulevel <= 1)   then eventcode_out := EVENT_OK_OWNER_DELETED_FILE;
    else                              eventcode_out := EVENT_OK_DELETED_FILE;
    end if;

    perform log_event( source_cid, source_mid, eventcode_out, null, target_cid, target_mid);
    return RETVAL_SUCCESS;

end;
$$ language plpgsql;


