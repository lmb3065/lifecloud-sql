
create or replace function delete_pending_purchase
(
    _ip text
) returns int as $$

begin

    delete from pending_purchases pp
        where pp.ip_address = _ip;

    if found then return 1;
    else          return 0;
    end if;

end $$
language plpgsql;
