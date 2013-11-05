    
-- ======================================================================
-- function purge_sessions_before
-------------------------------------------------------------------------
--     cutoff timestamp : time of earliest session to preserve 
-- returns number of rows purged.  (0 is not necessarily an error)
-- ======================================================================
  
create or replace function purge_sessions_before( _dt timestamp )
    returns int as $$
declare
    nrows int;
begin
    delete from sessions where dtlogin < _dt;
    get diagnostics nrows = row_count;
    return nrows;
end;
$$ language plpgsql;

