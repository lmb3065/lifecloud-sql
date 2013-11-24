-- ===========================================================================
--  function get_lccategories
-- ---------------------------------------------------------------------------
--  Simply retrieves the ref_categories table
-- ---------------------------------------------------------------------------
--  2013-11-24 dbrown: created
-- ---------------------------------------------------------------------------

create or replace function get_lccategories ()
returns table (uid int, name text) as $$
begin

    select uid, name from ref_categories;

end
$$ language plpgsql;
