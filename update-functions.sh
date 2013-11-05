#!/bin/sh

for i in ./functions/func-*.sql; do
    psql --dbname=lc --username=pgsql --file=$i
done
