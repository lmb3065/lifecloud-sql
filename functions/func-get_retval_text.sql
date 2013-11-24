-- ---------------------------------------------------------------------------
--  function get_retval_text
-- ---------------------------------------------------------------------------
--  2013-11-17 dbrown: returns SUCCESS for anything > success
-- ---------------------------------------------------------------------------

create or replace function get_retval_text(

    arg_retval int

) returns text as $$

declare
    RETVAL_SUCCESS constant int := 1;
    msgout text;

begin

    if (arg_retval > RETVAL_SUCCESS) then
        arg_retval = RETVAL_SUCCESS;
    end if;

    select msg into msgout from ref_retvals
    where retval = arg_retval;

    return msgout;

end
$$ language plpgsql;
