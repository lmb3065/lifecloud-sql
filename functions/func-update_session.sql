
/*  =============================================================================
     update_session                                                     function
    -----------------------------------------------------------------------------     
      _tag varchar(32)    : client-supplied unique? string to tag this session
      _mid int            : member.mid of the client in this session
      _ipaddr varchar(15) : ip address of client connection
      _action char        : "I" log-In or "O" log-Out
    -----------------------------------------------------------------------------    
     2009-08-26 lbrown : original (T-SQL)
     2013-08-29 dbrown : ported to PL/pgSQL
     2013-11-01 dbrown : eventcodes revision
     2014-10-09 dbrown : fix eventcode 9501 -> 9053 'dev err updating session'
    ============================================================================= */

create or replace function update_session(

    _tag    varchar(32),
    _mid    int,
    _ipaddr varchar(15),
    _action char = null
    
) returns table( inserted int, closed int, purged int ) as $$

declare
    cutoff timestamp;
    nrows int;
    
    n_ins int = 0;
    n_clos1 int = 0;
    n_clos2 int = 0;
    n_purg int = 0;
    _cid int = null;
    
begin

    cutoff := current_date - interval '1 year';
    n_purg := purge_sessions_before( cutoff );
    select cid into _cid from members where mid = _mid;

    if lower(_action) = 'o' then -- o for logOut
    
        update sessions
            set dtlogout = clock_timestamp()
            where mid = _mid;
        get diagnostics n_clos1 = row_count;
                    
    elsif lower(_action) = 'i' then -- i for logIn
    
        -- has this session been recorded already?
        if exists( select sid from Sessions where tag = _tag ) then
            n_ins := -1;            
        else        
            insert into Sessions ( mid, tag, x_ipaddr )
            values ( _mid, _tag, fencrypt(_ipaddr) );
            n_ins := 1;           
        end if;
        
    else -- Unknown action code
    
        -- eventcode 9040 : error updating session
        perform log_event( _cid, _mid, '9053', "unknown action '" || char || "'");
        select (-1, -1, -1) into n_ins, n_clos1, n_purg;
        
    end if;


    -- close any unrelated sessions for this user     
    
    update Sessions set dtlogout = clock_timestamp()
        where mid = _mid 
          and tag <> _tag
          and dtlogout is null;
    get diagnostics n_clos2 = row_count;
    return query select n_ins, n_clos1 + n_clos2, n_purg;
    
end;

$$ language plpgsql;

