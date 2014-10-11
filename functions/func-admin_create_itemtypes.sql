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
        ('item'),                   -- 1
        ('physician'),              -- 2
        ('provider'),               -- 3
        ('auto'),                   -- 4
        ('school'),                 -- 5
        ('home'),                   -- 6
        ('kitchen'),                -- 7
        ('pet'),                    -- 8
        ('health tracking form'),   -- 9
        ('medical facility stay'),  -- 10
        ('medication/supplement'),  -- 11
        ('pharmacy'),               -- 12
        ('allergy'),                -- 13
        ('health history'),         -- 14
        ('reserved'),               -- 15
        ('reserved'),               -- 16
        ('reserved'),               -- 17
        ('reserved'),               -- 18
        ('reserved'),               -- 19
        ('vehicle')                 -- 20
    select count(*) from ref_itemtypes into nrows;
    return 'ItemTypes reference table loaded: '||nrows||' rows.';

end
$$ language plpgsql;
