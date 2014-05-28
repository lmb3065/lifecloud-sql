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
-- 2014-02-11 dbrown: pared to Contacts Emergency Medical MemoryBox Reminder
-- 2014-05-24 dbrown: removed Reminders
-- -----------------------------------------------------------------------------

create or replace function admin_create_defaultfolders() returns text as $$
declare
    nrows int;
begin
    truncate table ref_defaultfolders cascade;
    insert into ref_defaultfolders(x_name, x_desc) values
        (fencrypt('Contacts'),              fencrypt('Contacts folder')),
        (fencrypt('Emergency'),             fencrypt('Emergency folder')),
        (fencrypt('Medical'),               fencrypt('Medical folder')),
        (fencrypt('Memory Box'),            fencrypt('Memory Box folder'));

    select count(*) into nrows from ref_defaultfolders;
    return 'DefaultFolders reference table loaded: '||nrows||' rows.';
end;
$$ language plpgsql;
