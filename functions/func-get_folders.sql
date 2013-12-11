
-- ================================================================================
--  get_folders()
-- --------------------------------------------------------------------------------
-- 2013-10-30 dbrown: Completely rewritten to incorporate get_folder and folder_t
-- 2013-11-01 dbrown: Coded to new folders.uid but still outputs it as "fid"
-- 2013-11-12 dbrown: Raises warning, rets NULL if neither search term provided
-- 2013-12-11 dbrown: replaced itemtype with app_uid
-- --------------------------------------------------------------------------------

create or replace function get_folders(

    _folder_uid int default null,
    _mid        int default null,
    _pagesize   int default null,
    _page       int default 0

) returns table (

    fid         int,
    mid         int,
    cid         int,
    memberfname text,
    memberlname text,
    foldername  text,
    description text,
    app_uid     int,
    created     timestamp,
    updated     timestamp,
    nrows       int,
    npages      int
)

as $$

declare
    _cid int;
    _owner_mid int;
    _nrows int;
    _npages int;

begin

    if (_folder_uid is not null) then -- Search by folderID

        create temporary table folders_out on commit drop as
            select f.uid as fid, f.mid, m.cid,
                fdecrypt(m.x_fname) as memberfname,
                fdecrypt(m.x_lname) as memberlname,
                fdecrypt(f.x_name) as foldername,
                fdecrypt(f.x_desc) as description,
                f.app_uid, f.created, f.updated
            from Folders f join Members m on (f.mid = m.mid)
            where f.uid = _folder_uid;

    elsif (_mid is not null) then -- Search by MemberID

        -- Is this member an account owner?
        select m.cid into _cid from Members m where m.mid = _mid;
        select a.owner_mid into _owner_mid from Accounts a where a.cid = _cid;

        if (_mid = _owner_mid) then
            -- Yes: retrieve folders from all members under this account
            create temporary table folders_out on commit drop as
                select f.uid as fid, f.mid, m.cid,
                    fdecrypt(m.x_fname) as memberfname,
                    fdecrypt(m.x_lname) as memberlname,
                    fdecrypt(f.x_name) as foldername,
                    fdecrypt(f.x_desc) as description,
                    f.app_uid, f.created, f.updated
                from Folders f join Members M on (f.mid = m.mid)
                where f.cid = _cid;

        else -- No: retrieve folders from only this member
            create temporary table folders_out on commit drop as
                select f.uid as fid, f.mid, m.cid,
                    fdecrypt(m.x_fname) as memberfname,
                    fdecrypt(m.x_lname) as memberlname,
                    fdecrypt(f.x_name) as foldername,
                    fdecrypt(f.x_desc) as description,
                    f.app_uid, f.created, f.updated
                from Folders f join Members m on (f.mid = m.mid)
                where f.mid = _mid;

        end if;
    else
        raise warning 'get_folders(): no search criteria supplied';
        return;
    end if;


    -- Pagination
    select count(*) into _nrows from folders_out;
    if (coalesce(_pagesize, 0) = 0) then -- No paging = 1 page
        _pagesize := null;
        _npages   := 1;
    else -- Calculate actual # of pages
        _npages   := _nrows / _pagesize;
        if (_nrows % _pagesize > 0) then _npages := _npages + 1; end if;
    end if;


    -- Output results
    return query
        select o.*, _nrows, _npages
        from folders_out o
            order by memberlname asc, memberfname asc, foldername asc
            limit _pagesize offset (_page * _pagesize);

    return;

end
$$ language plpgsql;

