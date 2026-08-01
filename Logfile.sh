#!/bin/bash
USERID=$(id -u)
LOG_FOLDER="/var/log/shell-script"
LOG_FILE="/var/log/shell-script/$0.log"

if [$USERID -ne 0 ]; then
    echo "Please run this script with root user"
    exit 1
fi

mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
    echo " $2... FAILUER"
    exit 1
    echo "$2... SUCCESS"
    fi
}

dnf install nginex -y &>>  $LOG_FILE
VALIDATE $? "Installing Nginx"

dnf install nginex -y &>>  $LOG_FILE
VALIDATE $? "Installing Mysql"


dnf install nginex -y &>>  $LOG_FILE
VALIDATE $? "Installing nodejs"