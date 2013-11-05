
-- ======================================================================
-- fdecrypt()
-- ======================================================================

create or replace function fdecrypt(data bytea) returns text as $$
declare
   psw text;
begin
   select keydata into psw from pgpkeys where keyname='public';
   return pgp_sym_decrypt(data, psw);
end;
$$ language plpgsql;

----------------------------------------------------------------------

create or replace function fdecrypt(data bytea, psw text) returns text as $$
begin
    return pgp_symdecrypt(data, psw);
end;
$$ language plpgsql;


