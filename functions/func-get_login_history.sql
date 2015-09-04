
create or replace function get_login_history(

    _target_mid     int,
    _from           timestamp   default now() - interval '7 days',
    _to             timestamp   default now(),
    _pagesize       int         default null,
    _page           int         default 0

) returns table (

    eid int, 
    dt timestamp,
    code char(4),
    descrip varchar,
    event varchar,
    cid int,
    mid int,
    nrows int,
    npages int

) as $$

declare

    _nrows int;
    _npages int;

begin

    if (_from is null) then _from := now() - interval '7 days'; end if;
    if (_to   is null) then _to   := now();                     end if;

    create temporary table events_out on commit drop as
        select e.eid, e.dt, e.code, re.description,
            cast(fdecrypt(e.x_data) as varchar) as event,
            e.cid, e.mid, 0 as nrows, 0 as npages
        from events e left outer join ref_eventcodes re on (e.code = re.code)
        where (e.dt between _from and _to)
          and (e.mid = _target_mid)
          and (e.code in ('1000','1001'));

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

