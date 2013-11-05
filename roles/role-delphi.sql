
-- role-delphi.pgsql

grant all on
    accounts, accounts_cid_seq,
    events,   events_eid_seq,
    files,    files_uid_seq,
    folders,  folders_fid_seq,
    members,  members_mid_seq,
    sessions, sessions_sid_seq,
    profilepics
to delphi;

grant select on
    pgpkeys,
    ref_defaultfolders,
    ref_eventcodes
to delphi;

