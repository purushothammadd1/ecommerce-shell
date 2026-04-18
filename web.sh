#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "installing nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "enabling nginx"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "starting nginx server"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "remove default website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "Downloaded web application"

cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "moving nginx html directory"

unzip -o /tmp/web.zip &>> $LOGFILE
VALIDATE $? "unziped web folder"

cp /home/centos/ecommerce-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATE $? "copied roboshop reverse proxy config"

systemctl restart nginx &>> $LOGFILE
VALIDATE $? "restarting nginx server"