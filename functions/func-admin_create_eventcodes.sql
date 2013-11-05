
-- =============================================================================
-- admin_create_eventcodes()
-- -----------------------------------------------------------------------------
-- The event codes are defined here.
-- This function is run automatically by the database installation script. 
-- =============================================================================
-- 2013-10-08 dbrown: Initial check-in
-- 2013-10-12 dbrown: Added 9006 'error updating password'
-- 2013-10-13 dbrown: Added 9999 'assert failure'
-- 2013-10-29 dbrown: Added 9026 'error deleting file', 'item' is now 'file'
--                    Changed 9031 'error updating item' to 9025
-- 2013-11-01 dbrown: Revised to better reflect current project
-----------------------------------------------------------------------------

create or replace function admin_create_eventcodes()  returns int as $$

begin
    truncate table ref_eventcodes;
    insert into ref_eventcodes(code, description) values

    /* -- general rules :
        nnn0 Add/Create
        nnn3 Update
        nnn5 Get
        nnn8 Delete
        nnn9 Delete by Admin
    
        nn2n Account
        nn3n Member
        nn4n Password
        nn5n Session
        nn6n Event
        nn7n Folder
        nn8n File
      */  
    
    
    -- 0000 - 0999 : Detailed (debug) information
    
    -- 1000 - 1999 : Normal conditions / notifications 
    
        ( '1000', 'user logged in' ),
        ( '1001', 'user logged out' ),
        ( '1003', 'automatic log-in' ),
        ( '1004', 'userid/password e-mailed' ),
        ( '1005', 'delphi notified' ),
        ( '1020', 'new account registration' ),
        ( '1021', 'new account added by admin' ),
        ( '1022', 'account updated' ),
        ( '1028', 'account deleted' ),
        ( '1029', 'account deleted by admin' ),
        ( '1030', 'new member added' ),
        ( '1031', 'new member added by admin' ),
        ( '1032', 'member updated' ),
        ( '1038', 'member deleted' ),
        ( '1039', 'member deleted by admin' ),
        ( '1040', 'password changed' ),
        ( '1041', 'password changed by owner' ),
        ( '1042', 'password changed by admin' ),
        ( '1070', 'new folder added' ),
        ( '1071', 'new folder added by owner' ),
        ( '1072', 'new folder added by admin' ),
        ( '1073', 'folder updated' ),
        ( '1077', 'folder deleted' ),
        ( '1078', 'folder deleted by owner' ),
        ( '1079', 'folder deleted by admin' ),
        ( '1080', 'new file added' ),
        ( '1081', 'new file added by owner' ),
        ( '1082', 'new file added by admin' ),
        ( '1087', 'file deleted' ),
        ( '1088', 'file deleted by owner' ),
        ( '1089', 'file deleted by admin' ),
        
    -- 4000 - 4999 : User's Fault errors
    
        ( '4000', 'invalid login attempt' ),
        ( '4006', 'unauthorized page attempt' ),
        ( '4020', 'user could not add account' ),
        ( '4030', 'user could not add member' ),
        ( '4040', 'user could not update password' ),       
        ( '4070', 'user could not add folder' ),
        ( '4073', 'user could not update folder' ),
        ( '4078', 'user could not delete folder' ),
        ( '4080', 'user could not add file' ),
        ( '4088', 'user could not delete file' ),
        
           
    -- 9000+ : Database errors
        ( '9020', 'error adding account' ),
        ( '9022', 'error updating account' ),
        ( '9030', 'error adding member' ),
        ( '9032', 'error updating member' ),
        ( '9040', 'error updating password' ),
        ( '9050', 'error updating session'  ),
        ( '9070', 'error adding folder' ),
        ( '9073', 'error updating folder' ),
        ( '9079', 'error deleting folder' ),
        ( '9080', 'error adding file' ),
        ( '9085', 'error getting file(s)' ),
        ( '9089', 'error deleting file' ),
        
    -- 9500+: Programming errors
        ( '9500', 'required argumemt(s) were NULL' ),
        ( '9501', 'an argument had an invalid value' ),
        ( '9999', 'ASSERT failure' );

    return 1;
end;
$$ language plpgsql;



