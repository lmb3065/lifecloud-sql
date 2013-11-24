-- ===========================================================================
--  function admin_create_forms
-- ---------------------------------------------------------------------------
--  Runs once at installation to populate the Forms reference table
--   * DEPENDS ON ref_categories
-- ---------------------------------------------------------------------------
--  2013-11-21 dbrown: created
--  2013-11-22 dbrown: added columm 'category' with content 'default'
--  2013-11-23 dbrown: reorganized around categories
-- ---------------------------------------------------------------------------

create or replace function admin_create_forms() returns text as $$

declare
    nrows int;
    i int;
begin

    truncate table ref_forms;

    select cat.uid into i from ref_categories cat where name = 'Personal';
    insert into ref_forms( category, filename, title ) values
        (i, 'ToDoAnnual.pdf',       'To-Do: Annual'),
        (i, 'ToDoChoresWeekly.pdf', 'To-Do: Weekly Chores'),
        (i, 'ToDoDaily.pdf',        'To-Do: Daily'),
        (i, 'ToDoWeekly.pdf',       'To-Do: Weekly');

    select cat.uid into i from ref_categories cat where name = 'Home';
    insert into ref_forms( category, filename, title ) values
        (i, 'CommunicationTrackingForm.pdf',        'Communication Tracking Form'),
        (i, 'EmergencyPreparedness.pdf',            'Emergency Preparedness'),
        (i, 'EmergencySafety.pdf',                  'Emergency Safety'),
        (i, 'GuestList.pdf',                        'Guest List'),
        (i, 'PackingList.pdf',                      'Packing List');

    select cat.uid into i from ref_categories cat where name = 'Family';
    insert into ref_forms( category, filename, title ) values
        (i, 'InfantBreastFeeding.pdf',              'Infant Breast Feeding'),
        (i, 'InfantDiaperingSleeping.pdf',          'Infant Diapering/Sleeping'),
        (i, 'InfantFeedingFormulaTracker.pdf',      'Infant Feeding/Formula Tracker');

    select cat.uid into i from ref_categories cat where name = 'Medical';
    insert into ref_forms( category, filename, title ) values
        (i, '24hrTracking_Sheet.pdf', '24 Hour Tracking Sheet'),
        (i, 'HealthTrackingSheet.pdf',              'Health Tracking Sheet'),
        (i, 'HealthTrackingSheetAdult.pdf',         'Health Tracking Sheet (Adult)'),
        (i, 'HealthTrackingSheetChildTeenager.pdf', 'Health Tracking Sheet (Child/Teenager)'),
        (i, 'HealthTrackingSheetOlderAdult.pdf',    'Health Tracking Sheet (Older Adult)'),
        (1, 'MedicalAuthorizationForm.pdf',         'Medical Authorization Form'),
        (i, 'Personal_Care_Routine.pdf',            'Personal Care Routine'),
        (i, 'SelfAdvocacy.pdf',                     'Self-Advocacy');

    select count(*) into nrows from ref_forms;
    return 'Forms reference table loaded: '||nrows||' rows.';

end
$$ language plpgsql;
