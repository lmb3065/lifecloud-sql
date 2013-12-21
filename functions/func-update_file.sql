-- ===========================================================================
--  function update_file
-- ---------------------------------------------------------------------------
--  Description goes here.
-- ---------------------------------------------------------------------------
--  2013-12-20 dbrown: created to update description field only
-- ---------------------------------------------------------------------------

create or replace function update_file (

    source_mid     int,
    _file_uid       int,
    _new_desc       text

) returns int as $$

declare

    EVENT_OK_UPDATED_FILE       constant char(4) := '1083';
    EVENT_OK_OWNER_UPDATED_FILE constant char(4) := '1084';
    EVENT_OK_ADMIN_UPDATED_FILE constant char(4) := '1085';
    EVENT_AUTHERR_UPDATING_FILE constant char(4) := '6083';
    EVENT_DEVERR_UPDATING_FILE  constant char(4) := '9083';
    event_out char(4);

    RETVAL_SUCCESS              constant int := 1;
    RETVAL_ERR_FILE_NOTFOUND    constant int := -14;
    RETVAL_ERR_EXCEPTION        constant int := -98;
    result int;

    target_mid int;
    target_cid int;
    source_cid int;
    source_level int;
    source_isadmin int;

begin

    -- Get owner of specified file

    select mid into target_mid from files where uid = _file_uid;
    if (target_mid is null) then
        event_out := EVENT_DEVERR_UPDATING_FILE;
        result    := RETVAL_ERR_FILE_NOTFOUND;
        perform log_event( null, source_mid, event_out, 'File ['||_file_uid||'] does not exist' );
        return result;
    end if;

    -- Ensure user is allower to touch target's stuff

    SELECT allowed, scid, slevel, sisadmin, tcid
        INTO result, source_cid, source_level, source_isadmin, target_cid
        FROM member_can_update_member(source_mid, target_mid);
    if (result < RETVAL_SUCCESS) then
        event_out := EVENT_AUTHERR_UPDATING_FILE;
        perform log_permissions_error( event_out, result, source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;

    declare errno text; errmsg text; errdetail text;
    begin

        update Files set
            x_desc      = fencrypt(_new_desc),
            modified_by = source_mid,
            updated     = now()
        where uid = _file_uid;

    exception when others then

        -- Couldn't update file!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        event_out := EVENT_DEVERR_UPDATING_FILE;
        result    := RETVAL_ERR_EXCEPTION;
        perform log_event(source_cid, source_mid, event_out, '['||errno||'] '||errmsg||' : '||errdetail);
        RETURN result;

    end;

    -- Success
    if (source_mid = target_mid) then event_out := EVENT_OK_UPDATED_FILE;
    elsif (source_isadmin = 1) then   event_out := EVENT_OK_ADMIN_UPDATED_FILE;
    elsif (source_level <= 1) then    event_out := EVENT_OK_OWNER_UPDATED_FILE;
    else event_out := EVENT_OK_UPDATED_FILE;
    end if;

    perform log_event( source_cid, source_mid, event_out, null, target_cid, target_mid );
    return result;

end
$$ language plpgsql;
