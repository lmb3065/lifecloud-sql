
create table sms_telcos
(
    telco   text   not null,
    suffix  text   not null
);

alter table sms_telcos owner to pgsql;
