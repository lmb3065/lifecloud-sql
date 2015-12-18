-- --------------------------------------------------------------------------
-- mailusers
-- --------------------------------------------------------------------------
-- This table stores usernames and passwords for digitallifecloud.com email
-- users.
--
-- 2015-12-18 lbrown : Script created
-- --------------------------------------------------------------------------
create table mailusers
(
    x_un  bytea not null,
    x_pw  bytea not null
);
alter table mailusers owner to pgsql;

