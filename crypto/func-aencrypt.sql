
-- aencrypt() : AES encrypt

create or replace function aencrypt(msg text) returns bytea as $$
    declare
        cipherkey bytea;
    begin
        select dearmor(keydata) into cipherkey from pgpkeys where keyname='a-pub';
        return pgp_pub_encrypt( msg, cipherkey, 'cipher-algo=aes256' );
    end;
$$ language plpgsql;
