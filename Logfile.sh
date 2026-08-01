#!/bin/bash
USERID=$(id -u)
LOG_FOLDER="/var/log/shell-script"
LOG_FILE="/var/log/shell-script/$0.log"

if [ $USERID -ne 0 ]; then
    echo "Please run this script with root user access" | tee -a $LOG_FILE
    exit 1
fi

mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
    echo "$2... FAILUER" | tee -a $LOG_FILE
    exit 1
    else
    echo "$2... SUCCESS" | tee -a $LOG_FILE
    fi
}

dnf install nginx -y &>>  $LOG_FILE
VALIDATE $? "Installing Nginx"

dnf install mysql -y &>>  $LOG_FILE
VALIDATE $? "Installing Mysql"


dnf install nodejs -y &>>  $LOG_FILE
VALIDATE $? "Installing nodejs"