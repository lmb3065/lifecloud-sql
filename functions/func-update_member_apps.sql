
-- -----------------------------------------------------------------------------
--  function update_member_apps
-- -----------------------------------------------------------------------------
--  Updates the member's entry in then member_apps table.
--  If there is no entry for the member, creates one.
-- -----------------------------------------------------------------------------
--  Returns 1 on success, 0 on failure
-- -----------------------------------------------------------------------------
-- 2013-11-05 dbrown: Created

create or replace function update_member_apps(

    _mid integer,
    _apps char(64)

) returns int as $$

declare

    nrows integer;

begin

    if exists (select mid from member_apps where mid = _mid)
    then    
        update member_apps set apps = _apps where mid = _mid;
    else
        insert into member_apps (mid, apps) values (_mid, _apps);
    end if;
            
    get diagnostics nrows = row_count;
    return nrows;
    
end
$$ language plpgsql;

