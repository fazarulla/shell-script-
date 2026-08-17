#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.fazarulla.online
MYSQL_HOST=mysql.fazarulla.online

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf install maven -y$LOGS_FILE
validate $? "install Maven"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi
mkdir -p /app 
validate $? "Creating App directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOGS_FILE
VALIDATE $? "Downloading shipping code"

cd /app
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/shipping.zip &>>$LOGS_FILE
VALIDATE $? "Uzip shipping code"

cd /app 
mvn clean package 
validate $? "installing & bultiding shipping "

mv target/shipping-1.0.jar shipping.jar &>>$LOGS_FILE
validate $? "moving and renaming shipping "

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Created systemctl service"

dnf install mysql -y &>>$LOGS_FILE
validate $? "installing mysql "

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'

if [ $? ne 0 ]; then
      mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOGS_FILE
      mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOGS_FILE
      mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOGS_FILE
      VALIDATEn $? "loaded data in to mysql"

eals
    echo -e " Data is already loded .. so $Y ..skping $N"
fi

systemctl enable shipping 
systemctl start shipping
validate $? "Enable&start shipping "