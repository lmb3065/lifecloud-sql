
-- -----------------------------------------------------------------------------
-- 1.1. Decrypt/Extract Members
-- -----------------------------------------------------------------------------

create or replace function ETL_11() returns integer as $$
begin

    CREATE TABLE _ct_Members
    (
        mid         serial     primary key,
        cid         int        references Accounts,
        h_passwd    text       not null,
        userid      text       not null,
        email       text       not null,
        h_profilepic text,
        fname       text       not null,
        mi          text,
        lname       text       not null,
        address1    text,
        address2    text,
        city        text,
        state       text,
        postalcode  text,
        country     text,
        phone       text,
        alerttype   int,
        alertphone  text,
        alertemail  text,
        status      int         not null   default 0,
        pwstatus    int         not null   default 0,
        userlevel   int         not null   default 4,
        tooltips    int         not null   default 1,
        isadmin     int         not null   default 0,
        logincount  int         not null   default 0,
        created     timestamp   not null   default now(),
        updated     timestamp   not null   default now()
    );

    declare cur_Members CURSOR for SELECT
        mid,
        cid,
        h_passwd,
        fdecrypt(x_userid)      as userid,
        fdecrypt(x_email)       as email,
        h_profilepic,
        fdecrypt(x_fname)       as fname,
        fdecrypt(x_mi)          as mi,
        fdecrypt(x_lname)       as lname,
        fdecrypt(x_address1)    as address1,
        fdecrypt(x_address2)    as address2,
        fdecrypt(x_city)        as city,
        fdecrypt(x_state)       as state,
        fdecrypt(x_postalcode)  as postalcode,
        fdecrypt(x_country)     as country,
        fdecrypt(x_phone)       as phone,
        alerttype,
        fdecrypt(x_alertphone)  as alertphone,
        fdecrypt(x_alertemail)  as alertemail,
        status,
        pwstatus,
        userlevel,
        tooltips,
        isadmin,
        logincount,
        created,
        updated
    from Members;
    begin
        for r in cur_Members loop
            insert into _ct_Members
            (
                mid,
                cid,
                h_passwd,
                userid,
                email,
                h_profilepic,
                fname,
                mi,
                lname,
                address1,
                address2,
                city,
                state,
                postalcode,
                country,
                phone,
                alerttype,
                alertphone,
                alertemail,
                status,
                pwstatus,
                userlevel,
                tooltips,
                isadmin,
                logincount,
                created,
                updated
            ) values (
                r.mid,
                r.cid,
                r.h_passwd,
                r.userid,
                r.email,
                r.h_profilepic,
                r.fname,
                r.mi,
                r.lname,
                r.address1,
                r.address2,
                r.city,
                r.state,
                r.postalcode,
                r.country,
                r.phone,
                r.alerttype,
                r.alertphone,
                r.alertemail,
                r.status,
                r.pwstatus,
                r.userlevel,
                r.tooltips,
                r.isadmin,
                r.logincount,
                r.created,
                r.updated
            );

        end loop;
    end;

    return query
        select count(*) from _ct_Members;
end;
$$ language plpgsql;
