#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

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
    echo "You are root user"
fi

dnf install maven -y &>> $LOGFILE
VALIDATE $? "installing maven"

id ecommerce
if [ $? -ne 0 ]
then
    useradd ecommerce
    VALIDATE $? "ecommerce user creation"
else
    echo -e "E-commerce user already exist $Y Skipping $N"
fi

mkdir /app &>> $LOGFILE
VALIDATE $? "Creating app directory"
rm -rf /app/*
curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "Downloading shipping"

cd /app 
VALIDATE $? "moving to app directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "unzipping shipping"

mvn clean package &>> $LOGFILE
VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "renaming jar file"

cp /home/centos/ecommerce-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "copying shipping service "

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon reloading"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "enabled shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "starting shipping"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "install mysql client"

mysql -h mysql.purushothamai.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "loading shipping data"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "restart shipping"