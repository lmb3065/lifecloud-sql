-----------------------------------------------------------------------------
-- function add_alert
-----------------------------------------------------------------------------
-- Inserts a new reminder (aka alert) into the Reminders table
--  Returns the UID of the newly created reminder, OR a negative errorcode
-----------------------------------------------------------------------------
-- 2014-04-12 dbrown : created
-- 2014-04-12 dbrown : provided defaults for some arguments
-- 2014-10-17 dbrown : If a similar alert exists, return it instead
-----------------------------------------------------------------------------

create or replace function add_alert(

    _mid             int,
    _event_name      text,
    _event_date      timestamp,
    _advance_days    int        default 0,
    _item_uid        int        default null,
    _recurrence      int        default 0,
    _sent            int        default 0
    
) returns int as $$

declare

    newuid int;
    existing_uid int;
    
    EVENT_OK_ADDED_ALERT        constant varchar := '1110';
    EVENT_DEVERR_ADDING_ALERT   constant varchar := '9110';

    RETVAL_SUCCESS              constant int :=  1;
    RETVAL_ERR_ARG_INVALID      constant int :=  0;
    RETVAL_ERR_EXCEPTION        constant int := -98;

begin

    -- Ensure a NAME was supplied
    if (length(_event_name) = 0) then
        return RETVAL_ERR_ARG_INVALID;
    end if;
    
    -- Validate item_uid if supplied
    if (_item_uid is not null)
    and _item_uid not in (select uid from items) then
        perform log_event( null, _mid, EVENT_DEVERR_ADDING_ALERT, 
            'item_uid '|| _item_uid ||' does not exist' );
        return RETVAL_ERR_ARG_INVALID;
    end if;
    
    -- Check for an existing reminder that looks like this one.
    -- If we find one, return its UID instead

    SELECT r.uid into existing_uid FROM Reminders r
    WHERE r.mid = _mid
      and r.event_name = _event_name
      and r.event_date = _event_date
      and r.advance_days = _advance_days
      and r.recurrence = _recurrence;
    if existing_uid > 0 then
        return existing_uid;
    end if;

    -- ADD REMINDER TO DATABASE
    
    declare errno text; errmsg text; errdetail text;
    begin
    
        INSERT INTO Reminders (mid, event_name, event_date, advance_days, item_uid, recurrence, sent)
        VALUES (_mid, _event_name, _event_date, _advance_days, _item_uid, _recurrence, _sent);
        select lastval() into newuid;
        
    exception when others then
    
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        perform log_event(null, _mid, EVENT_DEVERR_ADDING_ALERT, '['||errno||'] '||errmsg||' : '||errdetail);
        RETURN RETVAL_ERR_EXCEPTION;

    end;
    
    perform log_event( null, _mid, EVENT_OK_ADDED_ALERT, null, null, null );
    return newuid;
    
end;
$$ language plpgsql;

