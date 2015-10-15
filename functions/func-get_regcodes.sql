
-- Get ALL registration codes, with paging -- if MID is an Admin.
-- 2015-01-15 dbrown : Create
-- 2015-01-17 dbrown : Order output by code
-- 2015-01-17 dbrown : Fix paging
-- 2015-03-23 dbrown : Add column 'paypal_button_id'
-- 2015-06-27 dbrown : Add paypal columns periodN/amountN
-- 2015-10-15 dbrown : Add 2nd paypal button columns

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
    paypal_button_id_1  varchar(16),
    period1_1           varchar(4),
    period2_1           varchar(4),
    period3_1           varchar(4),
    amount1_1           varchar(10),
    amount2_1           varchar(10),
    amount3_1           varchar(10),
    paypal_button_id_2  varchar(16),
    period1_2           varchar(4),
    period2_2           varchar(4),
    period3_2           varchar(4),
    amount1_2           varchar(10),
    amount2_2           varchar(10),
    amount3_2           varchar(10),
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
            rc.account_life, rc.discount, 
            rc.paypal_button_id_1, 
            rc.period1_1, rc.period2_1, rc.period3_1,
            rc.amount1_1, rc.amount2_1, rc.amount3_1,
            rc.paypal_button_id_2, 
            rc.period1_2, rc.period2_2, rc.period3_2,
            rc.amount1_2, rc.amount2_2, rc.amount3_2,
            _nrows, _npages
        from reg_codes rc
        order by rc.code asc
        offset (_page * _pagesize) limit _pagesize;

end;

$$ language plpgsql;
