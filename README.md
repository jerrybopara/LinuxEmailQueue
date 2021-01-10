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