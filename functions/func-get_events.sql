
-- =====================================================================
-- function get_events
--     _from timestamp : date of oldest event to include
--     _to   timestamp : date of most recent event to include
--     _pagesize int   : [optional] # of rows that define a "page"
--     _page int = 0   : [optional] which "page" to return (0 is first)
-- ----------------------------------------------------------------------
-- Returns a table of all events befween _from and _to
--   sorted by date descending
--   optionally divide into _pagesize-row pages and return page _page
-- ----------------------------------------------------------------------
-- 2013-09-25 dbrown : Accounts/Members refactor; added MID
-- 2013-10-10 dbrown : Added _nrows, _npages
-- 2013-10-11 dbrown : New pagination technique using temporary table
-- 2013-10-12 dbrown : Can now be called with no arguments at all
-- 2013-10-30 dbrown : Integrated event_t into the function definition
-- 2013-11-10 dbrown : ref_EventCodes is now a Left Outer Join in case we
--                have typoed eventCodes or missing entries 
-----------------------------------------------------------------------------

create or replace function get_events(

    _from       timestamp   default date_trunc('day',now()),
    _to         timestamp   default now(),
    _pagesize   int         default null,        
    _page       int         default 0

) returns table ( 

    eid int, 
    dt timestamp,
    code char(4),
    cid int,
    mid int,
    tcid int,
    tmid int,
    descrip varchar,
    event varchar,
    nrows int,
    npages int

) as $$  

declare

    _nrows int;
    _npages int;

begin

    if (_from is null) then _from := date_trunc('day',now()); end if;
    if (_to   is null) then _to   := now();                   end if;

    -- Perform initial (unpaged) query into a temp table.    
    create temporary table events_out on commit drop as
        select e.eid, e.dt, e.code, e.cid, e.mid, e.target_cid, e.target_mid,
            cast(fdecrypt(e.x_data) as varchar) as event,
            re.description, 0 as nrows, 0 as npages
        from Events e left outer join ref_EventCodes re on (e.code = re.code) 
        where e.dt between _from and _to;
        
    -- Calculate pages from the temp table
    select count(*) into _nrows from events_out;    
    if (coalesce(_pagesize, 0) = 0) then -- No paging = 1 page
        _pagesize := null;
        _npages   := 1;
    else   -- Calculate actual # of pages
        _npages   := _nrows / _pagesize;
        if (_nrows % _pagesize > 0) then _npages := _npages + 1; end if;
    end if;

    update events_out set nrows = _nrows, npages = _npages;

    -- Output final results
    return query select * from events_out
        order by dt desc
        limit _pagesize offset (_page * _pagesize);
    
end;
$$ language plpgsql;


