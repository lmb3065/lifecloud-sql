
-- Get ALL registration codes, with paging -- if MID is an Admin.
-- 2015-01-15 dbrown : Create
-- 2015-01-17 dbrown : Order output by code
-- 2015-01-17 dbrown : Fix paging
-- 2015-03-23 dbrown : Add column 'paypal_button_id'
-- 2015-06-27 dbrown : Add paypal columns periodN/amountN
--  drop function get_regcodes(int, int, int);

create or replace function get_regcodes
(
    _mid        int,
    _pagesize   int         default null,        
    _page       int         default 0
)
returns table 
(
    code             text,
    maximum_uses     int,
    code_uses        int,
    description      text,
    code_effective   timestamp,
    code_expires     timestamp,
    account_expires  timestamp,
    account_life     int,
    discount         int,
    paypal_button_id varchar(16),
    period1           char(1),
    period2           char(1),
    period3           char(1),
    amount1           varchar(10),
    amount2           varchar(10),
    amount3           varchar(10),
    nrows            int,
    npages           int
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
            rc.account_life, rc.discount, rc.paypal_button_id, 
            rc.period1, rc.period2, rc.period3,
            rc.amount1, rc.amount2, rc.amount3,
            _nrows, _npages
        from reg_codes rc
        order by rc.code asc
        offset (_page * _pagesize) limit _pagesize;

end;

$$ language plpgsql;
