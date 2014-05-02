-- -----------------------------------------------------------------------------
--  function get_alert_types()
-- -----------------------------------------------------------------------------
-- Returns the Alert-related fields for the specific member.
--  Pass search criteria into one or both fields.
--  Pass 0 or NULL into a unused field. 
-- -----------------------------------------------------------------------------
-- 2014-03-26 dbrown: created
-- -----------------------------------------------------------------------------

create or replace function get_alert_types(

    _mid    int  default null,
    _cid    int  default null  

) returns table (

    cid         int,
    mid         int,
    alerttype   int,
    alertphone  text,
    alertemail  text

) as $$

begin

    -- Quit if _mid and _cid are both null or 0
    if coalesce(_mid, 0) = 0 and coalesce(_cid, 0) = 0 then return; end if;

    return query 
        select m.cid, m.mid, m.alerttype, 
               fdecrypt(m.x_alertphone),
               fdecrypt(m.x_alertemail)
        from members m 
        where ((_mid is null) or (_mid = 0) or (m.mid = _mid))
          and ((_cid is null) or (_cid = 0) or (m.cid = _cid));
        
    return;

end

$$ language plpgsql;

