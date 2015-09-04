
create or replace function get_login_history(

    _my_mid         int,
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

    RETVAL_SUCCESS              constant int := 1;
    EVENT_AUTHERR_GETTING_EVENT constant varchar := '6096';
    _nrows int;
    _npages int;
    _result int;
    _sisadmin int;

begin

    if (_from is null) then _from := now() - interval '7 days'; end if;
    if (_to   is null) then _to   := now();                     end if;

    if (_target_mid = 0) then
        select isadmin into _sisadmin from members m where m.mid = _my_mid;
        if (_sisadmin <> 1) then
            perform log_permissions_error( EVENT_AUTHERR_GETTING_EVENT, _result, 
                null, _my_mid, null, _target_mid );
            return;
        end if;

        create temporary table events_out on commit drop as
            select e.eid, e.dt, e.code, re.description,
                cast(fdecrypt(e.x_data) as varchar) as event,
                e.cid, e.mid, 0 as nrows, 0 as npages
            from events e left outer join ref_eventcodes re on (e.code = re.code)
            where (e.dt between _from and _to)
              and (e.code in ('1000','1001'));

    else

        select allowed, sisadmin into _result, _sisadmin
            from member_can_view_member(_my_mid, _target_mid);
        if (result < 1) then
            perform log_permissions_error( EVENT_AUTHERR_GETTING_EVENT, _result, 
                null, _my_mid, null, _target_mid );
            return;
        end if;

        create temporary table events_out on commit drop as
            select e.eid, e.dt, e.code, re.description,
                cast(fdecrypt(e.x_data) as varchar) as event,
                e.cid, e.mid, 0 as nrows, 0 as npages
            from events e left outer join ref_eventcodes re on (e.code = re.code)
            where (e.dt between _from and _to)
              and (e.mid = _target_mid)
              and (e.code in ('1000','1001'));

    end if;

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

