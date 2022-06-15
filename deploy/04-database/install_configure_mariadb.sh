#!/bin/sh
curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
bash mariadb_repo_setup --os-type=rhel  --os-version=7 --mariadb-server-version=10.7
yum makecache
yum repolist
yum install -y MariaDB-server MariaDB-client
systemctl enable --now mariadb
sudo mysql -sfu root -e "GRANT ALL PRIVILEGES ON wordpress.* to 'wordpress'@'%' IDENTIFIED BY 'wordpress99';"
sudo mysql -sfu root -e "GRANT SUPER, RELOAD, PROCESS, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO wordpress@'%';"
sudo mysql -sfu root -e "FLUSH PRIVILEGES;"
systemctl stop mariadb
sudo cp /etc/my.cnf.d/server.cnf /etc/my.cnf.d/server.cnf.backup
sudo rm /etc/my.cnf.d/server.cnf 
sudo tee /etc/my.cnf.d/server.cnf<<EOT
[mysqld]
log_bin=/var/lib/mysql/bin-log
log_bin_index=/var/lib/mysql/mysql-bin.index
expire_logs_days= 2
binlog_format= ROW
EOT
systemctl start mariadb