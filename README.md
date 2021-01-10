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

6. - 