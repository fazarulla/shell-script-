#!/bin/bash
USERID=$(id -u)
LOG_FOLDER="/var/log/shell-Roboshop"
LOG_FILE="/var/log/shell-Roboshop/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MONGODB_host=mongodb.fazarulla.online

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
VALIDATE $?"moving to app directory"
rm -rf /app/*
VALIDATE "removing existing code"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Unzip package code"


 
npm install &>>$LOG_FILE 
VALIDATE $? "installing dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "created systemctl service"

systemctl daemon-reload
systemctl enable catalogue &>>$LOG_FILE
systemctl start catalogue 
VALIDATE "startin & enabling catatalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongosh -y &>>$LOG_FILE



INDEX=$(mongosh --host $MONGODB_host --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_host </app/db/master-data.js
    VALIDATE $? "Loading products"
else
    echo -e "Products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
VALIDATE $? "Restarting catalogue"

