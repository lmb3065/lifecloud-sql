
-- role-delphi.pgsql
-- 2013-11-01 dbrown : changed folders_fid_seq to folders_uid_seq

grant all on
    accounts, accounts_cid_seq,
    events,   events_eid_seq,
    files,    files_uid_seq,
    folders,  folders_uid_seq,
    members,  members_mid_seq,
    sessions, sessions_sid_seq,
    profilepics
to delphi;

grant select on
    pgpkeys,
    ref_defaultfolders,
    ref_eventcodes,
    ref_apps
to delphi;

