
-- function get_member_pics( cid )
-- 2016-10-22 dbrown : Created

create or replace function get_member_pics( arg_cid int )
returns table ( h_profilepic text, mid int, fname text ) as $$
begin

    return query
        select m.h_profilepic, m.mid, fdecrypt(m.x_fname)
        from members m
        where cid = arg_cid;

end
$$ language plpgsql;
