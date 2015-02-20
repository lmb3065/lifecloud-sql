
create or replace function get_pending_purchase
(
    _ip text
) returns table (

    ip_address text,
    email_address text,
    dt_added timestamp

) as $$

begin

    return query
    select pp.ip_address, pp.email_address, pp.dt_added
    from pending_purchases pp
    where pp.ip_address = _ip;

end
$$ language plpgsql;
