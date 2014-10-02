-- ---------------------------------------------------------------------------
--  function admin_create_itemtypes
-- ---------------------------------------------------------------------------
--  Runs once at installation to populate the ref_itemtypes reference table
-- ---------------------------------------------------------------------------
-- 2014-10-02 dbrown: Created

create or replace function admin_create_itemtypes() returns text as $$

declare
    nrows int;

begin

    truncate table ref_itemtypes restart identity cascade;
    insert into ref_itemtypes (name) values
        ('Generic Item'),
        ('Physician'),
        ('Pet'),
        ('Vehicle');

    select count(*) from ref_itemtypes into nrows;
    return 'ItemTypes reference table loaded: '||nrows||' rows.';

end
$$ language plpgsql;
