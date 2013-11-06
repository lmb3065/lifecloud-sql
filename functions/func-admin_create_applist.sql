
-- -----------------------------------------------------------------------------
--  function admin_create_applist
-- -----------------------------------------------------------------------------
--  Populates the ref_apps reference table with the available applications
--  This function is only run once during initial database setup
-- -----------------------------------------------------------------------------
--  2013-11-05 dbrown: created
-- -----------------------------------------------------------------------------

create or replace function admin_create_applist() returns integer as $$

begin
                                                                                         
 truncate table ref_apps;                                                                
                                                                                         
 insert into ref_apps( app_url, app_name, app_icon) values                               
     ( 'activities',      'Activities',               'activities.gif'    ),             
     ( 'autos',           'Autos',                    'auto.gif'          ),             
     ( 'babysitting',     'Babysitting',              'babysitting.gif'   ),             
     ( 'banking',         'Banking<br/>Information',  'banking.gif'       ),             
     ( 'caregiver',       'Caregiver',                'caregiver.gif'     ),             
     ( 'carpool',         'Carpool',                  'carpool.gif'       ),             
     ( 'clients',         'Clients',                  'client.gif'        ),             
     ( 'contacts',        'Contacts',                 'contacts.gif'      ),             
     ( 'cooking',         'Cooking/Dining',           'cooking.gif'       ),             
     ( 'education',       'Education',                'education.gif'     ),             
     ( 'elderCare',       'Elder&nbsp;Care',          'eldercare.gif'     ),             
     ( 'emergency',       'Emergency',                'emergency.gif'     ),             
     ( 'financial',       'Financial<br/>Summary',    'financial.gif'     ),             
     ( 'funeral',         'Funeral<br/>Plans',        'funeral.gif'       ),             
     ( 'gifts',           'Gifts',                    'gifts.gif'         ),             
     ( 'contractor',      'Handyman<br/>Contractor',  'handyman.gif'      ),             
     ( 'homeEmergency',   'Home<br/>Emergency',       'home_emergency.gif'),             
     ( 'homeImprovement', 'Home<br/>Improvement',     'home_improvement.gif'),           
     ( 'homeCare',        'Home Care<br/>Utilities',  'home_repair.gif'   ),             
     ( 'dates',           'Important<br/>Dates',      'dates.gif'         ),             
     ( 'insurance',       'Insurance',                'insurance.gif'     ),             
     ( 'legal',           'Legal<br/>Documents',      'legal.gif'         ),             
     ( 'loan',            'Loan<br/>Information',     'loans.gif'         ),             
     ( 'majorPurchases',  'Major<br/>Purchases',      'purchases.gif'     ),             
     ( 'marriage',        'Marriage<br/>Information', 'marriage.gif'      ),             
     ( 'medical',         'Medical',                  'medical.gif'       ),             
     ( 'memoryBox',       'Memory<br/>Box',           'memories.gif'      ),             
     ( 'netWorth',        'Net&nbsp;Worth',           'net_worth.gif'     ),             
     ( 'party',           'Party',                    'party.gif'         ),             
     ( 'passwords',       'Passwords',                'passwords.gif'     ),             
     ( 'personal',        'Personal',                 'personal.gif'      ),             
     ( 'pets',            'Pets',                     'pets.gif'          ),             
     ( 'professional',    'Professional<br/>Relationships', 'contacts_professional.gif'),
     ( 'resume',          'R&eacute;sum&eacute;',     'resume.gif'        ),             
     ( 'subscriptions',   'Subscriptions',            'subscriptions.gif' ),             
     ( 'taxes',           'Tax&nbsp;Returns',         'taxes.gif'         ),             
     ( 'toDo',            'To&nbsp;Do&nbsp;List',     'todo.gif'          ),             
     ( 'vacation',        'Vacation',                 'vacation.gif'      ),             
     ( 'wallet',          'Wallet Contents',          'wallet.gif'        ),             
     ( 'reminder',        'Reminder',                 'reminder.gif'      ),             
     ( 'reminder',        'Review<br/>Reminders',     'reminders.gif'     );             
 return 1;                                                                               

end
$$ language plpgsql;

