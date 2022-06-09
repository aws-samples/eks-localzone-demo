===============
mariaDB on EC2
===============
sudo yum -y update
sudo reboot

curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
sudo bash mariadb_repo_setup --os-type=rhel  --os-version=7 --mariadb-server-version=10.7

sudo rm -rf /var/cache/yum
sudo yum makecache
sudo yum repolist

sudo yum install MariaDB-server MariaDB-client
sudo systemctl enable --now mariadb

systemctl status mariadb


CREATE USER 'username'@'host' IDENTIFIED WITH authentication_plugin BY 'wordpress99';


sudo mysqladmin password "Ys3WO99THog8ghEbGoehv4V8f"
sudo mysql -sfu root -e "create database wordpress"

sudo mysql -sfu root -e "GRANT ALL PRIVILEGES ON wordpress.* to 'wordpress'@'%' IDENTIFIED BY 'wordpress99';"
sudo mysql -sfu root -e "GRANT SUPER, RELOAD, PROCESS, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO wordpress@'%';"
sudo mysql -sfu root -e "FLUSH PRIVILEGES;"

systemctl stop mariadb

sudo cp /etc/my.cnf.d/server.cnf /etc/my.cnf.d/server.cnf.backup
sudo rm /etc/my.cnf.d/server.cnf 

sudo tee /etc/my.cnf.d/server.cnf<<EOF
[mysqld]
log_bin=/var/lib/mysql/bin-log
log_bin_index=/var/lib/mysql/mysql-bin.index
expire_logs_days= 2
binlog_format= ROW
EOF

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
--replication-task-identifier my-repl-task-mariadb-rds \
--source-endpoint-arn arn:aws:dms:us-east-1:171535337713:endpoint:BWEMEXMXPJ7HCQVR6KROJZK74NZIXQS7Q6SWPKA \
--target-endpoint-arn arn:aws:dms:us-east-1:171535337713:endpoint:55JXSNCOK5ZIB2LGWAJNN3IXSZSDOXMU3J6RNFA \
--replication-instance-arn arn:aws:dms:us-east-1:171535337713:rep:V6WFZ4O5VGTS6I7AYNMBEAEV65GHPQ4PBYTZKWA \
--migration-type full-load-and-cdc \
--table-mappings file://table-mappings.json

{
    "ReplicationTask": {
        "ReplicationTaskIdentifier": "my-repl-task-mariadb-rds1",
        "SourceEndpointArn": "arn:aws:dms:us-east-1:171535337713:endpoint:BWEMEXMXPJ7HCQVR6KROJZK74NZIXQS7Q6SWPKA",
        "TargetEndpointArn": "arn:aws:dms:us-east-1:171535337713:endpoint:55JXSNCOK5ZIB2LGWAJNN3IXSZSDOXMU3J6RNFA",
        "ReplicationInstanceArn": "arn:aws:dms:us-east-1:171535337713:rep:V6WFZ4O5VGTS6I7AYNMBEAEV65GHPQ4PBYTZKWA",
        "MigrationType": "full-load-and-cdc",
        "TableMappings": "{\n    \"rules\": [\n        {\n            \"rule-type\": \"selection\",\n            \"rule-id\": \"1\",\n            \"rule-name\": \"1\",\n            \"object-locator\": {\n                \"schema-name\": \"wordpress\",\n                \"table-name\": \"%\"\n            },\n            \"rule-action\": \"include\"\n        }\n    ]\n}",
        "ReplicationTaskSettings": "{\"Logging\":{\"EnableLogging\":false,\"LogComponents\":[{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"DATA_STRUCTURE\"},{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"COMMUNICATION\"},{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"IO\"},{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"COMMON\"},{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"FILE_FACTORY\"},{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"FILE_TRANSFER\"},{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"REST_SERVER\"},{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"ADDONS\"},{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"TARGET_LOAD\"},{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"TARGET_APPLY\"},{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"SOURCE_UNLOAD\"},{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"SOURCE_CAPTURE\"},{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"TRANSFORMATION\"},{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"SORTER\"},{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"TASK_MANAGER\"},{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"TABLES_MANAGER\"},{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"METADATA_MANAGER\"},{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"PERFORMANCE\"},{\"Severity\":\"LOGGER_SEVERITY_DEFAULT\",\"Id\":\"VALIDATOR_EXT\"}],\"CloudWatchLogGroup\":null,\"CloudWatchLogStream\":null},\"StreamBufferSettings\":{\"StreamBufferCount\":3,\"CtrlStreamBufferSizeInMB\":5,\"StreamBufferSizeInMB\":8},\"ErrorBehavior\":{\"FailOnNoTablesCaptured\":true,\"ApplyErrorUpdatePolicy\":\"LOG_ERROR\",\"FailOnTransactionConsistencyBreached\":false,\"RecoverableErrorThrottlingMax\":1800,\"DataErrorEscalationPolicy\":\"SUSPEND_TABLE\",\"ApplyErrorEscalationCount\":0,\"RecoverableErrorStopRetryAfterThrottlingMax\":true,\"RecoverableErrorThrottling\":true,\"ApplyErrorFailOnTruncationDdl\":false,\"DataTruncationErrorPolicy\":\"LOG_ERROR\",\"ApplyErrorInsertPolicy\":\"LOG_ERROR\",\"EventErrorPolicy\":\"IGNORE\",\"ApplyErrorEscalationPolicy\":\"LOG_ERROR\",\"RecoverableErrorCount\":-1,\"DataErrorEscalationCount\":0,\"TableErrorEscalationPolicy\":\"STOP_TASK\",\"RecoverableErrorInterval\":5,\"ApplyErrorDeletePolicy\":\"IGNORE_RECORD\",\"TableErrorEscalationCount\":0,\"FullLoadIgnoreConflicts\":true,\"DataErrorPolicy\":\"LOG_ERROR\",\"TableErrorPolicy\":\"SUSPEND_TABLE\"},\"TTSettings\":{\"TTS3Settings\":null,\"TTRecordSettings\":null,\"EnableTT\":false},\"FullLoadSettings\":{\"CommitRate\":10000,\"StopTaskCachedChangesApplied\":false,\"StopTaskCachedChangesNotApplied\":false,\"MaxFullLoadSubTasks\":8,\"TransactionConsistencyTimeout\":600,\"CreatePkAfterFullLoad\":false,\"TargetTablePrepMode\":\"DROP_AND_CREATE\"},\"TargetMetadata\":{\"ParallelApplyBufferSize\":0,\"ParallelApplyQueuesPerThread\":0,\"ParallelApplyThreads\":0,\"TargetSchema\":\"\",\"InlineLobMaxSize\":0,\"ParallelLoadQueuesPerThread\":0,\"SupportLobs\":true,\"LobChunkSize\":64,\"TaskRecoveryTableEnabled\":false,\"ParallelLoadThreads\":0,\"LobMaxSize\":32,\"BatchApplyEnabled\":false,\"FullLobMode\":false,\"LimitedSizeLobMode\":true,\"LoadMaxFileSize\":0,\"ParallelLoadBufferSize\":0},\"BeforeImageSettings\":null,\"ControlTablesSettings\":{\"historyTimeslotInMinutes\":5,\"HistoryTimeslotInMinutes\":5,\"StatusTableEnabled\":false,\"SuspendedTablesTableEnabled\":fal
se,\"HistoryTableEnabled\":false,\"ControlSchema\":\"\",\"FullLoadExceptionTableEnabled\":false},\"LoopbackPreventionSettings\":null,\"CharacterSetSettings\":null,\"FailTaskWhenCleanTaskResourceFailed\":false,\"ChangeProcessingTuning\":{\"StatementCacheSize\":50,\"CommitTimeout\":1,\"BatchApplyPreserveTransaction\":true,\"BatchApplyTimeoutMin\":1,\"BatchSplitSize\":0,\"BatchApplyTimeoutMax\":30,\"MinTransactionSize\":1000,\"MemoryKeepTime\":60,\"BatchApplyMemoryLimit\":500,\"MemoryLimitTotal\":1024},\"ChangeProcessingDdlHandlingPolicy\":{\"HandleSourceTableDropped\":true,\"HandleSourceTableTruncated\":true,\"HandleSourceTableAltered\":true},\"PostProcessingRules\":null}",
        "Status": "creating",
        "ReplicationTaskCreationDate": "2022-06-05T09:01:37.434000+08:00",
        "ReplicationTaskArn": "arn:aws:dms:us-east-1:171535337713:task:GWSNIFXWQMHNE3BHYVJINFQQMGTWLEDI2FZSICA"
    }
}

aws dms start-replication-task \
    --replication-task-arn arn:aws:dms:us-east-1:171535337713:task:ELB6BD3ZGNVDQORJXLL4H6KQ2DA7D4EYPBWE3CQ \
    --start-replication-task-type start-replication