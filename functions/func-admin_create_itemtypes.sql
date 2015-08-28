-- ---------------------------------------------------------------------------
--  function admin_create_itemtypes
-- ---------------------------------------------------------------------------
--  Runs once at installation to populate the ref_itemtypes reference table
-- ---------------------------------------------------------------------------
-- 2014-10-02 dbrown: Created
-- 2014-10-31 dbrown: Add itemtypes 15--17

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
        ('reminder'),               -- 15
        ('safety checklist'),       -- 16
        ('items'),                  -- 17
        ('reserved'),               -- 18
        ('reserved'),               -- 19
        ('vehicle'),                -- 20
        ('emergency'),              -- 21
        ('memory'),                 -- 22
        ('item location list'),     -- 23
        ('insurance policy'),       -- 24
        ('banking document'),       -- 25
        ('activity'),               -- 26
        ('funeral plan'),           -- 27
        ('major purchase'),         -- 28
        ('to-do list'),             -- 29
        ('vacation'),               -- 30
        ('tax item'),               -- 31
        ('babysitter'),             -- 32
        ('caregiver'),              -- 33
        ('carpool'),                -- 34
        ('subscription');           -- 35
    select count(*) from ref_itemtypes into nrows;
    return 'ItemTypes reference table loaded: '||nrows||' rows.';

end
$$ language plpgsql;
