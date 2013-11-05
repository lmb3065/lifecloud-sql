
-- ==============================================================================
-- get_accounts()
-- ------------------------------------------------------------------------------
-- for administrator use only!  returns data on the specified accounts.
-- 'filter' is a string to find, 'filtertype' indicates where to look for it:
--      'e'=e-mail 'f'=firstname 'l'=lastname
-- if no filter is supplied, returns ALL THE ACCOUNTS
-- ------------------------------------------------------------------------------
-- 2013-10-11 dbrown : returns paging stats (nrows, npages); new query structure
-- 2013-10-11 dbrown : fixed case-sensitive ordering
-- 2013-10-16 dbrown : added column member_count
---------------------------------------------------------------------------------

create or replace function get_accounts(

    _filter   varchar(32) default '',
    _pagesize int         default 0,
    _page     int         default 0,
    _filtertype char      default ''

) returns table(account account_ext_t) as $$

declare
    _nrows int;
    _npages int;
    _lower_filter     text = lower(_filter);
    _lower_filtertype text = lower(_filtertype);
    
begin

    -- Do our main unpaged query into a temporary table

    create temporary table accounts_out on commit drop as
    select a.cid,
        a.status                as account_status,
        a.quota                 as account_quota,
        a.referrer              as account_referrer,
        a.created               as account_created,
        a.updated               as account_updated,
        a.expires               as account_expires,
        -1                      as member_count,
        m.mid                   as owner_mid, 
        fdecrypt(x_userid)      as userid, 
        fdecrypt(x_email)       as email, 
        fdecrypt(x_fname)       as fname,
        fdecrypt(x_mi)          as mi,
        fdecrypt(x_lname)       as lname,
        fdecrypt(x_address1)    as address1,
        fdecrypt(x_address2)    as address2,
        fdecrypt(x_city)        as city, 
        fdecrypt(x_state)       as state,
        fdecrypt(x_postalcode)  as postalcode,
        fdecrypt(x_country)     as country,
        fdecrypt(x_phone)       as phone,
        m.status                as owner_mstatus,
        m.pwstatus              as owner_pwstatus,
        m.userlevel             as owner_userlevel,
        m.tooltips              as owner_tooltips,
        m.isadmin               as owner_isadmin,
        m.logincount            as owner_logincount,
        m.created               as owner_created,
        m.updated               as owner_updated,
        0                       as nrows,
        0                       as npages
    from Accounts a join Members m on (a.owner_mid = m.mid)
    
    -- Apply filters
    where ((_lower_filtertype = 'e')  and  (lower(fdecrypt(x_email)) like _lower_filter || '%'))
       or ((_lower_filtertype = 'f')  and  (lower(fdecrypt(x_fname)) like _lower_filter || '%'))
       or ((_lower_filtertype = 'l')  and  (lower(fdecrypt(x_lname)) like _lower_filter || '%'))
    
       or (coalesce(length(_filter)    , 0) = 0)  -- No filter? Return all
       or (coalesce(length(_filtertype), 0) = 0); -- No filtertype? Return all

    --- Count the members for each account
    
    declare c cursor for select distinct cid from accounts_out;
    begin
        for r in c loop
            update accounts_out set member_count = 
                    (select count(*) from Members where cid = r.cid)
                where cid = r.cid;
        end loop;
    end;      
       
    -- Calculate pagination stats and add them to the table
       
    select count(*) into _nrows from accounts_out;
    if (coalesce(_pagesize, 0) = 0) then -- No paging = 1 page
        _pagesize := null;
        _npages := 1;
    else 
        _npages := _nrows / _pagesize;
        if (_nrows % _pagesize > 0) then
            _npages := _npages + 1;
        end if;
    end if;
    
    update accounts_out set nrows = _nrows, npages = _npages;

    
    -- Output
    
    return query select * from accounts_out
        order by upper(email) asc
        limit _pagesize offset (_page * _pagesize);
    
end;
$$ language plpgsql;

