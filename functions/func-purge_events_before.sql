
-- ======================================================================
-- function purge_events_before
-------------------------------------------------------------------------
--     cutoff timestamp : time of earliest event to preserve 
-- ======================================================================   
    
create or replace function purge_events_before( _dt timestamp )
    returns null as $$
begin
    delete from events where dt < _dt;
end;
$$ language plpgsql;
    

