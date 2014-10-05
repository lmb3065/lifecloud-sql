-- ---------------------------------------------------------------------------
--  function get_itemtype_text
-- ---------------------------------------------------------------------------
--  2014-10-02 dbrown: Created
-- ---------------------------------------------------------------------------

create or replace function get_itemtype_text(

    _uid int

) returns text as $$

declare

    _out text;

begin

    select name into _out from ref_itemtypes
    where uid = _uid;

    return _out;

end
$$ language plpgsql;
