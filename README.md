<!-- 
      2014-04-29 dbrown
-->

# Directory Structure

__`crypto/`__ Support and wrapper functions for the pgcrypto library  
__`documents/`__ Text and documentation  
__`functions/`__ The bulk of the code. These populate the database with initial data, handle all user transactions, and provide administrative tools  
__`roles/`__ Database user definitions (currently only "delphi")  
__`tables/`__ Database table definitions  
__`types/`__ Data type definitions, standardize interfaces across functions that return the same types of data 

`transfer.sh` Copies an install package onto a target machine via SCP  
`install.sh` (Re-)Creates the lc database on the local machine

---

# Step 1. Get the code
 - On the target machine, Clone the repository from GitHub:
  
        git clone git://github.com:mojo-blues/lifecloud.git
     
 - Or, on the source machine, edit and run `transfer.sh`

# Step 2. Create the database
Once the code is in place, run `install.sh`

 - PostgreSQL must be running
 - The `pgcrypto` library must be installed
 - You may need to first say this:
 
 	`pg_ctl restart -D /opt/pgsql/data/ -m fast`
 	
 	This restarts PostgreSQL, kicking off any attached web users and freeing up the database to be dropped and recreated.

---

### Code Notes
The `admin_create_...` functions define all of the magic EventCodes, ReturnValues, Applications, etc that are used by the other functions