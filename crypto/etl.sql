
/* 
    ETL_11 Decrypt/Extract Members [DONE]
    ETL_12 Decrypt/Extract Folders
    ETL_13 Decrypt/Extract Files
    ETL_14 Decrypt/Extract Items
    ETL_15 Decrypt/Extract IPN
    ETL_21 Encrypt/Insert Members
    ETL_22 Encrypt/Insert Folders
    ETL_23 Encrypt/Insert Files
    ETL_24 Encrypt/Insert Items
    ETL_25 Encrypt/Insert IPN
*/

create or replace function ETL_ALL() returns integer as $$
begin

    raise notice '***Extracting Members';      perform ETL_11();
    raise notice '***Extracting Folders';      perform ETL_12();
    raise notice '***Extracting Files';        perform ETL_13();
    raise notice '***Extracting Items';        perform ETL_14();
    raise notice '***Extracting IPNs';         perform ETL_15();

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

    -- raise notice 'Inserting Members';     perform ETL_21();
    -- raise notice 'Inserting Folders';     perform ETL_22();
    -- raise notice 'Inserting Files';       perform ETL_23();
    -- raise notice 'Inserting Items';       perform ETL_24();
    -- raise notice 'Inserting IPNs';        perform ETL_25();
    raise notice '***Done';
    return 0;

end;
$$ language plpgsql;
