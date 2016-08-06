
-- get_help_link()
-- 2016-08-06 dbrown : created

create or replace function get_help_link
(
    _code integer
) returns table (
    code     int,
    doc_link text,
    vid_link text
) as $$

begin

    return query
    select hl.code, hl.doc_link, hl.vid_link 
    from help_links hl
    where hl.code = _code;

end

$$ language plpgsql;
