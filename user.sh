#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODB_HOST=mongodb.purushothamai.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
else
    echo -e "$G You are root user $N"
fi

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabling current NodeJS"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enabling NodeJS:18"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing NodeJS:18"

id ecommerce
if [ $? -ne 0 ]
then
    useradd ecommerce
    VALIDATE $? "ecommerce user creation"
else
    echo -e "E-commerce user already exist $Y Skipping $N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "creating app directory"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "Downloading user application"

cd /app

unzip -o /tmp/user.zip &>> $LOGFILE
VALIDATE $? "unzipping user"

npm install &>> $LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/centos/ecommerce-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "copying user service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "user daemon reload"

systemctl enable user &>> $LOGFILE
VALIDATE $? "Enable user"

systemctl start user &>> $LOGFILE
VALIDATE $? "Starting user"

cp /home/centos/ecommerce-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongodb repo"

yum install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Installing MongoDB client"

mongo --host $MONGODB_HOST </app/schema/user.js &>> $LOGFILE
VALIDATE $? "Loading user data into MongoDB"