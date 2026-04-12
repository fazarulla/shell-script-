#!/bin/bash

SG_ID="sg-016b62a93da4cccb5"
AMI_ID="ami-0220d79f3f480ecf5"

# List of instance roles you want to create
INSTANCES=("frontend" "backend" "database")

for instance in "${INSTANCES[@]}"; do
    echo "Launching $instance ..."

    # Launch the EC2 instance
    instance_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type "t3.micro" \
        --security-group-ids "$SG_ID" \
        --query 'Instances[0].InstanceId' \
        --output text)

    echo "$instance launched with Instance ID: $instance_ID"
    echo "Waiting for instance to enter 'running' state..."
    
    aws ec2 wait instance-running --instance-ids "$instance_ID"

    # Determine whether to retrieve Public or Private IP
    if [[ "$instance" == "frontend" ]]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids "$instance_ID" \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids "$instance_ID" \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text)
    fi

    echo "$instance IP Address: $IP"
    echo "----------------------------------"

done