
# Directory Structure

 - **`crypto/`** Support and wrapper functions for the pgcrypto library
 - **`documents/`** Text and documentation
 - **`functions/`** The bulk of the code. These populate the database with initial data, handle all user transactions, and provide administrative tools.
 - **`roles/`** Database user definitions (currently only "delphi")
 - **`tables/`** Database table definitions
 - **`types/`** Data type definitions, standardize interfaces across functions that return the same types of data.
 - `transfer.sh` Script to place an install package on a target machine via SCP
 - `install.sh`  Creates the `lc` database on the local machine, dropping it first if necessary.

# Getting the Install package
 - On the target machine, Clone the repository from GitHub: ``git clone git://github.com:mojo-blues/lifecloud.git``
 - On the source machine, edit and run `transfer.sh`, which copies the installation package onto the target machine via `scp`.

# Installation

Once the installation package is in place, run `install.sh`

 - PostgreSQL must be running
 - the `pgcrypto` library must be installed
 - You may need to first invoke these magic words:
 
 	`pg_ctl restart -D /opt/pgsql/data/ -m fast`
 	
 	This restarts PostgreSQL, kicking off any attached web users and freeing up the database to be dropped and recreated.

### Notes

The `admin_create_...` functions define all of the magic EventCodes, ReturnValues, Applications, etc that are used by the other functions