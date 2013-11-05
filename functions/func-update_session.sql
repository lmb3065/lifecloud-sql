
/*  =============================================================================
     update_session                                                     function
    -----------------------------------------------------------------------------     
        _tag varchar(32)    : client-supplied unique? string to tag this session
      _mid int            : member.mid of the client in this session
      _ipaddr varchar(15) : ip address of client connection
      _action char        : "I" login or "O" logout
    -----------------------------------------------------------------------------    
     2009-08-26 lbrown : original (T-SQL)
     2013-08-29 dbrown : ported to PL/pgSQL
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
    err_cid int = null;
    
begin

    cutoff := current_date - interval '1 year';
    n_purg := purge_sessions_before( cutoff );

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
    
        select cid into err_cid from members where mid = _mid;
        perform log_event( err_cid, _mid, '9005', "unknown action '" || char || "'");
        select (-1, -1, -1) into n_ins, n_clos1, n_purg;
        
    end if;


    -- purge any unrelated, unclosed sessions for this user     
    
    update Sessions set dtlogout = clock_timestamp()
        where mid = _mid 
          and tag <> _tag
          and dtlogout is null;
    get diagnostics n_clos2 = row_count;
    return query select n_ins, n_clos1 + n_clos2, n_purg;
    
end;

$$ language plpgsql;

