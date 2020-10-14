############
#Readme file
############

## Project worked upon by Harish Lingegowda & Zeeshan (Zee) Mirza From AWS

			###################################################
			#RDS RMAN BACKUP AUTOMATION Using Stored PROCEDURE#
			###################################################
			
# Description
> These procedures are created to automate the RMAN backup on Oracle RDS locally and upload them to S3 and Notify the customer

# Types
> 2 types of procedure codes have been written based on method of Notification

Method-1 >> With Lambda for Notification
Method-2 >> With NO Lambda for Notifcation (reducing the costs)


# Prerequisites
1. Create a S3 bucket for RMAN backup uploads
	> and make sure Glacier Lifecycle policies are there (based on the retention policy)
	Note: if you are using Method 1 (with LAMBDA) then you might want to create a status folder/ or s status bucket
2. Create Option Group for S3 & Mail integration with RDS database
3. Create a DBA_DIRECTORY for backups wihtin RDS database
4. Grant Priv's to the Admin user (which is used for executing and scheduling the procedure)
5. Set retention of Archives based on the need in hours 
6. IAM Role for S3 integration
7. IAM Policy for S3 integration
8. If Method 2 (with NO Lambda) then make sure Wallet for SMTP or SMTP configuration is done for RDS
Note: This might not be required based on SMTP policies and usage in your organization

# Disclaimer
We have designed and tested this on our environment in multiple scenarios, make sure this is well tested before deploying it in your Live environments (especially Prod)
- There are a lot of variables which can be modified per your need


# Implementation steps
###########################################################################################
#################### Method-1    >> With Lambda for Notification <<  ######################
###########################################################################################

# Pre-requisites
> Make sure Bucket for Dumps and Bucket/Folder for Status
> Create S3 Integration Role & Policy
> Create Option group 
Note: try to have a large instance db on the server
> use compression for backups - as needed

Steps to deploy
1. Use the "lamdda.py" to create a S3_RMAN_AUTOMATION Lambda function

2. Use the "pre_steps.sql" to do the pre-steps 

3. Use the "RMAN_bkup_to_S3_Lamb_SP.sql" - for the main procedure

4. Use the scripts to check status "Check_quries.sql" of each steps  (these are common handy queries)

5. Use DBMS_SCHEDULER to schedule the frequency of backups

# Executing the procedure:
	exec RMAN_bkup_to_S3_Lamb_SP.sql(<S3_Bucket_name>);

###########################################################################################
################# Method-2    >> With NO-Lambda for Notification <<  ######################
###########################################################################################

# Pre-requisites
> Make sure Bucket for Dumps (only 1 needed)
> Create S3 Integration Role & Policy
> Create Option group 
Note: try to have a large instance db on the server
> use compression for backups - as needed
> create a wallet for 12c/19c accordingly for SMTP 
Note: this step of creating a wallet is not needed unless there a restirctions in organization to send direct emails

Steps to deploy

1. Use the "pre_steps.sql" to do the pre-steps 

2. Use the "RMAN_bkup_to_S3_NoLamb_SP.sql" - for the main procedure

3. Use the scripts to check status "Check_quries.sql" of each steps (these are common handy queries)

4. deploy the "mail_setup.sql" (configure the email and SMTP domains)

5. Use DBMS_SCHEDULER to schedule the frequency of backups

# Executing the procedure:
	exec RMAN_bkup_to_S3_NoLamb_SP.sql(<S3_Bucket_name>);

#########################################################################################