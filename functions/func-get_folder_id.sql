
-- get ID of folder(s) with specific name for a specific user
-- 2016-10-26 dbrown : Created

create or replace function get_folder_id (

    _mid int,
    _folder_name text

) returns table(folder_id int) as $$
begin

    return query
        select uid
        from folders f
        where f.mid = _mid
            and fdecrypt(f.x_name) = _folder_name;

end
$$ language plpgsql;
