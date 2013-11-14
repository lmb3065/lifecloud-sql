#!/bin/sh

for i in ./functions/func-*.sql; do
    psql --dbname=lc --username=pgsql --file=$i
done

psql -d lc -U pgsql -t -c 'select admin_create_eventcodes();'
psql -d lc -U pgsql -t -c 'select admin_create_retvals();'
psql -d lc -U pgsql -t -c 'select admin_create_defaultfolders();'
psql -d lc -U pgsql -t -c 'select admin_create_applist();'

