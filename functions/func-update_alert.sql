-----------------------------------------------------------------------------
-- update_alert
-----------------------------------------------------------------------------
-- updates an existing reminder with the new data provided.  it may be the
-- same as the old data.  source_mid will need to be validated to determine
-- if they are allowed to edit (account owner, proxy, or creator).
--
-- We assume that the caller is passing us a *complete* alert structure;
-- any existing data is simply overwritten.
--
-- Returns integer from ref_retvals
-----------------------------------------------------------------------------
-- 2014-04-13 dbrown: created
-- 2014-04-15 dbrown: exception now logs target mid/cid
-- 2014-05-23 dbrown: fixed some incomplete sections
-- 2014-05-23 dbrown: changed behavior to expect complete structure
-----------------------------------------------------------------------------

create or replace function update_alert(

    _source_mid     int,   -- Which member is updating the alert
    _alert_uid      int,   -- Which alert is being updated
    _event_name     text,  -- Data fields ....
    _event_date     timestamp,
    _advance_days   int,
    _item_uid       int,
    _recurrence     int,
    _sent           int

) returns integer as $$

declare

    EVENT_OK_UPDATED_ALERT       constant varchar := '1113';
    EVENT_OK_OWNER_UPDATED_ALERT constant varchar := '1114';
    EVENT_OK_ADMIN_UPDATED_ALERT constant varchar := '1115';
    EVENT_AUTHERR_UPDATING_ALERT constant varchar := '6113';
    EVENT_DEVERR_UPDATING_ALERT  constant varchar := '9113';
    event_out varchar;
    
    RETVAL_SUCCESS               constant int :=   1;
    RETVAL_ERR_ARGUMENTS         constant int :=   0;
    RETVAL_ERR_ALERT_NOTFOUND    constant int := -14;
    RETVAL_ERR_EXCEPTION         constant int := -98;
    result int;
    
    _target_mid int;
    _target_cid int;
    _source_cid int;
    _source_level int;
    _source_isamin int;
    
begin

    -- Make sure specified alert exists (and get its owner)
    
    select mid into _target_mid from reminders where uid = _alert_uid;
    
    if (_target_mid is null) then
        event_out := EVENT_DEVERR_UPDATING_ALERT;
        result    := RETVAL_ERR_ALERT_NOTFOUND;
        perform log_event( null, _source_mid, event_out, 'reminder ['||_alert_uid||'] does not exist' );
        return result;
    end if;
    

    -- Ensure caller is allowed to touch target's stuff
    
    select allowed, scid, slevel, sisadmin, tcid
        into result, _source_cid, _source_level, _source_isamin, _target_cid
        from member_can_update_member( _source_mid, _target_mid );
        
    if (result < RETVAL_SUCCESS) then
        event_out := EVENT_AUTHERR_UPDATING_ALERT;
        perform log_permissions_error( event_out, result, _source_cid, _source_mid, _target_cid, _target_mid );
        return result;
    end if;

    
    -- Update database record

    declare errno text; errmsg text; errdetail text;
    begin

        update reminders set
            event_name   = _event_name,
            event_date   = _event_date,
            advance_days = _advance_days,
            item_uid     = _item_uid,
            recurrence   = _recurrence,
            sent         = _sent
        where uid = _alert_uid;

    exception when others then

        -- Couldn't update reminder: Bail out!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        event_out := EVENT_DEVERR_UPDATING_ALERT;
        result    := RETVAL_ERR_EXCEPTION;
        perform log_event( _source_cid, _source_mid, event_out,
                    '['||errno||'] '||errmsg||' : '||errdetail, _target_cid, _target_mid );
        return result;

    end;
    

    -- Success

    if (_source_mid = _target_mid) then event_out := EVENT_OK_UPDATED_ALERT;
    elsif (_source_isamin = 1) then     event_out := EVENT_OK_ADMIN_UPDATED_ALERT;
    elsif (_source_level <= 1) then     event_out := EVENT_OK_OWNER_UPDATED_ALERT;
    else event_out := EVENT_OK_UPDATED_ALERT;
    end if;
    
    perform log_event( _source_cid, _source_mid, event_out, null, _target_cid, _target_mid );
    return result;
    
end;
$$ language plpgsql;
        