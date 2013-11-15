#!/bin/sh

for i in ./functions/func-*.sql; do
    psql --dbname=lc --username=pgsql --file=$i
done
echo
## psql emits a blank line, grep eats it
psql -d lc -U pgsql -t -c 'select admin_create_eventcodes();' | grep '.'
psql -d lc -U pgsql -t -c 'select admin_create_retvals();' | grep '.'
psql -d lc -U pgsql -t -c 'select admin_create_defaultfolders();' | grep '.'
psql -d lc -U pgsql -t -c 'select admin_create_applist();' | grep '.'
echo

