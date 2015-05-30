
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

/* 
    ETL_21 Encrypt/Insert Members
    ETL_22 Encrypt/Insert Folders
    ETL_23 Encrypt/Insert Files
    ETL_24 Encrypt/Insert Items
    ETL_25 Encrypt/Insert IPN
*/