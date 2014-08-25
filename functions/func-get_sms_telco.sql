
-- 2014-08-24 dbrown: created

create or replace function get_sms_telco
(
   _telco text

) returns text as $$

declare

    _result text;

begin

    SELECT suffix into _result
    FROM sms_telcos 
    WHERE telco = _telco;

    return _result;

end;
$$ language plpgsql;


select * from get_sms_telco('ATT');
