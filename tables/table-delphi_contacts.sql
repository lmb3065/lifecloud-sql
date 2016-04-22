-- --------------------------------------------------------------------------
-- delphi_contacts
-- --------------------------------------------------------------------------
-- This table stores names and email addresses for users requesting free
-- PDFs from BioBinders.com and other Delphi web sites
--
-- 2016-04-21 lbrown : Script created
-- --------------------------------------------------------------------------
create table delphi_contacts
(
    x_email  bytea not null,
    x_fname  bytea not null,
    x_lname  bytea not null,
    dt_added timestamp default clock_timestamp()
);
alter table delphi_contacts owner to pgsql;