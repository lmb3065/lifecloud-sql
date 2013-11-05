
-- ==============================================================================================
--  ACCOUNTS                                                                               Table
-- ----------------------------------------------------------------------------------------------
--  An Account is a Group of Members
-- ----------------------------------------------------------------------------------------------
-- status: 
--   0 = Normal
--   9 = Temporary/Incomplete Signup Account
-- ----------------------------------------------------------------------------------------------
-- 2013-09-25 dbrown Encrypted fields moved to Members; owner_mid added; removed autorenew
-- 2013-10-02 dbrown added "referrer"
-- ----------------------------------------------------------------------------------------------

create table Accounts
(
    cid           serial      not null  primary key, -- Customer ID
    owner_mid     integer     not null, -- references Members(MID),
    status        int         not null,
    quota         bigint      not null,
    referrer      varchar(64),
    created       timestamp   not null  default now(),
    updated       timestamp   not null  default now(),
    expires       timestamp   not null  default current_date + interval '1 year'
);
alter table Accounts owner to pgsql;

