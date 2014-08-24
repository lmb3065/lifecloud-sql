
-- 2014-08-24 dbrown: created

create or replace function get_sms_telco
(
    _telco text
)
returns text as $$
declare
  _cleantelco text;
  _result text;
begin

    _cleantelco := upper(_telco);
    _cleantelco := replace(_cleantelco, '-','');
    _cleantelco := replace(_cleantelco, '&','');
    _cleantelco := replace(_cleantelco, ' ','');

    select suffix into _result from sms_telcos where telco = _cleantelco;
    return _result;

end;
$$ language plpgsql;


