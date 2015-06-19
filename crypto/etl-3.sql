
 -- ETL PART 3 : INSERTION


    alter table files       drop constraint files_mid_fkey;
    alter table folders     drop constraint folders_mid_fkey;
    alter table items       drop constraint items_mid_fkey;
    alter table member_apps drop constraint member_apps_mid_fkey;
    alter table profilepics drop constraint profilepics_mid_fkey;
    alter table reminders   drop constraint reminders_mid_fkey;
    alter table sessions    drop constraint sessions_mid_fkey;    
    alter table files       drop constraint files_folder_uid_fkey;
    alter table items       drop constraint items_folder_uid_fkey;

    truncate table members;
    truncate table folders;
    truncate table files;
    truncate table items;
    truncate table ipn;

create or replace function etl3() returns int as $$
declare

    folders_c cursor for select * from _ct_Folders;
    items_c   cursor for select * from _ct_Items;
    files_c   cursor for select * from _ct_Files;
    members_c cursor for select * from _ct_Members;

begin

    -----------------------------------------------------------------------------
    raise notice 'Adding Folders';

    truncate table Folders;
    for r in folders_c loop
        insert into Folders (
            uid, mid, cid, x_name, x_desc,
            app_uid, created, updated )
        values (
            r.uid, r.mid, r.cid, fencrypt(r.name), fencrypt(r.desc),
            r.app_uid, r.created, r.updated );
    end loop;

    -----------------------------------------------------------------------------
    raise notice 'Adding Items';

    truncate table Items;
    for r in items_c loop
        insert into Items (
            uid, mid, cid, 
            folder_uid, app_uid, itemtype,
            x_name, x_desc, 
            created, updated, modified_by )
        values (
            r.uid, r.mid, r.cid, 
            r.folder_uid, r.app_uid, r.itemtype,
            fencrypt(r.name), fencrypt(r.desc), 
            r.created, r.updated, r.modified_by );
    end loop;

    -----------------------------------------------------------------------------
    raise notice 'Adding Files';

    truncate table Files;
    for r in files_c loop
        insert into Files (
            uid, folder_uid, mid, item_uid,
            x_name, x_desc,
            content_type, isprofile, category,
            x_form_data, modified_by, created, updated )
        values (
            r.uid, r.folder_uid, r.mid, r.item_uid,
            fencrypt(r.name), fencrypt(r.desc),
            r.content_type, r.isprofile, r.category,
            fencrypt(r.form_data), r.modified_by, r.created, r.updated );
    end loop;

    -----------------------------------------------------------------------------
    raise notice 'Adding Members';

    truncate table Members;
    for r in members_c loop
        insert into Members (
            mid, cid, h_passwd, x_userid, x_email,
            h_profilepic,
            x_fname, x_mi, x_lname,
            x_address1, x_address2, x_city,
            x_state, x_postalcode, x_country,
            x_phone,
            alerttype, x_alertphone, x_alertemail,
            status, pwstatus, userlevel, tooltips, 
            isadmin, logincount, created, updated )
        values (
            r.mid, r.cid, r.h_passwd, fencrypt(r.userid), fencrypt(r.email),
            r.h_profilepic,
            fencrypt(r.fname), fencrypt(r.mi), fencrypt(r.lname),
            fencrypt(r.address1), fencrypt(r.address2), fencrypt(r.city),
            fencrypt(r.state), fencrypt(r.postalcode), fencrypt(r.country),
            fencrypt(r.phone),
            r.alerttype, fencrypt(r.alertphone), fencrypt(r.alertemail),
            r.status, r.pwstatus, r.userlevel, r.tooltips,
            r.isadmin, r.logincount, r.created, r.updated );
    end loop;


    return 0;
end;
$$ language plpgsql;


/* 
    ETL_21 Encrypt/Insert Members
    ETL_22 Encrypt/Insert Folders
    ETL_23 Encrypt/Insert Files
    ETL_24 Encrypt/Insert Items
    ETL_25 Encrypt/Insert IPN
*/
