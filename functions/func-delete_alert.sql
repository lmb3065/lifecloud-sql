-----------------------------------------------------------------------------
-- function delete_alert (source_mid, event_uid)
-----------------------------------------------------------------------------
-- deletes an existing reminder from the Reminders table.  source_mid will
-- have to be validated to determine if they are allowed to do this.
-- the account owner, proxy, or original mid-creator are the only users 
-- authorized to delete a reminder.
-----------------------------------------------------------------------------
-- 2014-04-12 dbrown: created
-----------------------------------------------------------------------------

create or replace function delete_alert(

    _source_mid int,
    _alert_uid  int
    
) returns int as $$

declare

    EVENT_OK_DELETED_ALERT       constant varchar := '1117';
    EVENT_OK_OWNER_DELETED_ALERT constant varchar := '1118';
    EVENT_OK_ADMIN_DELETED_ALERT constant varchar := '1119';
    EVENT_AUTHERR_DELETING_ALERT constant varchar := '6117';
    EVENT_DEVERR_DELETING_ALERT  constant varchar := '9117';
    eventcode_out varchar;
    
    RETVAL_SUCCESS               constant int :=   1;
    RETVAL_ERR_ALERT_NOTFOUND    constant int := -16;
    RETVAL_ERR_EXCEPTION         constant int := -98;
    result int;
    
    source_cid      int;
    source_ulevel   int;
    source_isadmin  int;
    target_mid      int;
    target_cid      int;
    
begin

    -- Ensure target alert exists (and get its owner)
    select mid into target_mid from reminders where uid = _alert_uid;
    if (target_mid is null) then
        perform log_event( null, _source_mid, EVENT_DEVERR_DELETING_ALERT,
            'Reminder ['||_alert_uid||'] does not exist' );
        return RETVAL_ERR_ALERT_NOTFOUND;
    end if;
    
    -- Check that user is allowed to touch target-alert-owner's stuff
    select allowed, scid, slevel, sisadmin, tcid
        into result, source_cid, source_ulevel, source_isadmin, target_cid
        from member_can_update_member(_source_mid, target_mid);
    
    if (result < RETVAL_SUCCESS) then
        perform log_permissions_error( EVENT_AUTHERR_DELETING_ALERT, result,
                source_cid, _source_mid, target_cid, target_mid );
        return result;
    end if;
    
    
    -- DELETE THE ALERT
    
    declare errno text; errmsg text; errdetail text;
    begin
        delete from reminders where uid = _alert_uid;
        
    exception when others then
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        perform log_event( source_cid, source_mid, EVENT_DEVERR_DELETING_ALERT, '['||errno||'] '||errmsg||' : '||errdetail);
        return RETVAL_ERR_EXCEPTION;
    end;

    -- Success
    
    if (_source_mid = target_mid) then eventcode_out := EVENT_OK_DELETED_ALERT;
    elsif (source_isadmin = 1)   then eventcode_out := EVENT_OK_ADMIN_DELETED_ALERT;
    elsif (source_ulevel <= 1)   then eventcode_out := EVENT_OK_OWNER_DELETED_ALERT;
    else                              eventcode_out := EVENT_OK_DELETED_ALERT;
    end if;
    
    perform log_event( source_cid, _source_mid, eventcode_out, null, target_cid, target_mid);
    return RETVAL_SUCCESS;

end;
$$ language plpgsql;

