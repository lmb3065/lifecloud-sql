
-- role-delphi.pgsql
-- 2013-11-01 dbrown : changed folders_fid_seq to folders_uid_seq
-- 2013-12-20 dbrown : added items, items_uid_seq
-- 2014-05-25 dbrown : added reminders, reminders_uid_seq
-- 2016-04-22 dbrown : added delphi_contacts

grant all on
    accounts,    accounts_cid_seq,
    delphi_contacts,
    events,      events_eid_seq,
    files,       files_uid_seq,
    folders,     folders_uid_seq,
    items,       items_uid_seq,
    help_links,
    member_apps,
    reg_codes,
    members,     members_mid_seq,
    profilepics, profilepics_ppid_seq,
    reminders,   reminders_uid_seq,
    sessions,    sessions_sid_seq,
    sms_telcos
to delphi;

grant select on
    pgpkeys,
    ref_apps,           ref_apps_uid_seq,
    ref_categories,     ref_categories_uid_seq,
    ref_defaultfolders,
    ref_eventcodes,
    ref_forms,
    ref_itemtypes,
    ref_retvals
to delphi;
