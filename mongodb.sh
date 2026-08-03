!#/bin/bash
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

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copyping Mongo Repo"

dnf install mongodb-org -y 
VALIDATE $? "installing MongoDB Server"

systemctl enable mongod 
VALIDATE $? "enable mongoDB"

systemctl start mongod 
VALIDATE $? "start mongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing Remote connections"

systemctl restart mongod
VALIDATE $? "Restart MongoDB"
