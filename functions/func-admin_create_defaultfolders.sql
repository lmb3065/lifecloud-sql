
-- =============================================================================
-- admin_create_defaultfolders()
-- -----------------------------------------------------------------------------
-- The default folders for new users are defined here.
-- This function is run automatically by the database installation script. 
-- -----------------------------------------------------------------------------
-- 2013-10-11 dbrown: renamed "Funeral" to "Funeral Plans" (cough)
-- 2013-10-15 dbrown: removed vieworder field
-- 2013-11-09 dbrown: resets UID sequence
-- -----------------------------------------------------------------------------


create or replace function admin_create_defaultfolders() returns int as $$

begin
    truncate table ref_defaultfolders;
    perform setval('ref_defaultfolders_uid_seq', 1 , false);  -- Reset UID sequence

    insert into ref_defaultfolders(x_name, x_desc, itemtype) values 
        (fencrypt('Activities'),            fencrypt('Activities folder'),      0),
        (fencrypt('Car Pool'),              fencrypt('Car Pool folder'),        0),
        (fencrypt('Education'),             fencrypt('Education folder'),       0),
        (fencrypt('Emergency'),             fencrypt('Emergency folder'),       0),
        (fencrypt('Financial Summary'),     fencrypt('Financial folder'),       0),
        (fencrypt('Insurance'),             fencrypt('Insurance folder'),       0),
        (fencrypt('Medical'),               fencrypt('Medical folder'),         0),
        (fencrypt('Memory Box'),            fencrypt('Memory Box folder'),      0),
        (fencrypt('Passwords'),             fencrypt('Passwords folder'),       0),
        (fencrypt('Personal Info'),         fencrypt('Personal Info folder'),   0),
        (fencrypt('To Do List'),            fencrypt('To Do List folder'),      0);
        
    return 1;
end;
$$ language plpgsql;

