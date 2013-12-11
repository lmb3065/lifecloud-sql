
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
-- 2013-12-11 dbrown: removed itemtype field
-- -----------------------------------------------------------------------------

create or replace function admin_create_defaultfolders() returns text as $$
declare
    nrows int;
begin
    truncate table ref_defaultfolders cascade;
    insert into ref_defaultfolders(x_name, x_desc) values
        (fencrypt('Activities'),            fencrypt('Activities folder')),
        (fencrypt('Car Pool'),              fencrypt('Car Pool folder')),
        (fencrypt('Education'),             fencrypt('Education folder')),
        (fencrypt('Emergency'),             fencrypt('Emergency folder')),
        (fencrypt('Financial Summary'),     fencrypt('Financial folder')),
        (fencrypt('Insurance'),             fencrypt('Insurance folder')),
        (fencrypt('Medical'),               fencrypt('Medical folder')),
        (fencrypt('Memory Box'),            fencrypt('Memory Box folder')),
        (fencrypt('Passwords'),             fencrypt('Passwords folder')),
        (fencrypt('Personal Info'),         fencrypt('Personal Info folder')),
        (fencrypt('To Do List'),            fencrypt('To Do List folder'));

    select count(*) into nrows from ref_defaultfolders;
    return 'DefaultFolders reference table loaded: '||nrows||' rows.';
end;
$$ language plpgsql;

