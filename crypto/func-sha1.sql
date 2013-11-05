
-- func-sha1

CREATE OR REPLACE FUNCTION sha1(bytea) returns text AS $$
BEGIN
      RETURN encode(digest($1, 'sha1'), 'hex');
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION sha1(varchar) returns text AS $$
BEGIN
      RETURN sha1(cast($1 as bytea));
END;
$$ LANGUAGE PLPGSQL;
