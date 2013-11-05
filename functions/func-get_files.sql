
-- -----------------------------------------------------------------------------
--  get_files()
-- -----------------------------------------------------------------------------
--  Retrieves row(s) from Files based on the first criteria provided.
--   _fileuid        : Simple index lookup for one file. 
--   _folderuid      : Retrieves all files in the specified folder.
--   _mid            : Retrieves all files owned by the specified member.
--   _pagesize _page : Standard pagination arguments
-- -----------------------------------------------------------------------------
--  if nrows is ...
--     > 0  OK
--       0  Given criteria doesn't match any files
--      -1  You didn't provide an argument by which to search
-- -----------------------------------------------------------------------------
-- 2013-10-29 dbrown: Created
-- 2013-10-30 dbrown: Added filename/description, simplified structure
-- -----------------------------------------------------------------------------

create or replace function get_files(

    _fileuid    int    default null, --  \
    _folderuid  int    default null, --   > Search Criteria
    _mid        int    default null, --  /
    _pagesize   int    default null, --  \  Pagination
    _page       int    default 0     --  /    Options
    
) returns table (

    uid         int, 
    fid         int, 
    mid         int, 
    created     timestamp, 
    filename    text,
    description text,
    nrows       int,
    npages      int
    
) as $$
    
declare
    _nrows int;
    _npages int;

begin

    -- Do our initial query into a temp table

    if (_fileuid is not null) then           -- Look up one file by UID
        create temporary table files_out on commit drop as
            select f.uid, f.fid, f.mid, f.created,
                    fdecrypt(f.x_name) as filename,
                    fdecrypt(f.x_desc) as description 
                from files f
                where f.uid = _fileuid;
        
    elsif (_folderuid is not null) then      -- Get all files in folder
        create temporary table files_out on commit drop as
            select f.uid, f.fid, f.mid, f.created,
                    fdecrypt(f.x_name) as filename,
                    fdecrypt(f.x_desc) as description
                from files f
                where f.fid = _folderuid;
        
    elsif (_mid is not null) then      -- Get all files owned by Member
        create temporary table files_out on commit drop as 
            select f.uid, f.fid, f.mid, f.created,
                    fdecrypt(f.x_name) as filename,
                    fdecrypt(f.x_desc) as description 
                from files f 
                where f.mid = _mid;
        
    else  -- No arguments supplied
        return query select 0, 0, 0, 
            cast(null as timestamp), 
            cast('' as text),
            cast('' as text), -1, 0;
        return;
        
    end if;

    
    -- Count results, return if there are none
    select count(*) into _nrows from files_out; 
    if _nrows = 0 then
        return query select 0, 0, 0, 
            cast(null as timestamp), 
            cast('' as text),
            cast('' as text), 0, 0;
        return;
    end if;
    
    -- Calculate pages
    if (coalesce(_pagesize, 0) = 0) then-- No paging = 1 page
        _pagesize := null;
        _npages   := 1;
    else -- Calculate actual # of pages
        _npages   := _nrows / _pagesize;
        if (_nrows % _pagesize > 0) then _npages := _npages + 1; end if;
    end if;
    
    
    -- Output final results
    return query
        select fo.uid, fo.fid, fo.mid, fo.created, 
            fo.filename, fo.description, _nrows, _npages
        from files_out fo
        order by created desc
        limit _pagesize offset (_page * _pagesize);
    
    return;
    
end
$$ language plpgsql;


