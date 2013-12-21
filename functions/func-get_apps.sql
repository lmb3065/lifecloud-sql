-- -----------------------------------------------------------------------------
--  function get_apps()
-- -----------------------------------------------------------------------------
-- 2013-11-05 dbrown: created
-- -----------------------------------------------------------------------------

create or replace function get_apps(

    _uid    integer default null

) returns table (

    app_uid int,
    app_url text,
    app_name text,
    app_icon text

) as $$

declare

begin

    if (_uid is null) then
        return query select ra.uid, ra.app_url, ra.app_name, ra.app_icon
            from ref_apps ra
            order by ra.uid;
    else
        return query select ra.uid, ra.app_url, ra.app_name, ra.app_icon
            from ref_apps ra where uid=_uid;
    end if;

    return;

end

$$ language plpgsql;
