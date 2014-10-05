-- ===========================================================================
--  function update_item
-- ---------------------------------------------------------------------------
--  Description goes here.
-- ---------------------------------------------------------------------------
--  2013-12-20 dbrown: created to update description field only
--  2014-10-02 dbrown: added itemType argument
-- ---------------------------------------------------------------------------

create or replace function update_item (

    source_mid     int,
    _item_uid       int,
    _new_desc       text,
    _new_itemtype   int

) returns int as $$

declare

    EVENT_OK_UPDATED_ITEM       constant char(4) := '1103';
    EVENT_OK_OWNER_UPDATED_ITEM constant char(4) := '1104';
    EVENT_OK_ADMIN_UPDATED_ITEM constant char(4) := '1105';
    EVENT_AUTHERR_UPDATING_ITEM constant char(4) := '6103';
    EVENT_DEVERR_UPDATING_ITEM  constant char(4) := '9103';
    event_out char(4);

    RETVAL_SUCCESS              constant int := 1;
    RETVAL_ERR_ITEM_NOTFOUND    constant int := -15;
    RETVAL_ERR_EXCEPTION        constant int := -98;
    result int;

    target_mid int;
    target_cid int;
    source_cid int;
    source_level int;
    source_isadmin int;

begin

    -- Get owner of specified item

    select mid into target_mid from items where uid = _item_uid;
    if (target_mid is null) then
        event_out := EVENT_DEVERR_UPDATING_ITEM;
        result    := RETVAL_ERR_ITEM_NOTFOUND;
        perform log_event( null, source_mid, event_out, 'Item ['||_item_uid'] does not exist' );
        return result;
    end if;

    -- Ensure caller is allowed to touch item owner's stuff

    SELECT allowed, scid, slevel, sisadmin, tcid
        INTO result, source_cid, source_level, source_isadmin, target_cid
        FROM member_can_update_member(source_mid, target_mid);
    if (result < RETVAL_SUCCESS) then
        event_out := EVENT_AUTHERR_UPDATING_ITEM;
        perform log_permissions_error( event_out, result, source_cid, source_mid, target_cid, target_mid );
        return result;
    end if;

    -- --Update Database------------------------------------------------------

    declare errno text; errmsg text; errdetail text;
    begin

        update Items set
            x_desc      = fencrypt(_new_desc),
            ItemType    = _new_itemtype,
            modified_by = source_mid,
            updated     = now()
        where uid = _item_uid;

    exception when others then

        -- Couldn't update item!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        event_out := EVENT_DEVERR_UPDATING_ITEM;
        perform log_event(source_cid, source_mid, event_out, '['||errno||'] '||errmsg||' : '||errdetail);
        RETURN RETVAL_ERR_EXCEPTION;

    end;

    -- Success

    if (source_mid = target_mid) then event_out := EVENT_OK_UPDATED_ITEM;
    elsif (source_isadmin = 1) then   event_out := EVENT_OK_ADMIN_UPDATED_ITEM;
    elsif (source_level <= 1) then    event_out := EVENT_OK_OWNER_UPDATED_ITEM;
    else event_out := EVENT_OK_UPDATED_ITEM;
    end if;

    perform log_event( source_cid, source_mid, event_out, null, target_cid, target_mid );
    return result;

end
$$ language plpgsql;
