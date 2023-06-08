-- Step 1: Create the POLICY_ADMIN Custom Role
use role USERADMIN;
-- Create users for challenge
create user FF32_USER1; -- A UI User
create user FF32_USER2; -- A NON-UI User
create role policy_admin;
grant role policy_admin to user ABENBINYAMIN;

-- Step 2: Grant Privileges to the POLICY_ADMIN Custom Role
use role SECURITYADMIN;
grant usage on database atzmon_db to role policy_admin;
grant usage, create session policy on schema atzmon_db.challenges to role policy_admin;
grant apply session policy on account to role policy_admin;

-- Associating a session policy with an individual user:
grant apply session policy on user FF32_USER1 to role policy_admin;
grant apply session policy on user FF32_USER2 to role policy_admin;


-- Step 3: Create a New Session Policy
use role policy_admin;
create or replace session policy atzmon_db.policies.session_policy_ff32_user1
    -- The idle timeout period in minutes for the Snowflake web interface
    SESSION_UI_IDLE_TIMEOUT_MINS = 8
    COMMENT = 'Session policy for FrostyFriday challenge 32 - apply to UI user FF32_USER1';

create or replace session policy atzmon_db.policies.session_policy_ff32_user2
    -- The idle timeout period in minutes for Snowflake Clients and programmatic clients
    SESSION_IDLE_TIMEOUT_MINS = 10
    COMMENT = 'Session policy for FrostyFriday challenge 32 - apply to NON UI user FF32_USER2';

-- Step 4: Set the Session Policy on an Account or User
use role policy_admin;
-- Set the policy on an account
--alter account set session policy atzmon_db.policies.session_policy_ff32;
-- Or a user
alter user FF32_USER1 set session policy atzmon_db.challenges.session_policy_ff32_user1;
alter user FF32_USER2 set session policy atzmon_db.challenges.session_policy_ff32_user2;

-- Important!
-- To replace a session policy that is already set for an account or user, 
-- unset the session policy first and then set the new session policy for the account or user.
--ALTER ACCOUNT UNSET session policy;
--ALTER ACCOUNT SET SESSION POLICY mydb.policies.session_policy_prod_2;

-- Clean up and Closing:
-- To set or unset a user-level session policy, 
-- execute the ALTER USER command as shown below.
--ALTER USER user1 SET SESSION POLICY mydb.policies.session_policy_prod_1_jsmith;
use role policy_admin;
alter user FF32_USER1 unset session policy;
alter user FF32_USER2 unset session policy;

-- Drop SESSION POLICIES
drop session policy atzmon_db.challenges.session_policy_ff32_user1;
drop session policy atzmon_db.challenges.session_policy_ff32_user2;


-- Drop Users
use role USERADMIN;
drop user FF32_USER1;
drop user FF32_USER2;
