
-- adecrypt() : AES decrypt

create or replace function adecrypt(msg bytea) returns text as $$
    declare
        cipherkey bytea;
        keypass text;
    begin
        select dearmor(keydata) into cipherkey from pgpkeys where keyname='a-sec';
        select keydata into keypass from pgpkeys where keyname='kp';
        return pgp_pub_decrypt( msg, cipherkey, keypass );
    end;
$$ language plpgsql;
