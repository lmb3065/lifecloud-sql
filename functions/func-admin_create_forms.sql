-- ===========================================================================
--  function admin_create_forms
-- ---------------------------------------------------------------------------
--  Runs once at installation to populate the Forms reference table
--   * DEPENDS ON ref_categories
-- ---------------------------------------------------------------------------
--  2013-11-21 dbrown: created
--  2013-11-22 dbrown: added columm 'category' with content 'default'
--  2013-11-23 dbrown: reorganized around categories
--  2014-03-24 dbrown: updated to match development database
-- ---------------------------------------------------------------------------

create or replace function admin_create_forms() returns text as $$

declare
    nrows int;
    i int;
begin

    truncate table ref_forms cascade;

    select cat.uid into i from ref_categories cat where name = 'Personal';
    insert into ref_forms( category, filename, title ) values
        (i, 'ToDoDaily.pdf',                        'Daily To Do List'),
        (i, 'ToDoWeekly.pdf',                       'Weekly To Do List'),
        (i, 'ToDoAnnual.pdf',                       'Annual To Do List'),
        (i, 'GuestList.pdf',                        'Guest List'),
        (i, 'Spirituality.pdf',                     'Spirituality and Worship'),
        (i, 'ToDoChoresWeekly.pdf',                 'Chores List');

    select cat.uid into i from ref_categories cat where name = 'Home';
    insert into ref_forms( category, filename, title ) values
        (i, 'AirConditioner.pdf',                   'Air Conditioner'),
        (i, 'Alarm.pdf',                            'Alarm System'),
        (i, 'BackyardGrill.pdf',                    'Backyard Grill'),
        (i, 'BasicTips.pdf',                        'Basic Organizing Tips'),
        (i, 'CleaningAgency.pdf',                   'Cleaning Agency'),
        (i, 'CleaningInformation.pdf',              'Cleaning Instructions'),
        (i, 'CommunicationTrackingForm.pdf',        'Communication Tracking Form'),
        (i, 'Computer.pdf',                         'Computer Information'),
        (i, 'EmergencyGatheringLocations.pdf',      'Emergency Gathering Locations'),
        (i, 'EmergencyNumbers.pdf',                 'Emergency Numbers'),
        (i, 'EmergencyPreparedness.pdf',            'Emergency Preparedness Guide'),
        (i, 'EmergencySafety.pdf',                  'Emergency Safety'),
        (i, 'EvacuationPlan.pdf',                   'Evacuation Plan'),
        (i, 'Locator.pdf',                          'Locator'),
        (i, 'MaintenanceContactInformation.pdf',    'Maintenance Contact Sheet'),
        (i, 'PackingList.pdf',                      'Packing List'),
        (i, 'UtilitiesContacts.pdf',                'Utilities Contacts');

    select cat.uid into i from ref_categories cat where name = 'Family';
    insert into ref_forms( category, filename, title ) values
        (i, '24hrTrackingSheet',                    'Caregiver Tracking Form'),
        (i, 'CaregiverInformation.pdf',             'Caregiver Information'),
        (i, 'FamilyMemberInformation.pdf',          'Family Member Information'),
        (i, 'InfantBreastFeeding.pdf',              'Infant Breast Feeding Schedule'),
        (i, 'InfantDiaperingSleeping.pdf',          'Infant Diapering/Sleeping Schedule'),
        (i, 'InfantFeedingFormulaTracker.pdf',      'Infant Feeding/Formula Schedule'),
        (i, 'PersonalCareRoutine.pdf',              'Personal Care Routine'),
        (i, 'Spirituality.pdf',                     'Spirituality and Worship');

    select cat.uid into i from ref_categories cat where name = 'Medical';
    insert into ref_forms( category, filename, title ) values
        (i, '24hrTrackingSheet',                    'Caregiver Tracking Form'),
        (i, 'CaregiverInformation.pdf',             'Caregiver Information'),
        (i, 'HealthTrackingSheet.pdf',              'Health Tracking Sheet'),
        (1, 'MedicalAuthorizationForm.pdf',         'Medical Authorization Form'),
        (i, 'PersonalCareRoutine.pdf',              'Personal Care Routine'),
        (i, 'SelfAdvocacy.pdf',                     'Self-Advocacy Tips');

    select cat.uid into i from ref_categories cat where name = 'Pet';
    insert into ref_forms( category, filename, title ) values
        (i, 'PetCare.pdf',                          'Pet Care'),
        (i, 'PetSitter.pdf',                        'Pet Sitter Information');
    
    select cat.uid into i from ref_categories cat where name = 'Financial';
    insert into ref_forms( category, filename, title ) values
        (i, 'Accountant.pdf',                       'Accountant'),        
        (i, 'Banking.pdf',                          'Banking'),
        (i, 'Brokers.pdf',                          'Brokers');

    select cat.uid into i from ref_categories cat where name = 'Legal';
    insert into ref_forms( category, filename, title ) values
        (i, 'Attorney.pdf',                         'Attorney');

    select cat.uid into i from ref_categories cat where name = 'Insurance';
    insert into ref_forms( category, filename, title ) values
        (i, 'Insurance.pdf',                        'Insurance');

    --------------------------------------------------------------------------------        
        
    select count(*) into nrows from ref_forms;
    return 'Forms reference table loaded: '||nrows||' rows.';

end
$$ language plpgsql;
