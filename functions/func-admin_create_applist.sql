
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
-- -----------------------------------------------------------------------------

create or replace function admin_create_applist() returns text as $$
declare
    nrows int;
begin

 truncate table ref_apps restart identity;

 insert into ref_apps( app_url, app_name, app_icon) values
     ( 'appActivities',     'Activities',                   'activities.gif'    ),
     ( 'appAutos',          'Autos',                        'auto.gif'          ),
     ( 'comingSoon.jsp',    'Babysitting',                  'babysitting.gif'   ),
     ( 'comingSoon.jsp',    'Banking<br/>Information',      'banking.gif'       ),
     ( 'comingSoon.jsp',    'Caregiver',                    'caregiver.gif'     ),
     ( 'comingSoon.jsp',    'Carpool',                      'carpool.gif'       ),
     ( 'comingSoon.jsp',    'Clients',                      'client.gif'        ),
     ( 'comingSoon.jsp',    'Contacts',                     'contacts.gif'      ),
     ( 'comingSoon.jsp',    'Cooking/Dining',               'cooking.gif'       ),
     ( 'comingSoon.jsp',    'Education',                    'education.gif'     ),
     ( 'comingSoon.jsp',    'Elder&nbsp;Care',              'eldercare.gif'     ),
     ( 'comingSoon.jsp',    'Emergency',                    'emergency.gif'     ),
     ( 'comingSoon.jsp',    'Financial<br/>Summary',        'financial.gif'     ),
     ( 'comingSoon.jsp',    'Funeral<br/>Plans',            'funeral.gif'       ),
     ( 'comingSoon.jsp',    'Gifts',                        'gifts.gif'         ),
     ( 'comingSoon.jsp',    'Handyman<br/>Contractor',      'handyman.gif'      ),
     ( 'comingSoon.jsp',    'Home<br/>Emergency',           'home_emergency.gif'),
     ( 'comingSoon.jsp',    'Home<br/>Improvement',         'home_improvement.gif'),
     ( 'comingSoon.jsp',    'Home Care<br/>Utilities',      'home_repair.gif'   ),
     ( 'comingSoon.jsp',    'Important<br/>Dates',          'dates.gif'         ),
     ( 'comingSoon.jsp',    'Insurance',                    'insurance.gif'     ),
     ( 'comingSoon.jsp',    'Legal<br/>Documents',          'legal.gif'         ),
     ( 'comingSoon.jsp',    'Loan<br/>Information',         'loans.gif'         ),
     ( 'comingSoon.jsp',    'Major<br/>Purchases',          'purchases.gif'     ),
     ( 'comingSoon.jsp',    'Marriage<br/>Information',     'marriage.gif'      ),
     ( 'comingSoon.jsp',    'Medical',                      'medical.gif'       ),
     ( 'comingSoon.jsp',    'Memory<br/>Box',               'memories.gif'      ),
     ( 'comingSoon.jsp',    'Net&nbsp;Worth',               'net_worth.gif'     ),
     ( 'comingSoon.jsp',    'Party',                        'party.gif'         ),
     ( 'comingSoon.jsp',    'Passwords',                    'passwords.gif'     ),
     ( 'comingSoon.jsp',    'Personal',                     'personal.gif'      ),
     ( 'comingSoon.jsp',    'Pets',                         'pets.gif'          ),
     ( 'comingSoon.jsp',    'Professional<br/>Relationships', 'contacts_professional.gif'),
     ( 'comingSoon.jsp',    'R&eacute;sum&eacute;',         'resume.gif'        ),
     ( 'comingSoon.jsp',    'Subscriptions',                'subscriptions.gif' ),
     ( 'comingSoon.jsp',    'Tax&nbsp;Returns',             'taxes.gif'         ),
     ( 'comingSoon.jsp',    'To&nbsp;Do&nbsp;List',         'todo.gif'          ),
     ( 'comingSoon.jsp',    'Vacation',                     'vacation.gif'      ),
     ( 'comingSoon.jsp',    'Wallet Contents',              'wallet.gif'        ),
     ( 'comingSoon.jsp',    'Delphi VIM',                   'vim.gif'           ),
     ( 'comingSoon.jsp',    'Reminder',                     'reminder.gif'      ),
     ( 'comingSoon.jsp',    'Review<br/>Reminders',         'reminders.gif'     );

    select count(*) into nrows from ref_apps;
    return 'AppList reference table loaded: '||nrows||' rows.';

end
$$ language plpgsql;

