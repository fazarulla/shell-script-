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

for package in $@

do

  dnf list install $package &>> $LOG_FILE
  if [ $? ne 0 ]; then
     echo "$package not installed"


     dnf install $package -y &>> $LOG_FILE
     VALIDATE $? "$package installtion" 
    else "$package already installed, skip "
   fi
done