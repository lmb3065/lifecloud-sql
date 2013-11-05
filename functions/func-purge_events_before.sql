
-- ======================================================================
-- function purge_events_before
-------------------------------------------------------------------------
--     cutoff timestamp : time of earliest event to preserve 
-- returns number of rows purged.  (0 is not necessarily an error)
-- ======================================================================   
    
create or replace function purge_events_before( _dt timestamp )
    returns int as $$

declare
    nrows int;
begin
    delete from events where dt < _dt;
    get diagnostics nrows = row_count;
    return nrows;
end;
$$ language plpgsql;
    

