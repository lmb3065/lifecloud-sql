
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
    raise notice 'Adding Files'

    

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
