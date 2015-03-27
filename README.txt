
Directory Structure
-------------------
crypto/     Support and wrapper functions for the pgcrypto library  
documents/  Text and documentation  
functions/  The bulk of the code. These populate the database with initial
            data, handle user transactions, and provide administrative tools
roles/      database user definitions (currently only "delphi")
sqltools/   Not product code; tools for working with Postgres
tables/     Database table definitions  
tests/      Not product code; performance tests
types/      Data type definitions, standardize interfaces across functions
            that return the same types of data 

transfer.sh   Copies an install package onto a target machine via SCP  
install.sh    (Re-)Creates the lc database on the local machine


Step 1. Get the code
--------------------
On the target machine, Clone the repository from GitHub:
  
    git clone git://github.com:mojo-blues/lifecloud.git
     
Or, on the source machine, edit and run transfer.sh



Step 2. Create the database
--------------------
First of all
 - PostgreSQL must be running
 - Its pgcrypto library must be installed
 - You may need to first say:  pg_ctl restart -D /opt/pgsql/data/ -m fast
     This restarts PostgreSQL, kicking off any attached web users and
     freeing up the database to be dropped and recreated.

Once the code is in place, run install.sh.

