-----------------------------------------------------------------------------
-- function get_delphi_contacts
-----------------------------------------------------------------------------
--
-- 2016-04-21 dbrown: created
-----------------------------------------------------------------------------

create or replace function get_delphi_contacts(

    _dt timestamp default null

) returns table (

    email   text,
    fname   text,
    lname   text,
    dt_added timestamp

) as $$

begin

    return query
    select fdecrypt(dc.x_email) as email,
            fdecrypt(dc.x_fname) as fname,
            fdecrypt(dc.x_lname) as lname,
            dc.dt_added
    from delphi_contacts dc
    where ( _dt is null)
        or ( _dt = date_trunc('day', dc.dt_added));

end

$$ language plpgsql;
