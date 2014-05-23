-----------------------------------------------------------------------------
-- function get_alerts
-----------------------------------------------------------------------------
-- Gets alerts (reminders) from database
-----------------------------------------------------------------------------
-- 2014-04-12 dbrown: created
-- 2014-05-22 dbrown: added paging functions
-----------------------------------------------------------------------------

create or replace function get_alerts(

    _cid        int default null,
    _mid        int default null,
    _pagesize   int default 0,
    _page       int default 0
    
) returns table (

    uid int,
    mid int,
    event_name text,
    event_date timestamp,
    advance_days int,
    item_uid int,
    recurrence int,
    sent int,
    nrows int,
    npages int
    
) as $$

declare
    _nrows int;
    _npages int;

begin

    if (_cid is null) and (_mid is null) then return; end if;
    

    -- Perform unpaged query into a temporary table

    if (_cid is null) then

        create temporary table alerts_out on commit drop as
        select r.uid, r.mid, r.event_name, r.event_date, r.advance_days,
            r.item_uid, r.recurrence, r.sent
        from reminders r
        where _mid = r.mid;
        
    else

        create temporary table alerts_out on commit drop as
        select r.uid, r.mid, r.event_name, r.event_date, r.advance_days,
            r.item_uid, r.recurrence, r.sent
        from reminders r
        where r.mid in ( select m.mid from members m where m.cid = _cid );

    end if;
    
    -- Calculate paging values and add them to the temp table

    select count(*) into _nrows from alerts_out;
    if _nrows = 0 then return; end if; -- Bail out now if no results

    if (coalesce(_pagesize, 0) > 0) then
        _npages := _nrows / _pagesize;
        if (_nrows % _pagesize > 0) then _npages := _npages + 1; end if;
    else -- No paging, everything goes on 1 page
        _pagesize := null;
        _npages := 1;
    end if;
    update alerts_out set nrows = _nrows, npages = _npages;

    -- Output final results --

    return query 
        select * from alerts_out
        order by event_date desc
        limit _pagesize offset (_page * _pagesize);

end; $$ language plpgsql;

