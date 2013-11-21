
create or replace function admin_create_forms() returns text as $$

declare
    nrows int;

begin

    truncate table ref_forms;
    insert into ref_forms( filename, title ) values
        ('24hrTracking_Sheet.pdf',          '24 Hour Tracking Sheet'),
        ('CommunicationTrackingForm.pdf',   'Communication Tracking Form'),
        ('EmergencyPreparedness.pdf',       'Emergency Preparedness'),
        ('EmergencySafety.pdf',             'Emergency Safety'),
        ('GuestList.pdf',                   'Guest List'),
        ('HealthTrackingSheet.pdf',         'Health Tracking Sheet'),
        ('HealthTrackingSheetAdult.pdf',         'Health Tracking Sheet (Adult)'),
        ('HealthTrackingSheetChildTeenager.pdf', 'Health Tracking Sheet (Child/Teenager)'),
        ('HealthTrackingSheetOlderAdult.pdf',    'Health Tracking Sheet (Older Adult)'),
        ('InfantBreastFeeding.pdf',         'Infant Breast Feeding'),
        ('InfantDiaperingSleeping.pdf',     'Infant Diapering/Sleeping'),
        ('InfantFeedingFormulaTracker.pdf', 'Infant Feeding/Formula Tracker'),
        ('MedicalAuthorizationForm.pdf',    'Medical Authorization Form'),
        ('PackingList.pdf',                 'Packing List'),
        ('Personal_Care_Routine.pdf',       'Personal Care Routine'),
        ('SelfAdvocacy.pdf',                'Self-Advocacy'),
        ('ToDoAnnual.pdf',                  'To-Do: Annual'),
        ('ToDoChoresWeekly.pdf',            'To-Do: Weekly Chores'),
        ('ToDoDaily.pdf',                   'To-Do: Daily'),
        ('ToDoWeekly.pdf',                  'To-Do: Weekly');

    select count(*) into nrows from ref_forms;
    return 'Forms reference table loaded: '||nrows||' rows.';

end
$$ language plpgsql;
