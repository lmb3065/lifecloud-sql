/* etl-2.sql 

 etl-2a. Insert new keys and passphrase into 'pgpkeys' table

*/

insert into pgpkeys (keyname, keydata) values ('a-pub','-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

mQMuBFU3wDURCADMvemY+/SHNIpGI3Zfr9jLJVMgYeSX63XkbkitQnmzyuC8q/mg
jmjM8BiiOiRIGZ9eb9xDenXrir8O3LXvyxmgDki5XUzHVOqv64qJzGY0P0XbyXXJ
4ysM5TLhsnW4bS5OEaDjzBLF0MB0MlRktqB99Au4iqv/5hzsJ90F+qcvgOOdc3vI
AT4Gq+ahkf16A3i6jGN++PeWgSK9wuvHMGioVyxCxtbcvBUwiHmMqGPE7UQXAK7W
y0pukLFmCnigcSCVPShI6zIa+tsJMM2CuVeY6L8oLw3a4tb5p0hfGzGoLHUo2KMU
+HiLXHHIza5mAIK45ueIIEzVbmE5Mt0/1TK3AQCeG89YNx6gthnfR61lDE4vYoLd
dUZn0bMPfNGdABZO3wf/XhW4RxazH9qNUCK7UxD401sMBaXoZCRsdi+6b/47ycQO
QtvZo0s0lz7q3/R5achHjjKSVQ1Ch6+G5L7osYcjoYxCqgzBvgZsgT1zNA0DWzDy
K4yBPv17+ypyd60GfhKHggizZPhTYFGq/onJYvwY4GsqgYbVTpweyD3mv+OJceBx
lvPRPgldGNcBeVy+TvaGrjE+r44w97tr6YiHurvYULDp3ewCAlGd6nbWexy1rG6v
6KdQuZ+szJJwlrTT2WUeSHqx4nImbbMVxJjfsSsQ+pdmyVTdR2g4y9dmD7SGb5n8
9PVk8MZCDuDerCkC1dp7T7QVSr2jlFtdKfCJtDZ7CAf/dggwng3tYhbA92JYkDoY
LCE1HqC4dE7zHViH9fvpRYbobspVtJXunxiJoRqAlOojxKV10TsiTKrZmIvQFwiP
y6gs06ydm1Kb7xTakdOCD0G+9aJlD5Fx36lE8ih1hDNpTxQEEFarbFqV6snOemxc
Jv9HgxtMLySfDAa8qXN/6i+qww6/baUCBd7V5WEBkR7T/H6whPpU/Vlg/7CwpRMp
HIxtoYHIy2FIjAa5JXz4dL/5OJC2b5Jgyh3iH+RtKxiDTLJekwShEafGkNwFu8oj
//WK7FsC6Y1+Fz6zyzJU9Bfawi+XDUHpFnQs4KbUJ1b4t9UhIoyGKW2985jsrG98
F7QuRGlnaXRhbCBMaWZlQ2xvdWQgPGFkbWluQGRpZ2l0YWxsaWZlY2xvdWQuY29t
Poh6BBMRCAAiBQJVN8A1AhsDBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRD+
PP8KAsvYA+rkAP4qSQZsOjHD0rdEAgzaajqQE5fIgDryUhJgH0Oakep7HwD/fFfS
9epZXZGPhbk+XMJ2gvlW+Oo0TsiYmr+4xcZv68y5Ag0EVTfANRAIAMjZlm+pAoOu
hiS75mJlfdTrx73LLpFddGLRDh8ls0x1kJt4/ZSwGt+MImsOKEtBCQIhyRkFpVwN
43MfemMwBL7EpAA8jTQMdXyYkW364Z/0mNrc2IER6MMCBZHygsA6cZvTGi8mIqWW
pWoMjyaMQwfQMMqv5lyJKaw6rPwC6a6WIgslrv0DJP/N5QLKfRIlBtMWC+nEeJju
rxlMIzYSA3Lvmm9GW5ZDJMYumK9AkEXNOSifQFcL8UBk/j9D9AQGnVDx12bendJo
8RQ2YOAVwZ/wfFMLU3TszlHFKX66skCqdzs8xSQtLXU9vmRuqJY7dY20PSLGH84w
SaXLIK9+IVcAAwUIAI+C0BqXow4JshfmlKntuFDy5cQvSHf2C9oXEqhr4xKjgTnr
DWKyTjumtDgbQhlNh0nvhAplm1We/ZxxMlvIC34Q3r6OCbLA1dFEIExXWvYGG1ZL
qA2NnHpsYSIqdAVi5ZKUDHxDEArw7YuBaUsfKjTShODs2jJabcPrSF/oP5HD3UWu
GfIRsSqfL03n/kMZYkrvUAt+ONWC5BjtCLsQTKSkv1A03mEZ8yZ8+e27y33eC3I5
Qg6ma9laN/x1kyhtmSoYipKhw592pTbrC84vGb1ZlToMy5Tjki4SMXXYYMe0h3kU
mMRo/dka1rsZJSkV25rur9xzoRrzXXA6EG4qxqeIYQQYEQgACQUCVTfANQIbDAAK
CRD+PP8KAsvYA2guAP9Ul8lzrXygytI6q5D8F2B9CAkLS89kbl4OZPePbxINGwD/
ZmjZgBJ+DO+sIY1zjwSt/Y/sp6azIx/UVLoUuMa2o+E=
=mFwp
-----END PGP PUBLIC KEY BLOCK-----');

insert into pgpkeys (keyname, keydata) values ('a-sec','-----BEGIN PGP PRIVATE KEY BLOCK-----
Version: GnuPG v1

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
gA==
=8YRq
-----END PGP PRIVATE KEY BLOCK-----');

insert into pgpkeys (keyname, keydata) values ('kp','H4sBYFvwWpEBrx6gjbsoDZqKGUQjdP');

/*

 etl-2b. Update fencrypt and fdecrypt functions

*/


-- fencrypt() : AES-256 encrypt

create or replace function fencrypt(msg text) returns bytea as $$
    declare
        cipherkey bytea;
    begin
        select dearmor(keydata) into cipherkey from pgpkeys where keyname='a-pub';
        return pgp_pub_encrypt( msg, cipherkey, 'cipher-algo=aes256' );
    end;
$$ language plpgsql;


-- fdecrypt() : AES-256 decrypt

create or replace function fdecrypt(msg bytea) returns text as $$
    declare
        cipherkey bytea;
        keypass text;
    begin
        select dearmor(keydata) into cipherkey from pgpkeys where keyname='a-sec';
        select keydata into keypass from pgpkeys where keyname='kp';
        return pgp_pub_decrypt( msg, cipherkey, keypass );
    end;
$$ language plpgsql;

