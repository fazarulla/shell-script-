#!/bin/bash
USERID=$(id -u)
LOG_FOLDER="/var/log/shell-Roboshop"
LOG_FILE="/var/log/shell-Roboshop/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enable nidejs20"

dnf install nodejs -y
VALIDATE $? "install nodjs"

id roboshop &>>$LOG_FILE

if [ $? -ne 0 ]; then
       useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
       VALIDATE $? "Creating system user"
    else
     echo -e "User already exsit..$Y Skyping..$N "
fi
mkdir -p /app 
VALIDATE $? "Crreating directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOG_FILE

VALIDATE $? " Downloading Catalog app"

cd /app
VALIDATE $?

unzip /tmp/catalogue.zip
VALIDATE $? "Unzip package"

cd /app 
npm install 

