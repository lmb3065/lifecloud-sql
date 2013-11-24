-- ---------------------------------------------------------------------------
--  function admin_create_categories
-- ---------------------------------------------------------------------------
--  Runs once at installation to populate the Forms reference table
-- ---------------------------------------------------------------------------

create or replace function admin_create_categories() returns text as $$

declare
    nrows int;

begin

    truncate table ref_categories restart identity cascade;
    insert into ref_categories (name) values
        ('Personal'),
        ('Home'),
        ('Family'),
        ('Medical'),
        ('Pet'),
        ('Financial'),
        ('Legal'),
        ('Insurance');

    select count(*) from ref_categories into nrows;
    return 'Categories reference table loaded: '||nrows||' rows.';

end
$$ language plpgsql;
