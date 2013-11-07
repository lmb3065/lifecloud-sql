
-- ======================================================================
-- function log_event
-- ----------------------------------------------------------------------
-- dependencies: fencrypt, purge_events_before
-- ======================================================================
-- 2013-09-25 dbrown : added _mid
-- 2013-09-28 dbrown : added _target_cid, _target_mid
-- 2013-11-01 dbrown : _data field may now be omitted
-------------------------------------------------------------------------

create or replace function log_event(

    _cid int,   -- references Accounts.cid
    _mid int,   -- references Members.mid
    _code char(4),  -- references ref_EventCodes
    _data text      default '',    -- comments
    _targetcid int  default null,
    _targetmid int  default null
    
) returns void as $$

declare
    cutoff timestamp;
    
begin
    -- Get rid of old events
    cutoff := now() - interval '1 year';
    perform purge_events_before( cutoff );
    
    -- Insert new event
    insert into Events ( cid, mid, target_cid, target_mid, code, x_data ) 
        values ( _cid, _mid, _targetcid, _targetmid, _code, fencrypt(_data) );
    return;
    
end;
$$ language plpgsql;

