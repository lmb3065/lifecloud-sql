    
-- ======================================================================
-- function purge_sessions_before
-------------------------------------------------------------------------
--     cutoff timestamp : time of earliest session to preserve 
-- ======================================================================
-- 2013-11-15 dbrown: Purge counts added (needed by update_session)
  
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

