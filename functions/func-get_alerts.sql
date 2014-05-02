-----------------------------------------------------------------------------
-- function get_alerts
-----------------------------------------------------------------------------
-- Gets alerts (reminders) from database
-----------------------------------------------------------------------------
-- 2014-04-12 dbrown: created
-----------------------------------------------------------------------------

create or replace function get_alerts(

    _cid    int default null,
    _mid    int default null
    
) returns table (

    uid int,
    mid int,
    event_name text,
    event_date timestamp,
    advance_days int,
    item_uid int,
    recurrence int,
    sent int
    
) as $$

begin

    if (_cid is null) and (_mid is null) then return; end if;
    
    if (_cid is null) then return query
        
        select r.uid, r.mid, r.event_name, r.event_date, r.advance_days,
            r.item_uid, r.recurrence, r.sent
        from reminders r
        where _mid = r.mid;
        
    else return query

        select r.uid, r.mid, r.event_name, r.event_date, r.advance_days,
            r.item_uid, r.recurrence, r.sent
        from reminders r
        where r.mid in ( select m.mid from members m where m.cid = _cid );

    end if;
    
    return;

end; $$ language plpgsql;

