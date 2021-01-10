# How to move MySql Data Directory to a another location in Ubuntu Or in CentOS.

## *INTRODUCTION*

### In this post we going to discuss about migrating OR relocating MySql data directory to another location than the default one. 

#### - You may need to migrate/relocate the data directory, when your MySql growing so fast and there are more chances to go out of disk space anytime. 

#### - You may Need to Relocate MySql due to performance issues. Usally when you have your MySql running at the default location & disk, so there are more chances that you will face I/O bassed Issues. 

#### - Or due to some security issues we want to move MySql to a seprate location.

### *PREREQUISITES OR RECOMMENDATIONS*
1. Collect the Basic information about your Setup. 
   - Check your Installed OS & Its version.
   ```
   $ cat /etc/lsb-release 
   	 DISTRIB_ID=Ubuntu
	 DISTRIB_RELEASE=18.04
	 DISTRIB_CODENAME=bionic
	 DISTRIB_DESCRIPTION="Ubuntu 18.04.4 LTS"
   ```	

   - Keep an MySql Credentials with you. I've configured my ~/.my.cnf. 
   ```
   $ vim ~/.my.cnf
    [client]
	user=username
	password=password
   ```	 
   - Get the current MySql Directory. 
   ```
   $ mysql -e 'select @@datadir;' | grep -v '|' | tail -n1 | sed 's:/*$::'
     /var/lib/mysql
   ```

   - Make sure you've sudo user access of the server. 

2. I recommend you to migrate MySql Data Directory to the disks's which having good I/O rate. 

3. In this Guide, I'm Migrating MySql to my LVM `/dev/MYSQL_VG1/MYSQL_VG1`.

### Let's Get Started, Just get the script and make it executables, but before doing anything try to upderstand the all steps, it gonna perform.

1. - Please Update below Variables, Before you execute the script.
```
NewMySqlDir="/MySql_SSD/MySqlDIR/"  # Location where MySql will get moved.
BackupDir="/MySql_SSD/MySql_Backup" # Location where Script store the all db's backup before any change.

MAINMYSQL_DIR="/var/lib/mysql" # Current default location of MySql data Directory.
```

2. - Taking an backup of all db's, before making any change. 
```
# Taking Backup of current DB.
mkdir -p $NewMySqlDir
echo  "==> Taking all MySql DB's Backup."
mkdir -p $BackupDir
$MYSQLDUMP --all-databases | gzip > "$BackupDir"/"alldbs_before_moving_mysql.sql.gz"
```

3. - Stopping MySql Service, So that we can properly copy the mysql directory to the new destination.
```
# Stop MySql Service 
$SYSTEMCTL stop mysql.service
``` 

4. - Syncing the MySql Default Directory with the new location.
```
# Sync when mysql is off.
$RSYNC -av "$MAINMYSQL_DIR" "$NewMySqlDir"
$CHOWN -R mysql:mysql "$NewMySqlDir"/mysql
```

5. - Taking an a backup of Main Default MySql data directory. So that if anything goes wrong we can restore our MySql.
```
# Renaming the MySql Directory. 
$MV "$MAINMYSQL_DIR" "$MAINMYSQL_DIR"_Bak
```

6. - In this Script I'm using an approach where I'm creating an Symlink of new location with the same name/location of default MySql Data Directory.
```
# Creating Symlink - of new mysql dir with /var/lib/mysql
ln -s "$NewMySqlDir"/mysql $MAINMYSQL_DIR

$SYSTEMCTL start mysql.service  # Just Restarting the service back.
$SYSTEMCTL status mysql.service # If everything went well, You'll see the service is up & running.

```

### *KEYNOTES*
1. - There are 2 approaches to migrate MySql Data Directory.
	 - Following the `Symlink` approach. 
	 - Modify the MySql Data Directory Path in - `my.cnf` OR `mysqld.cnf`, as per the OS. 


2. - If you going to follow the 2nd approach. Here's the few things you've take care off. 
     - `Run the script till step 5, and comment out the further symlink stuff and run the follwing commands.` 

     ```
     # Making Changes in MySqld.conf

     - Taking a backup of main mysql conf file.
	 $ cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf.bak

	 - Collecting the line number of "datadir = /var/lib/mysql"
	 $ cat -n "/etc/mysql/mysql.conf.d/mysqld.cnf" | grep "datadir" | awk '{print $1}') 


	 - Just Using SED to replace the `/var/lib/mysql` with the new location `/MySql_SSD/MySqlDIR/mysql`
	 $ sed -i "36 s/\/var\/lib\/mysql/\/MySql_SSD\/MySqlDIR\/mysql/" cat -n "/etc/mysql/mysql.conf.d/mysqld.cnf" | grep "datadir" | awk '{print $1}'


     ``` 