#!/bin/bash
SG_ID="sg-0718c2c4c36982ff9"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z04148293H4QLTC84JQWN"
DOMAIN_Name='fazarulla.online'

for instance in $@
do
   INSTANCE_ID=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text )
    
    if [ $instance == "frontend" ]; then
        IP=$( 
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text 
        )
        RECORD_NAME="$DOMAIN_Name"
    else
        IP=$( 
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text 
        )
         RECORD_NAME="$instance.$DOMAIN_Name"
    fi 
    echo "IP Address: $IP" 

    aws route53 change-resource-record-sets \
    --hosted-zone-id "$ZONE_ID" \
    --change-batch '
        {
    "Comment": "Updating resource record set",
    "Changes": [
        {
        "Action": "UPSERT",
        "ResourceRecordSet": {
            "Name": "'$RECORD_NAME'",
            "Type": "A",
            "TTL": 1,
            "ResourceRecords": [
            {
                "Value": "'$IP'"
            }
            ]
        }
        }
    ]
    }
    '
    echo "DNS record Update for $instance"
              
done



