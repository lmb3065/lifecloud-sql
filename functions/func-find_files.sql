-- =============================================================================
-- function find_files()
-- -----------------------------------------------------------------------------

create or replace function find_files(

   _target_mid int default null,
   _namesearchstr text default null,
   _descsearchstr text default null,
   _pagesize int default null,
   _page int default 0

) returns table ( filerec file_t ) as $$
declare
    _nrows int;
    _npages int;

begin

    if (_namesearchstr is null) and (_descsearchstr is null) then
        return;
    end if;

    create temporary table files_out on commit drop as
        select f.uid, f.folder_uid, f.mid, f.item_uid, f.created,
        fdecrypt(f.x_name) as filename,
        fdecrypt(f.x_desc) as description,
        f.content_type, f.isprofile, f.category,
        fdecrypt(f.x_form_data) as form_data,
        f.modified_by, f.updated, 
        fdecrypt(m.x_fname) as ownerfname, 
        fdecrypt(m.x_lname) as ownerlname
    from files f join members m on (f.mid = m.mid)
    where ( _target_mid is null or _target_mid = m.mid)
      and (_namesearchstr is null or (fdecrypt(f.x_name) ilike '%' || _namesearchstr || '%'))
      and (_descsearchstr is null or (fdecrypt(f.x_desc)  ilike '%' || _descsearchstr || '%'));


    select count(*) into _nrows from files_out;
    if (coalesce(_pagesize, 0) > 0) then
        _npages := _nrows / _pagesize;
        if (_nrows % _pagesize > 0) then _npages := _npages + 1; end if;
    else -- No paging, everything goes on 1 page
        _pagesize := null;
        _npages := 1;
    end if;

    -- Output final results

    return query
        select fo.uid, fo.folder_uid, fo.mid, fo.item_uid, fo.created,
            fo.filename, fo.description, fo.content_type, fo.isprofile,
            fo.category, fo.form_data, fo.modified_by, fo.updated,
            fo.ownerfname, fo.ownerlname,
            _nrows, _npages
        from files_out fo
        order by isprofile desc, ownerfname asc, updated desc, created desc
        offset (_page * _pagesize) limit _pagesize;


end
$$ language plpgsql;
