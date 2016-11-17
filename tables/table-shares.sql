-- -----------------------------------------------------------------------------
--  SHARES                                                                 Table
-- -----------------------------------------------------------------------------
-- 2016-08-01 lbrown: created
-- -----------------------------------------------------------------------------

create table Shares
(
    file_id integer,
    shared_by integer,
    shared_with text,
    shared_on date,
    expires date,
    view_count integer,
    passcode text
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.shares
    OWNER to pgsql;

GRANT ALL ON TABLE shares TO pgsql;

GRANT ALL ON TABLE shares TO delphi;