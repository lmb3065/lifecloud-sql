
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
-----------------------------------------------------------------------------

create or replace function admin_create_eventcodes()  returns int as $$

begin
    truncate table ref_eventcodes;
    
    insert into ref_eventcodes(Code, Description) values ('0000', 'user logged in');
    insert into ref_eventcodes(Code, Description) values ('0001', 'user logged out');
    insert into ref_eventcodes(Code, Description) values ('0002', 'invalid login attempt');
    insert into ref_eventcodes(Code, Description) values ('0003', 'auto log-in');
    insert into ref_eventcodes(Code, Description) values ('0004', 'userid/password e-mailed');
    insert into ref_eventcodes(Code, Description) values ('0005', 'imaging options notified');
    insert into ref_eventcodes(Code, Description) values ('0006', 'unauthorized page attempt');
    insert into ref_eventcodes(Code, Description) values ('0007', 'auto log-out');
    
    insert into ref_eventcodes(Code, Description) values ('0010', 'account added by admin');
    insert into ref_eventcodes(Code, Description) values ('0011', 'account deleted by admin');
    insert into ref_eventcodes(Code, Description) values ('0012','new account registration');
    insert into ref_eventcodes(Code, Description) values ('0013','new member added');
    insert into ref_eventcodes(Code, Description) values ('0014','member deleted');
    insert into ref_eventcodes(Code, Description) values ('0015','account updated');
    insert into ref_eventcodes(Code, Description) values ('0016','member updated');
    insert into ref_eventcodes(Code, Description) values ('0017','member password reset');
    
    insert into ref_eventcodes(Code, Description) values ('0020','folder added'); 
    insert into ref_eventcodes(Code, Description) values ('0021','folder updated');
    insert into ref_eventcodes(Code, Description) values ('0022','folder deleted');
    insert into ref_eventcodes(Code, Description) values ('0023','folder purged');
    insert into ref_eventcodes(Code, Description) values ('0024','item added');
    insert into ref_eventcodes(Code, Description) values ('0025','item updated');
    insert into ref_eventcodes(Code, Description) values ('0026','item deleted');
    insert into ref_eventcodes(Code, Description) values ('0027','item purged');
    insert into ref_eventcodes(Code, Description) values ('0028','image uploaded');
    insert into ref_eventcodes(Code, Description) values ('0029','image deleted');
    
    insert into ref_eventcodes(Code, Description) values ('0030','user updated password');
    insert into ref_eventcodes(Code, Description) values ('0031','owner updated password');
    insert into ref_eventcodes(Code, Description) values ('0032','admin updated password');
    
    insert into ref_eventcodes(Code, Description) values ('0040','payment recorded');
    insert into ref_eventcodes(Code, Description) values ('0041','payment declined');
    insert into ref_eventcodes(Code, Description) values ('0042','IPN recevied');
    insert into ref_eventcodes(Code, Description) values ('0043','promotion code added');
    insert into ref_eventcodes(Code, Description) values ('0044','promotion code updated');
    insert into ref_eventcodes(Code, Description) values ('0045','promotion code deleted');

    -- error codes are OVER 9000
    insert into ref_eventcodes(Code, Description) values ('9000','failed login attempt');
    insert into ref_eventcodes(Code, Description) values ('9001','error adding account');
    insert into ref_eventcodes(Code, Description) values ('9002','error updating account');
    insert into ref_eventcodes(Code, Description) values ('9003','error adding member');
    insert into ref_eventcodes(Code, Description) values ('9004','error updating member');
    insert into ref_eventcodes(Code, Description) values ('9005','error updating session');  
    insert into ref_eventcodes(Code, Description) values ('9006','error updating password');  
    insert into ref_eventcodes(Code, Description) values ('9011','reserved');
    insert into ref_eventcodes(Code, Description) values ('9012','IPN update error');
    insert into ref_eventcodes(Code, Description) values ('9013','i/o notification error');
    insert into ref_eventcodes(Code, Description) values ('9014','error generating password');
    insert into ref_eventcodes(Code, Description) values ('9015','mail error on lost password');
    insert into ref_eventcodes(Code, Description) values ('9016','error adding promocode');
    insert into ref_eventcodes(Code, Description) values ('9017','error updating promocode');
    insert into ref_eventcodes(Code, Description) values ('9020','error inserting folder');
    insert into ref_eventcodes(Code, Description) values ('9021','error updating folder');
    insert into ref_eventcodes(Code, Description) values ('9022','error marking folder deleted');
    insert into ref_eventcodes(Code, Description) values ('9023','error purging folder');
    insert into ref_eventcodes(Code, Description) values ('9024','error adding file');
    insert into ref_eventcodes(Code, Description) values ('9025','error updating file');
    insert into ref_eventcodes(Code, Description) values ('9026','error deleting file');
    insert into ref_eventcodes(Code, Description) values ('9040','error uploading image');
    insert into ref_eventcodes(Code, Description) values ('9041','error adding image');
    insert into ref_eventcodes(Code, Description) values ('9999','ASSERT failure');

    return 1;
end;
$$ language plpgsql;



