-- ---------------------------------------------------------------------------
--  function get_retval_text
-- ---------------------------------------------------------------------------

create or replace function get_retval_text(

    arg_retval int

) returns text as $$

declare
    msgout text;

begin
    select msg into msgout from ref_retvals
    where retval = arg_retval;

    return msgout;
end
$$ language plpgsql;
