
-- =============================================================================
-- admin_create_defaultfolders()
-- -----------------------------------------------------------------------------
-- The default folders for new users are defined here.
-- This function is run automatically by the database installation script.
-- -----------------------------------------------------------------------------
-- 2013-10-11 dbrown: renamed "Funeral" to "Funeral Plans" (cough)
-- 2013-10-15 dbrown: removed vieworder field
-- 2013-11-10 dbrown: returns void, communicates via RAISE
-- 2013-11-14 dbrown: Communicates by returning TEXT
-- -----------------------------------------------------------------------------

create or replace function admin_create_defaultfolders() returns text as $$
declare
    nrows int;
begin
    truncate table ref_defaultfolders cascade;
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

    select count(*) into nrows from ref_defaultfolders;
    return 'DefaultFolders reference table loaded: '||nrows||' rows.';
end;
$$ language plpgsql;

