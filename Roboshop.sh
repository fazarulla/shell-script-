#!/bin/bash
SG_ID="sg-0718c2c4c36982ff9"
AMI_ID="ami-0220d79f3f480ecf5"

for Instance in $@
do
   INSTANCE_ID=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$Instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text )
    
    if [ $instance == "frontend" ]; then
        IP=$( 
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text 
        )
    else
        IP=$( 
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text 
        )
    fi 
    echo "IP Address: $IP"              
done




