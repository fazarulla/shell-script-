#!/bin/bash
USERID=$(id -u)
LOG_FOLDER="/var/log/shell-Roboshop"
LOG_FILE="/var/log/shell-Roboshop/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPTDERECTORY=$PWD

if [ $USERID -ne 0 ]; then
    echo "Please run this script with root user access" | tee -a $LOG_FILE
    exit 1
fi

mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
    echo -e "$2... $R FAILUER $N" | tee -a $LOG_FILE
    exit 1
    else
    echo -e "$2... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf module disable redis -y &>>LOG_FILE
dnf module enable redis:7 -y &>>LOG_FILE
validate $? "Enabling Redis 7 module" &>>LOG_FILE 

dnf install redis -y &>>LOG_FILE
validate $? "Installing Redis" &>>LOG_FILE
sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode/ no' /etc/redis/redis.conf
validate $? "Updating Redis Config" &>>LOG_FILE
systemctl enable redis &>>LOG_FILE
systemctl start redis 
validate $? "Enabling& Starting Redis Service"
