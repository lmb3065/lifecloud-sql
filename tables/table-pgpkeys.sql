
-- =============================================================================
-- PGP KEYS
-- =============================================================================

create table PGPKeys
(
    keydata text    not null,
    keyname varchar not null
);

alter table PGPKeys owner to pgsql;

insert into PGPKeys (keydata, keyname)
    values ('DEADBEEF','public');

    
