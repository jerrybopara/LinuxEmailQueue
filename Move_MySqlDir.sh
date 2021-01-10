# !/bin/bash
# A Basic Script to Migrate the MySql Data Directory to another Location.

# Note: MySql Credentials are in - ~/.my.cnf
# 
# [client]
# user=username
# password=password

# MySqlConf="/etc/mysql/mysql.conf.d/mysqld.cnf"

MYSQL=$(which mysql)
MYSQLDUMP=$(which mysqldump)
RSYNC=$(which rsync)
CHOWN=$(which chown)
SYSTEMCTL=$(which systemctl)
MV=$(which mv)
CP=$(which cp)

NewMySqlDir="/MySql_SSD/MySqlDIR/"
BackupDir="/MySql_SSD/MySql_Backup"

OLDMYSQL_DIR=$($MYSQL -e 'select @@datadir;' | grep -v '|' | tail -n1 | sed 's:/*$::')
MAINMYSQL_DIR="$OLDMYSQL_DIR"

# Taking Backup of current DB.
mkdir -p $NewMySqlDir
echo  "==> Taking all MySql DB's Backup."
mkdir -p $BackupDir
$MYSQLDUMP --all-databases | gzip > "$BackupDir"/"alldbs_before_moving_mysql.sql.gz"

# Stop MySql Service 
$SYSTEMCTL stop mysql.service

# Sync again when mysql is off.
# $RSYNC -av "$OLDMYSQL_DIR1" "$NewMySqlDir"
$RSYNC -av "$MAINMYSQL_DIR" "$NewMySqlDir"
$CHOWN -R mysql:mysql "$NewMySqlDir"/mysql

# Renaming the MySql Directory. 
$MV "$MAINMYSQL_DIR" "$MAINMYSQL_DIR"_Bak

# Creating Symlink - of new mysql dir with /var/lib/mysql
ln -s "$NewMySqlDir"/mysql $MAINMYSQL_DIR

$SYSTEMCTL start mysql.service
$SYSTEMCTL status mysql.service


