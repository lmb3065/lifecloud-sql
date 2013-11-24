-- ===========================================================================
--  function get_lcforms
-- ---------------------------------------------------------------------------
--  Gets the specified (or all) contents of the ref_Forms REFERENCE table.
-- ---------------------------------------------------------------------------
--  2013-11-23 dbrown: created
-- ---------------------------------------------------------------------------

create or replace function get_lcforms ( arg_category int default null )
returns table ( title text, filename text, category int ) as $$
begin

    return query
        SELECT rf.title, rf.filename, rf.category
        FROM ref_forms rf
        WHERE ( arg_category is null )
           or ( arg_category = rf.category );

end
$$ language plpgsql;
