-- -----------------------------------------------------------------------------
--  function set_alert_types()
-- -----------------------------------------------------------------------------
-- Updates the Alert-related fields for the specific member.
-- -----------------------------------------------------------------------------
-- 2014-04-15 dbrown: created
-- -----------------------------------------------------------------------------

create or replace function set_alert_types(

    _source_mid     int,
    _target_mid     int,
    _newalerttype   int  default null,
    _newalertphone  text default null,
    _newalertemail  text default null

) returns int as $$

declare    
    EVENT_OK_UPDATED_MEMBER         constant varchar := '1033';
    EVENT_OK_OWNER_UPDATED_MEMBER   constant varchar := '1034';
    EVENT_OK_ADMIN_UPDATED_MEMBER   constant varchar := '1035';
    EVENT_AUTHERR_UPDATING_MEMBER   constant varchar := '4033';
    EVENT_DEVERR_UPDATING_MEMBER    constant varchar := '9033';
    _event_out char(4);
   
    RETVAL_SUCCESS                  constant int     :=      1;
    RETVAL_ERR_ARGUMENTS            constant int     :=      0;
    RETVAL_ERR_EXCEPTION            constant int     :=    -98;
    _result int;

    _target_cid int;
    _source_cid int;
    _source_level int;
    _source_isadmin int;
    
    
begin
   
    -- Check arguments
    
    if (_newalerttype  is null) and (_newalertphone is null) and (_newalertemail is null) then
        return RETVAL_ERR_ARGUMENTS;
    end if;

    -- ensure Caller is allowed to touch Target's stuff

    select allowed, scid, slevel, sisadmin, tcid
        into _result, _source_cid, _source_level, _source_isadmin, _target_cid
        from member_can_update_member( _source_mid, _target_mid );
        
    if (_result < RETVAL_SUCCESS) then
        _event_out = EVENT_AUTHERR_UPDATING_MEMBER;
        perform log_permissions_error( _event_out, _result, _source_cid,
                _target_cid, _target_mid );
        return _result;
    end if;
    
    
    -- Update database record

    declare errno text; errmsg text; errdetail text;
    begin

        update members set
            alerttype    = coalesce(_newalerttype,  members.alerttype),
            x_alertphone = coalesce(fencrypt(_newalertphone), members.x_alertphone),
            x_alertemail = coalesce(fencrypt(_newalertemail), members.x_alertemail)
        where mid = _target_mid;
            
    exception when others then
    
        -- Couldn't update member!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        _event_out := EVENT_DEVERR_UPDATING_MEMBER;
        _result    := RETVAL_ERR_EXCEPTION;
        perform log_event( _source_cid, _source_mid, _event_out, 
                    'set_alert_types(): ['||errno||'] '||errmsg||' : '||errdetail, _target_cid, _target_mid );
        return _result;   
  
    end;
    
    -- Success
    
    if (_source_mid = _target_mid) then _event_out := EVENT_OK_UPDATED_MEMBER;
    elsif (_source_isadmin = 1) then    _event_out := EVENT_OK_ADMIN_UPDATED_MEMBER;
    elsif (_source_level <= 1) then     _event_out := EVENT_OK_OWNER_UPDATED_MEMBER;
    else _event_out := EVENT_OK_UPDATED_MEMBER;
    end if;
    
    perform log_event( _source_cid, _source_mid, _event_out, 'set_alert_types()', _target_cid, _target_mid );
    return _result;
    
end;
$$ language plpgsql;

