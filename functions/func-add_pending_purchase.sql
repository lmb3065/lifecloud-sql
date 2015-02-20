
create or replace function add_pending_purchase
(
    _ip text,
    _email text,
    _dt timestamp
) returns int as $$

declare
    EVENT_OK_UPDATED_PP constant varchar = '1133';    

begin

    delete from pending_purchases pp
        where pp.ip_address = _ip;

    if found then
        perform log_event( null, null, EVENT_OK_UPDATED_PP, _ip || ' <' || _email || '>');
    end if;

    insert into pending_purchases
        (ip_address, email_address, dt_added)
    values ( _ip, _email, _dt );

    return 1;

end 
$$ language plpgsql;
