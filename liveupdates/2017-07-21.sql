
-- 2017-07-21 dbrown : Open Subscriptions (default NULL expiry)

alter table Accounts
    alter column expires
        set default null;
