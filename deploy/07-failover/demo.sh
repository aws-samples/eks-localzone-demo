kubectl scale --replicas=0 deploy wordpress 
aws ec2 terminate-instances --instance-ids $DB_INSTANCE_ID 