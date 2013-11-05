
-- ======================================================================
-- fencrypt()
-- ======================================================================

create or replace function fencrypt(msg text) returns bytea as $$
declare
   psw text;
begin
   select keydata into psw from pgpkeys where keyname='public';
   return pgp_sym_encrypt(msg, psw);
end;
$$ language plpgsql;

----------------------------------------------------------------------

create or replace function fencrypt(msg text, psw text) returns bytea as $$
begin
    return pgp_sym_encrypt(msg, psw);
end;
$$ language plpgsql;


