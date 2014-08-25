
-- 2014-08-24 dbrown: created
create or replace function get_sms_telcos
(
    _pagesize   int         default null,        
    _page       int         default 0

) returns table (

    telco text,
    suffix text,
    nrows int,
    npages int

) as $$

declare

    _nrows int;
    _npages int;

begin

    -- Perform initial (unpaged) query into a temp table.    
    CREATE TEMPORARY TABLE telcos_out ON COMMIT DROP AS
        select st.telco, st.suffix, 0 as nrows, 0 as npages
        from sms_telcos st;

    -- Calculate pages from the temp table
    select count(*) into _nrows from telcos_out;    
    if (coalesce(_pagesize, 0) = 0) then -- No paging = 1 page
        _pagesize := null;
        _npages   := 1;
    else   -- Calculate actual # of pages
        _npages   := _nrows / _pagesize;
        if (_nrows % _pagesize > 0) then _npages := _npages + 1; end if;
    end if;

    update telcos_out set nrows = _nrows, npages = _npages;

    return query select * from telcos_out
    order by telco asc
    limit _pagesize offset (_page * _pagesize);

end;
$$ language plpgsql;


select * from get_sms_telcos();
