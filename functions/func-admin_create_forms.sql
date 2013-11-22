-- ===========================================================================
--  function admin_create_forms
-- ---------------------------------------------------------------------------
--  Runs once at installation to populate the Forms reference table
-- ---------------------------------------------------------------------------
--  2013-11-21 dbrown: created
--  2013-11-22 dbrown: added columm 'category' with content 'default'
-- ---------------------------------------------------------------------------

create or replace function admin_create_forms() returns text as $$

declare
    nrows int;

begin

    truncate table ref_forms;
    insert into ref_forms( category, filename, title ) values
        ('default', '24hrTracking_Sheet.pdf',               '24 Hour Tracking Sheet'),
        ('default', 'CommunicationTrackingForm.pdf',        'Communication Tracking Form'),
        ('default', 'EmergencyPreparedness.pdf',            'Emergency Preparedness'),
        ('default', 'EmergencySafety.pdf',                  'Emergency Safety'),
        ('default', 'GuestList.pdf',                        'Guest List'),
        ('default', 'HealthTrackingSheet.pdf',              'Health Tracking Sheet'),
        ('default', 'HealthTrackingSheetAdult.pdf',         'Health Tracking Sheet (Adult)'),
        ('default', 'HealthTrackingSheetChildTeenager.pdf', 'Health Tracking Sheet (Child/Teenager)'),
        ('default', 'HealthTrackingSheetOlderAdult.pdf',    'Health Tracking Sheet (Older Adult)'),
        ('default', 'InfantBreastFeeding.pdf',              'Infant Breast Feeding'),
        ('default', 'InfantDiaperingSleeping.pdf',          'Infant Diapering/Sleeping'),
        ('default', 'InfantFeedingFormulaTracker.pdf',      'Infant Feeding/Formula Tracker'),
        ('default', 'MedicalAuthorizationForm.pdf',         'Medical Authorization Form'),
        ('default', 'PackingList.pdf',                      'Packing List'),
        ('default', 'Personal_Care_Routine.pdf',            'Personal Care Routine'),
        ('default', 'SelfAdvocacy.pdf',                     'Self-Advocacy'),
        ('default', 'ToDoAnnual.pdf',                       'To-Do: Annual'),
        ('default', 'ToDoChoresWeekly.pdf',                 'To-Do: Weekly Chores'),
        ('default', 'ToDoDaily.pdf',                        'To-Do: Daily'),
        ('default', 'ToDoWeekly.pdf',                       'To-Do: Weekly');

    select count(*) into nrows from ref_forms;
    return 'Forms reference table loaded: '||nrows||' rows.';

end
$$ language plpgsql;
