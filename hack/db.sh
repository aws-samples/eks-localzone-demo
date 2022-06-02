===============
mariaDB on EC2
===============
sudo yum -y update

curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
sudo bash mariadb_repo_setup --os-type=rhel  --os-version=7 --mariadb-server-version=10.7

sudo rm -rf /var/cache/yum
sudo yum makecache
sudo yum repolist

sudo yum install MariaDB-server MariaDB-client -y
sudo systemctl enable --now mariadb

systemctl status mariadb

--todo : create account, grant access permission, create datbase/table
wordpress/wordperss99/wordpress

===============
RDS mariaDB 
===============
aws rds create-db-instance \
    --db-instance-identifier test-mariadb-instance \
    --db-instance-class db.t3.large \
    --engine mariadb \
    --master-username admin \
    --master-user-password secret99 \
    --allocated-storage 20

===============
DMS
===============
aws dms create-replication-instance \
    --replication-instance-identifier my-repl-instance \
    --replication-instance-class dms.t3.medium \
    --allocated-storage 50 \
    --no-multi-az \
    --no-publicly-accessible

{
    "ReplicationInstance": {
        "ReplicationInstanceIdentifier": "my-repl-instance",
        "ReplicationInstanceClass": "dms.t3.medium",
        "ReplicationInstanceStatus": "creating",
        "AllocatedStorage": 50,
        "VpcSecurityGroups": [
            {
                "VpcSecurityGroupId": "sg-04da9b1cfa8e4304d",
                "Status": "active"
            }
        ],
        "AvailabilityZone": "us-east-1b",
        "ReplicationSubnetGroup": {
            "ReplicationSubnetGroupIdentifier": "default",
            "ReplicationSubnetGroupDescription": "default",
            "VpcId": "vpc-09338c6cb945624d8",
            "SubnetGroupStatus": "Complete",
            "Subnets": [
                {
                    "SubnetIdentifier": "subnet-0da9155b11dff28be",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1-bos-1a"
                    },
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-0a7df20984733e6e4",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1d"
                    },
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-0e616c9f77ac89d39",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1a"
                    },
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-084d83cc961526196",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1-bos-1a"
                    },
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-03ad3036642f7a154",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1e"
                    },
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-01fb8e93f2e6c87ec",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1b"
                    },
                    "SubnetStatus": "Active"
                }
            ]
        },
        "PreferredMaintenanceWindow": "mon:06:33-mon:07:03",
        "PendingModifiedValues": {},
        "MultiAZ": false,
        "EngineVersion": "3.4.5",
        "AutoMinorVersionUpgrade": true,
        "KmsKeyId": "arn:aws:kms:us-east-1:171535337713:key/0974142a-1097-4197-98d3-1869a25a722a",
        "ReplicationInstanceArn": "arn:aws:dms:us-east-1:171535337713:rep:AGI3EOB7EQ33UBIVDW4PJ2CV2HLNNA5ND336HNQ",   <---
        "PubliclyAccessible": false
    }
}

aws dms create-endpoint \
    --endpoint-identifier source-mariadb-lz-ec2 \
    --endpoint-type source \
    --engine-name mariadb \
    --username root \
    --password t0shi6aB99 \
    --server-name 172.31.132.155 \
    --port 3306

{
    "Endpoint": {
        "EndpointIdentifier": "source-mariadb-lz-ec2",
        "EndpointType": "SOURCE",
        "EngineName": "mariadb",
        "EngineDisplayName": "MariaDB",
        "Username": "root",
        "ServerName": "172.31.132.155",
        "Port": 3306,
        "Status": "active",
        "KmsKeyId": "arn:aws:kms:us-east-1:171535337713:key/0974142a-1097-4197-98d3-1869a25a722a",
        "EndpointArn": "arn:aws:dms:us-east-1:171535337713:endpoint:BWEMEXMXPJ7HCQVR6KROJZK74NZIXQS7Q6SWPKA",
        "SslMode": "none",
        "MySQLSettings": {
            "Port": 3306,
            "ServerName": "172.31.132.155",
            "Username": "root"
        }
    }
}

aws dms create-endpoint \
    --endpoint-identifier target-mariadb-rds \
    --endpoint-type target \
    --engine-name mariadb \
    --username admin \
    --password secret99 \
    --server-name test-mariadb-instance.ctt4agymi5mq.us-east-1.rds.amazonaws.com \
    --port 3306

{
    "Endpoint": {
        "EndpointIdentifier": "target-mariadb-rds",
        "EndpointType": "TARGET",
        "EngineName": "mariadb",
        "EngineDisplayName": "MariaDB",
        "Username": "admin",
        "ServerName": "test-mariadb-instance.ctt4agymi5mq.us-east-1.rds.amazonaws.com",
        "Port": 3306,
        "Status": "active",
        "KmsKeyId": "arn:aws:kms:us-east-1:171535337713:key/0974142a-1097-4197-98d3-1869a25a722a",
        "EndpointArn": "arn:aws:dms:us-east-1:171535337713:endpoint:55JXSNCOK5ZIB2LGWAJNN3IXSZSDOXMU3J6RNFA",
        "SslMode": "none",
        "MySQLSettings": {
            "ParallelLoadThreads": 1,
            "Port": 3306,
            "ServerName": "test-mariadb-instance.ctt4agymi5mq.us-east-1.rds.amazonaws.com",
            "Username": "admin"
        }
    }
}

aws dms create-replication-task \
--replication-task-identifier my-repl-instance \
--source-endpoint-arn <value>
--target-endpoint-arn <value>
--replication-instance-arn <value>
--migration-type full-load-and-cdc \
--table-mappings <value>




sudo mysqladmin password “wordpress99”
sudo mysql -sfu root -e "create database wordpress"
sudo mysql -sfu root -e "GRANT ALL PRIVILEGES ON wordpress.* to 'wordpress'@'%' IDENTIFIED BY 'wordpress99';"
sudo mysql -sfu root -e "FLUSH PRIVILEGES;"

