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
-- 2013-12-12 dbrown: Added eventcodes for [Item] data type (x10x)
-- 2014-01-03 dbrown: Added eventcodes for account-related login failure
-- 2014-04-12 dbrown: Added eventcodes for Adding, Deleting Reminders
-- 2014-04-13 dbrown: Added eventcodes for Updating Reminders
-- 2014-09-27 dbrown: Added 6086
-- 2014-10-09 dbrown: Changed 9050 -> 9053 'dev err updating session'
-- 2015-01-02 dbrown: Added x12x 'Registration Codes' events
-- 2015-01-15 dbrown: Added 6126 'Auth Failure Getting Regcodes'
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
        -10-  Item
        -11-  Reminder
        -12-  Registration Code
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
        ( '1034', 'member updated by owner' ),
        ( '1035', 'member updated by Admin' ),
        ( '1037', 'member deleted' ),
        ( '1038', 'member deleted by owner' ),
        ( '1039', 'member deleted by Admin' ),
        ( '1042', 'password changed (obsolete)' ),
        ( '1043', 'password changed' ),
        ( '1044', 'password changed by owner' ),
        ( '1045', 'password changed by Admin' ),
        ( '1070', 'folder added' ),
        ( '1071', 'folder added by owner' ),
        ( '1072', 'folder added by Admin' ),
        ( '1073', 'folder updated' ),
        ( '1074', 'folder updated by owner' ),
        ( '1075', 'folder updated by Admin' ),
        ( '1077', 'folder deleted' ),
        ( '1078', 'folder deleted by owner' ),
        ( '1079', 'folder deleted by Admin' ),
        ( '1080', 'file added' ),
        ( '1081', 'file added by owner' ),
        ( '1082', 'file added by Admin' ),
        ( '1083', 'file updated' ),
        ( '1084', 'file updated by owner' ),
        ( '1085', 'file updated by Admin' ),
        ( '1087', 'file deleted' ),
        ( '1088', 'file deleted by owner' ),
        ( '1089', 'file deleted by Admin' ),
        ( '1100', 'item added'),
        ( '1101', 'item added by owner'),
        ( '1102', 'item added by Admin'),
        ( '1103', 'item updated'),
        ( '1104', 'item updated by owner'),
        ( '1105', 'item updated by Admin'),
        ( '1107', 'item deleted'),
        ( '1108', 'item deleted by owner'),
        ( '1109', 'item deleted by Admin'),
        ( '1110', 'reminder added' ),
        ( '1113', 'reminder updated' ),
        ( '1114', 'reminder updated by account owner' ),
        ( '1115', 'reminder updated by Admin' ),
        ( '1117', 'reminder deleted' ),
        ( '1118', 'reminder deleted by account owner' ),
        ( '1119', 'reminder deleted by Admin' ),
        ( '1120', 'registration code added'),
        ( '1123', 'registration code updated'),

    -- 4000 - 4999 : User's Fault errors

        ( '4000', 'invalid login attempt' ),
        ( '4001', 'login denied' ),
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
        ( '4100', 'user could not add item' ),
        ( '4103', 'user could not update item' ),
        ( '4107', 'user could not delete item' ),
        ( '4120', 'user could not add registration code'),
        ( '4123', 'user could not update registration code'),

    -- 6000+ Authorization (Permissions) Errors

        ( '6000', 'unauthorized login attempt' ),
        ( '6006', 'unauthorized page attempt' ),
        ( '6033', 'unauthorized attempt to update member' ),
        ( '6043', 'unauthorized attempt to change password' ),
        ( '6070', 'unauthorized attempt to add folder' ),
        ( '6073', 'unauthorized attempt to modify folder' ),
        ( '6077', 'unauthorized attempt to delete folder' ),
        ( '6080', 'unauthorized attempt to add file' ),
        ( '6083', 'unauthorized attempt to modify file' ),
        ( '6086', 'unauthorized attempt to get files'),
        ( '6087', 'unauthorized attempt to delete file' ),
        ( '6100', 'unauthorized attempt to add item' ),
        ( '6103', 'unauthorized attempt to update item' ),
        ( '6107', 'unauthorized attempt to delete item' ),
        ( '6113', 'unauthorized attempt to update reminder' ),
        ( '6117', 'unauthorized attempt to delete reminder' ),
        ( '6126', 'unauthorized attempt to list registration codes'),

    -- 9000+ : Database/Developer errors

        ( '9020', 'error adding account' ),
        ( '9023', 'error updating account' ),
        ( '9026', 'error getting account(s)' ),
        ( '9030', 'error adding member' ),
        ( '9033', 'error updating member' ),
        ( '9036', 'error getting member(s)' ),
        ( '9043', 'error updating password' ),
        ( '9053', 'error updating session'  ),
        ( '9070', 'error adding folder' ),
        ( '9073', 'error updating folder' ),
        ( '9077', 'error deleting folder' ),
        ( '9080', 'error adding file' ),
        ( '9083', 'error updating file' ),
        ( '9086', 'error getting file(s)' ),
        ( '9087', 'error deleting file' ),
        ( '9100', 'error adding item' ),
        ( '9103', 'error updating item' ),
        ( '9106', 'error getting item(s)' ),
        ( '9107', 'error deleting item' ),
        ( '9110', 'error adding reminder' ),
        ( '9113', 'error updating reminder' ),
        ( '9117', 'error deleting reminder' ),
        ( '9120', 'error adding registration code'),
        ( '9123', 'error updating registration code'),
        
        ( '9999', 'ASSERT failure');

    select count(*) into nrows from ref_eventcodes;
    return 'EventCodes reference table loaded: '||nrows||' rows.';
end;
$$ language plpgsql;
