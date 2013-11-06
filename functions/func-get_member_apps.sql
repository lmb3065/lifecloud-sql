
-- -----------------------------------------------------------------------------
--  function get_member_apps
-- -----------------------------------------------------------------------------
--  Returns a 64-character string representing the member's apps.
--  If the requested MID does not exist, the string consists of all spaces.
-- -----------------------------------------------------------------------------

-- 2013-11-05 dbrown: Created

create or replace function get_member_apps(

    _mid integer

) returns char(64) as $$

declare

    result char(64) := NULL;

begin

    select apps into result
        from member_apps
        where mid = _mid;
        
    if (result is null) then return cast('' as char(64)); end if;

    return result;
end

$$ language plpgsql;

