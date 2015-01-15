
-- Get ALL registration codes, with paging -- if MID is an Admin.
-- 2015-01-15 dbrown : Create

create or replace function get_regcodes
(
    _mid        int,
    _pagesize   int         default null,        
    _page       int         default 0
)
returns table 
(
    code            text,
    maximum_uses    int,
    code_uses       int,
    description     text,
    code_effective  timestamp,
    code_expires    timestamp,
    account_expires timestamp,
    account_life    int,
    discount        int,   
    nrows           int,
    npages          int
) as $$

declare

    EVENT_AUTHERR_GETTING_REGCODES constant varchar = '6126';
    _mid_is_admin int;
    _nrows int;
    _npages int;

begin

    -- Check that MID is an admin

    select isadmin into _mid_is_admin
        from members where mid = _mid;

    if (coalesce(_mid_is_admin, 0) = 0) then
        -- Security fail
        perform log_event(null, _mid, EVENT_AUTHERR_GETTING_REGCODES, null);
        return;
    end if;


    -- Perform query

    select count(*) into _nrows from reg_codes;
    if (coalesce(_pagesize, 0) = 0) then -- No paging == 1 page
        _pagesize := null;
        _npages   := 1;
    else -- Calculate actual number of pages
        _npages   := _nrows / _pagesize;
        if (_nrows % _pagesize > 0) then _npages := _npages + 1; end if;
    end if;

    return query
        select rc.code, rc.maximum_uses, rc.code_uses, rc.description,
            rc.code_effective, rc.code_expires, rc.account_expires, 
            rc.account_life, rc.discount, _nrows, _npages
        from reg_codes rc;

end;

$$ language plpgsql;
