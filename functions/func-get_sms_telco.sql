
-- 2014-08-24 dbrown: created

create or replace function get_sms_telco
(
   _telco text

) returns table (suffix text) as $$

declare

    _result text;

begin

    return query
        SELECT st.suffix as suffix
        FROM sms_telcos st 
        WHERE st.telco = _telco;

end;
$$ language plpgsql;


select * from get_sms_telco('ATT');
