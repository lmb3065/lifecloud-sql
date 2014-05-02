 -- -----------------------------------------------------------------------------
 --  admin_create_retvals.sql
 -- ---------------------------------------------------------------------------
 --  2013-12-20 dbrown: added -15, -27 (items)
 --  2014-04-12 dbrown: added -16 (reminder)
 -- -----------------------------------------------------------------------------

 create or replace function admin_create_retvals() returns text as $$

 declare
    nrows int;
 begin
    truncate table ref_retvals;
    insert into ref_retvals( retval, msg ) values

        ( 1,   'Success' ),
        ( 0,   'A required argument was invalid' ),

        ( -10, 'Account does not exist' ),
        ( -11, 'Member does not exist' ),
        ( -12, 'Target Member does not exist' ),
        ( -13, 'Folder does not exist' ),
        ( -14, 'File does not exist' ),
        ( -15, 'Item does not exist' ),
        ( -16, 'Reminder does not exist' ),

        ( -20, 'Account exists with this e-mail address' ),
        ( -21, 'Member exists with this e-mail address' ),
        ( -22, 'Member exists with this UserID' ),
        ( -23, 'Member exists with this Name and Account' ),
        ( -24, 'Account would exceed maximum Members' ),
        ( -25, 'Member already has this folder' ),
        ( -26, 'Folder already contains this file' ),
        ( -27, 'Folder already contains this item' ),

        ( -80, 'Action not authorized' ),

        ( -98, 'Database exception' ),
        ( -99, 'Unanticipated failure type' );

    select count(*) into nrows from ref_retvals;
    return 'RetVALS ref table loaded: '||nrows||' rows';

 end
 $$ language plpgsql;
