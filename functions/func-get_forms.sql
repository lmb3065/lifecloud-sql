-- ===========================================================================
--  function get_forms
-- ---------------------------------------------------------------------------
-- MID may not be null, form_uid overrides category.
--  get_forms( form_uid, mid, NUL ) -> returns 1 form
--  get_forms( NUL, mid, NUL )      -> returns all forms for MID
--  get_forms( NUL, mid, category ) -> returns all forms for MID+Category
-- ---------------------------------------------------------------------------
--  2013-11-23 dbrown: created
--  2013-12-12 dbrown: added item_uid
--  2013-12-20 dbrown: added updated
--  2013-12-24 dbrown: added form_data, changed isForm to isProfile
--  2014-09-28 dbrown: added ownerfname, ownerlname
-- ---------------------------------------------------------------------------

create or replace function get_forms (

    _formuid  int,
    _mid      int,
    _categuid int,

    _pagesize int default null,
    _page     int default 0

) returns table ( formrec file_t ) as $$

declare
    _nrows int;
    _npages int;

begin

    if (_mid is null) then return; end if;
    if (_formuid is not null) then _categuid := null; end if;

    -- Get initial results
    create temporary table forms_out on commit drop as
        select f.uid, f.folder_uid, f.mid, f.item_uid, f.created,
            fdecrypt(f.x_name) as filename,
            fdecrypt(f.x_desc) as description,
            f.content_type, f.isprofile, f.category,
            fdecrypt(f.x_form_data) as form_data,
            f.modified_by, f.updated, 
            fdecrypt(m.x_fname) as ownerfname,
            fdecrypt(m.x_lname) as ownerlname
        from files f join members m on (f.mid = m.mid)
        where f.mid = _mid
          and (_formuid is null or _formuid = f.uid)
          and (_categuid is null or _categuid = f.category);


    -- Calculate output paging
    select count(*) into _nrows from forms_out;
    if (coalesce(_pagesize, 0) > 0) then
        _npages := _nrows / _pagesize;
        if (_nrows % _pagesize > 0) then _npages := _npages + 1; end if;
    else -- No paging, everything goes on 1 page
        _pagesize := null;
        _npages := 1;
    end if;


    -- Output results
    return query
        select fo.uid, fo.folder_uid, fo.mid, fo.item_uid, fo.created,
            fo.filename, fo.description, fo.content_type, fo.isprofile,
            fo.category, fo.form_data, fo.modified_by, fo.updated,
            fo.ownerfname, fo.ownerlname,
            _nrows, _npages
        from forms_out fo
        order by ownerfname asc, updated desc, created desc
        limit _pagesize offset (_page * _pagesize);

end
$$ language plpgsql;
