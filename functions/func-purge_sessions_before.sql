    
-- ======================================================================
-- function purge_sessions_before
-------------------------------------------------------------------------
--     cutoff timestamp : time of earliest session to preserve 
-- ======================================================================
  
create or replace function purge_sessions_before( _dt timestamp )
    returns null as $$
begin
    delete from sessions where dtlogin < _dt;
end;
$$ language plpgsql;

