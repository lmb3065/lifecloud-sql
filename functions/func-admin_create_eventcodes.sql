-- =============================================================================
-- admin_create_eventcodes()
-- -----------------------------------------------------------------------------
-- The event codes are defined here.
-- This function is run automatically by the database installation script.
-- =============================================================================
-- 2013-10-08 dbrown: Initial check-in
-- 2013-11-01 dbrown: Completely Revised
-- 2013-11-10 dbrown: returns void, communicates via RAISE NOTICE
-- 2013-11-14 dbrown: communicates by returning text
-- 2013-11-17 dbrown: cleanup
-----------------------------------------------------------------------------

create or replace function admin_create_eventcodes() returns text as $$
declare
    nrows int;
begin

    /*  0---  (Obsolete eventcodes)
        1---  OK / Normal notification
        4---  User's Fault error
        6---  Authorization Failure
        9---  Developer Error
        -00-  Login (unique last-digit codes)
        -02-  Account
        -03-  Member
        -04-  Password
        -05-  Session
        -07-  Folder
        -08-  File
        -09-  Event
        ---0  Add/Create
        ---1  Add/Create by Account Owner
        ---2  Add/Create by Admin
        ---3  Update
        ---4  Update by Account Owner
        ---5  Update by Admin
        ---6  Get
        ---7  Delete
        ---8  Delete by Account Owner
        ---9  Delete by Admin */

    truncate table ref_eventcodes cascade;
    insert into ref_eventcodes(code, description) values

    -- 0000 - 0000 : Obsolete eventcodes still in use

        ( '0007', 'automatic log-out' ),

    -- 1000 - 1999 : Normal conditions / notifications

        ( '1000', 'user logged in' ),
        ( '1001', 'user logged out' ),
        ( '1002', 'invalid login attempt' ),
        ( '1003', 'automatic log-in' ),
        ( '1004', 'automatic log-out' ),
        ( '1005', 'userid/password e-mailed' ),
        ( '1006', 'delphi notified' ),
        ( '1020', 'new account registration' ),
        ( '1023', 'account updated' ),
        ( '1029', 'account deleted by Admin' ),
        ( '1030', 'new member added' ),
        ( '1033', 'member updated' ),
        ( '1034', 'member updated by account owner' ),
        ( '1035', 'member updated by Admin' ),
        ( '1037', 'member deleted' ),
        ( '1038', 'member deleted by account owner' ),
        ( '1039', 'member deleted by Admin' ),
        ( '1042', 'password changed (obsolete)' ),
        ( '1043', 'password changed' ),
        ( '1044', 'password changed by owner' ),
        ( '1045', 'password changed by Admin' ),
        ( '1070', 'folder added' ),
        ( '1071', 'folder added by owner' ),
        ( '1072', 'folder added by Admin' ),
        ( '1073', 'folder updated' ),
        ( '1074', 'folder updated by account owner' ),
        ( '1075', 'folder updated by Admin' ),
        ( '1077', 'folder deleted' ),
        ( '1078', 'folder deleted by owner' ),
        ( '1079', 'folder deleted by Admin' ),
        ( '1080', 'file added' ),
        ( '1081', 'file added by owner' ),
        ( '1082', 'file added by Admin' ),
        ( '1087', 'file deleted' ),
        ( '1088', 'file deleted by owner' ),
        ( '1089', 'file deleted by Admin' ),

    -- 4000 - 4999 : User's Fault errors

        ( '4000', 'invalid login attempt' ),
        ( '4006', 'unauthorized page attempt' ),
        ( '4020', 'user could not add account' ),
        ( '4030', 'user could not add member' ),
        ( '4033', 'user could not update member' ),
        ( '4040', 'user could not update password (obsolete)'),
        ( '4043', 'user could not update password' ),
        ( '4070', 'user could not add folder' ),
        ( '4073', 'user could not update folder' ),
        ( '4077', 'user could not delete folder' ),
        ( '4080', 'user could not add file' ),
        ( '4087', 'user could not delete file' ),

    -- 6000+ Authorization (Permissions) Errors

        ( '6000', 'unauthorized login attempt' ),
        ( '6006', 'unauthorized page attempt' ),
        ( '6043', 'unauthorized attempt to change password' ),
        ( '6070', 'unauthorized attempt to add folder' ),
        ( '6077', 'unauthorized attempt to delete folder' ),
        ( '6080', 'unauthorized attempt to add file' ),
        ( '6087', 'unauthorized attempt to delete file' ),

    -- 9000+ : Database/Developer errors

        ( '9020', 'error adding account' ),
        ( '9023', 'error updating account' ),
        ( '9026', 'error getting account(s)' ),
        ( '9030', 'error adding member' ),
        ( '9033', 'error updating member' ),
        ( '9036', 'error getting member(s)' ),
        ( '9043', 'error updating password' ),
        ( '9050', 'error updating session'  ),
        ( '9070', 'error adding folder' ),
        ( '9073', 'error updating folder' ),
        ( '9077', 'error deleting folder' ),
        ( '9080', 'error adding file' ),
        ( '9086', 'error getting file(s)' ),
        ( '9087', 'error deleting file' ),

    --
        ( '9999', 'general ASSERT failure');

    -- ---------------------------------------------------------------------------
    -- OBSOLETE EventCodes
    -- ---------------------------------------------------------------------------
/*
        ( '0000', 'user logged in (obsolete eventcode, use 1000)' ),
        ( '0001', 'user logged out (obsolete eventcode, use 1001)' ),
        ( '0002', 'invalid login attempt (obsolete eventcode, use 4000)' ),
        ( '0003', 'automatic log-in (obsolete eventcode, use 1003)' ),
        ( '0004', 'userid/password e-mailed (obsolete eventcode)' ),
        ( '0005', 'imaging options notified (obsolete eventcode)' ),
        ( '0006', 'unauthorized page attempt (obsolete eventcode)' ),

        ( '0010', 'account added by admin (obsolete eventcode)' ),
        ( '0011', 'account deleted by admin (obsolete eventcode)' ),
        ( '0012', 'new account registration (obsolete eventcode)' ),
        ( '0013', 'new member added (obsolete eventcode)' ),
        ( '0014', 'member deleted (obsolete eventcode)' ),
        ( '0015', 'account updated (obsolete eventcode)' ),
        ( '0016', 'member updated (obsolete eventcode)' ),
        ( '0017', 'member password reset (obsolete eventcode)' ),

        ( '0020', 'folder added (obsolete eventcode)' ),
        ( '0021', 'folder updated (obsolete eventcode)' ),
        ( '0022', 'folder deleted (obsolete eventcode)' ),
        ( '0023', 'folder purged (obsolete eventcode)' ),
        ( '0024', 'item added (obsolete eventcode)' ),
        ( '0025', 'item updated (obsolete eventcode)'),
        ( '0026', 'item deleted (obsolete eventcode)'),
        ( '0027', 'item purged (obsolete eventcode)'),
        ( '0028', 'image uploaded (obsolete eventcode)'),
        ( '0029', 'image deleted (obsolete eventcode)'),
        ( '0030', 'user updated password (obsolete eventcode)'),
        ( '0031', 'owner updated password (obsolete eventcode)'),
        ( '0032', 'admin updated password (obsolete eventcode)'),
        ( '0040', 'payment recorded (obsolete eventcode)'),
        ( '0041', 'payment declined (obsolete eventcode)'),
        ( '0042', 'IPN recevied (obsolete eventcode)'),
        ( '0043', 'promotion code added (obsolete eventcode)'),
        ( '0044', 'promotion code updated (obsolete eventcode)'),
        ( '0045', 'promotion code deleted (obsolete eventcode)'),

        ( '9000', 'failed login attempt (obsolete eventcode)'),
        ( '9001', 'error adding account (obsolete eventcode)'),
        ( '9002', 'error updating account (obsolete eventcode)'),
        ( '9003', 'error adding member (obsolete eventcode)'),
        ( '9004', 'error updating member (obsolete eventcode)'),
        ( '9005', 'error updating session (obsolete eventcode)'),
        ( '9006', 'error updating password (obsolete eventcode)'),
        ( '9011', 'reserved (obsolete eventcode)'),
        ( '9012', 'IPN update error (obsolete eventcode)'),
        ( '9013', 'i/o notification error (obsolete eventcode)'),
        ( '9014', 'error generating password (obsolete eventcode)'),
        ( '9015', 'mail error on lost password (obsolete eventcode)'),
        ( '9016', 'error adding promocode (obsolete eventcode)'),
        ( '9017', 'error updating promocode (obsolete eventcode)'),
        ( '9021', 'error updating folder (obsolete eventcode)'),
        ( '9022', 'error marking folder deleted (obsolete eventcode)'),
        ( '9024', 'error adding file (obsolete eventcode)'),
        ( '9025', 'error updating file (obsolete eventcode)'),
        ( '9040', 'error uploading image (obsolete eventcode)'),
        ( '9041', 'error adding image (obsolete eventcode)');
*/
    select count(*) into nrows from ref_eventcodes;
    return 'EventCodes reference table loaded: '||nrows||' rows.';
end;
$$ language plpgsql;
