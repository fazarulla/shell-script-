#!/bin/bash
SG_ID=sg-016b62a93da4cccb5
AMI_ID=ami-0220d79f3f480ecf5
for instance in $@
do insdent_ID=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID\
    --query 'Reservations[].Instances[].PublicIpAddress' \
    --output text
     )

    if [ $instance == "frontend" ]; then
        IP=$(
           aws ec2 describe-instances \
         --instance-ids $instant_ID \
         --query 'Reservations[].Instances[].PublicIpAddress' \
         --output text 
            ) 
   else 
        IP=$(
          aws ec2 describe-instances \
         --instance-ids $insdent_ID \
         --query 'Reservations[].Instances[].PrivateIpAddress' \
         --output text
         )
     fi
     echo "Ip address $IP"

done