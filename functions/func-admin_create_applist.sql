-- -----------------------------------------------------------------------------
--  function admin_create_applist
-- -----------------------------------------------------------------------------
--  Populates the ref_apps reference table with the available applications
--  This function is only run once during initial database setup
-- -----------------------------------------------------------------------------
--  2013-11-05 dbrown: created
--  2013-11-10 dbrown: returns void; communicates via RAISE
--  2013-11-14 dbrown: Communicates by returning TEXT
--  2013-12-11 dbrown: default app_url replaced with ComingSoon.jsp, as we
--                     begin developing the actual apps
--  2014-01-23 dbrown: added URLs for Education, Reminder, ReviewReminders
--  2014-03-23 dbrown: add URLS to match database contents
--  2014-04-13 dbrown: req by lbrown appReview -> appReview.jsp
--  2014-08-07 dbrown: req by lbrown add appPets
--  2014-08-28 dbrown: app/appMedical.jsp
--  2014-09-26 dbrown: appMedical, appEducation URL changed
--  2014-09-29 dbrown: appAutos URL changed
--  2014-10-01 dbrown: URL changes
--  2014-10-17 dbrown: Reminder / Review Reminders URLs changed
-- -----------------------------------------------------------------------------

create or replace function admin_create_applist() returns text as $$
declare
    nrows int;
begin

 truncate table ref_apps restart identity;

 insert into ref_apps( app_url, app_name, app_icon) values
 
     ( 'app/Activities.jsp','Activities',                   'activities.gif'    ),
     ( 'app/Autos.jsp',     'Autos',                        'auto.gif'          ),
     ( 'comingSoon.jsp',    'Babysitting',                  'babysitting.gif'   ),
     ( 'comingSoon.jsp',    'Banking<br/>Information',      'banking.gif'       ),
     ( 'comingSoon.jsp',    'Caregiver',                    'caregiver.gif'     ),
     ( 'comingSoon.jsp',    'Carpool',                      'carpool.gif'       ),
     ( 'comingSoon.jsp',    'Clients',                      'client.gif'        ),
     ( 'app/Contacts.jsp',  'Contacts',                     'contacts.gif'      ),
     ( 'app/Education.jsp', 'Education',                    'education.gif'     ),
     ( 'comingSoon.jsp',    'Elder&nbsp;Care',              'eldercare.gif'     ),
     ( 'app/Emergency.jsp', 'Emergency',                    'emergency.gif'     ),
     ( 'comingSoon.jsp',    'Financial<br/>Summary',        'financial.gif'     ),
     ( 'comingSoon.jsp',    'Funeral<br/>Plans',            'funeral.gif'       ),
     ( 'comingSoon.jsp',    'Gifts',                        'gifts.gif'         ),
     ( 'comingSoon.jsp',    'Handyman<br/>Contractor',      'handyman.gif'      ),
     ( 'app/Home.jsp',      'Home',                         'home.gif'          ),
     ( 'comingSoon.jsp',    'Home<br/>Improvement',         'home_improvement.gif'),
     ( 'comingSoon.jsp',    'Home Care<br/>Utilities',      'home_repair.gif'   ),
     ( 'comingSoon.jsp',    'Important<br/>Dates',          'dates.gif'         ),
     ( 'comingSoon.jsp',    'Insurance',                    'insurance.gif'     ),
     ( 'app/Kitchen.jsp',   'Kitchen',                      'kitchen.gif'       ),
     ( 'comingSoon.jsp',    'Legal<br/>Documents',          'legal.gif'         ),
     ( 'comingSoon.jsp',    'Loan<br/>Information',         'loans.gif'         ),
     ( 'comingSoon.jsp',    'Major<br/>Purchases',          'purchases.gif'     ),
     ( 'comingSoon.jsp',    'Marriage<br/>Information',     'marriage.gif'      ),
     ( 'app/Medical.jsp',   'Medical',                      'medical.gif'       ),
     ( 'app/Memories.jsp',  'Memories',                     'memories.gif'      ),
     ( 'comingSoon.jsp',    'Net&nbsp;Worth',               'net_worth.gif'     ),
     ( 'comingSoon.jsp',    'Party',                        'party.gif'         ),
     ( 'comingSoon.jsp',    'Passwords',                    'passwords.gif'     ),
     ( 'comingSoon.jsp',    'Personal',                     'personal.gif'      ),
     ( 'app/Pets.jsp',      'Pets',                         'pets.gif'          ),
     ( 'comingSoon.jsp',    'Professional<br/>Relationships', 'contacts_professional.gif'),
     ( 'comingSoon.jsp',    'R&eacute;sum&eacute;',         'resume.gif'        ),
     ( 'comingSoon.jsp',    'Subscriptions',                'subscriptions.gif' ),
     ( 'comingSoon.jsp',    'Tax&nbsp;Returns',             'taxes.gif'         ),
     ( 'comingSoon.jsp',    'To&nbsp;Do&nbsp;List',         'todo.gif'          ),
     ( 'comingSoon.jsp',    'Vacation',                     'vacation.gif'      ),
     ( 'comingSoon.jsp',    'Wallet Contents',              'wallet.gif'        ),
     ( 'comingSoon.jsp',    'Delphi VIM',                   'vim.gif'           ),
     ( 'app/Reminders.jsp', 'Reminder',                     'reminder.gif'      ),
     ( 'app/Reminders2.jsp', 'Review<br/>Reminders',        'reminders.gif'     );

    select count(*) into nrows from ref_apps;
    return 'AppList reference table loaded: '||nrows||' rows.';

end;
$$ language plpgsql;
