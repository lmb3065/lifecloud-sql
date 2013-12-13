-- ===========================================================================
--  function delete_item
-- ---------------------------------------------------------------------------
--  2013-12-12 dbrown: created
-- ---------------------------------------------------------------------------

create or replace function delete_item(

    source_mid  int,
    item_uid    int

) returns int as $$

declare
    EVENT_OK_DELETED_ITEM       constant varchar := '1107';
    EVENT_OK_OWNER_DELETED_ITEM constant varchar := '1108';
    EVENT_OK_ADMIN_DELETED_ITEM constant varchar := '1109';
    EVENT_AUTHERR_DELETING_ITEM constant varchar := '6107';
    EVENT_DEVERR_DELETING_ITEM  constant varchar := '9107';
    eventcode_out varchar;

    RETVAL_SUCCESS              constant int :=   1;
    RETVAL_ERR_ITEM_NOTFOUND    constant int := -15;
    RETVAL_ERR_EXCEPTION        constant int := -98;
    result int;

    source_cid      int;
    source_ulevel   int;
    source_isadmin  int;
    target_mid      int;
    target_cid      int;

begin

    -- Ensure target-item exists (and get its owner)
    select mid into target_mid from items where uid = item_uid;

    if (target_mid is null) then
        perform log_event( null, source_mid, EVENT_DEVERR_DELETING_ITEM,
                    'Item.UID ['||item_uid'] does not exist' );
        return RETVAL_ERR_ITEM_NOTFOUND;
    end if;

    -- Check that source user is allowed to touch item-owner's stuff
    SELECT allowed, scid, slevel, sisadmin, tcid
        INTO result, source_cid, source_ulevel, source_isadmin, target_cid
        FROM member_can_update_member(source_mid, target_mid);
    if (result < RETVAL_SUCCESS) then
        perform log_permissions_error( EVENT_AUTHERR_DELETING_ITEM, result,
                    source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;

    -- Delete the file -------------------------------------------------------

    declare
        errno text;
        errmsg text;
        errdetail text;

    begin
        delete from Items where uid = item_uid;

    exception when others then
        -- Couldn't delete Item!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        perform log_event( source_cid, source_mid, EVENT_DEVERR_DELETING_ITEM, '['||errno||'] '||errmsg||' : '||errdetail);
        return RETVAL_ERR_EXCEPTION;
    end;

    -- Success

    if (source_mid = target_mid)    then eventcode_out := EVENT_OK_DELETED_ITEM;
    elsif (source_isadmin = 1)      then eventcode_out := EVENT_OK_ADMIN_DELETED_ITEM;
    elsif (source_ulevel <= 1)      then eventcode_out := EVENT_OK_OWNER_DELETED_ITEM;
    else eventcode_out := EVENT_OK_DELETED_ITEM;
    end if;

    perform log_event( source_cid, source_mid, eventcode_out, null, target_cid, target_mid );
    return RETVAL_SUCCESS;

end
$$ language plpgsql;
