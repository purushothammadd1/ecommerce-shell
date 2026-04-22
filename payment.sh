#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.daws76s.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

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
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf install python36 gcc python3-devel -y  &>> $LOGFILE
VALIDATE $? "Installing python"

useradd ecommerce  &>> $LOGFILE
VALIDATE $? "adding a username"

mkdir /app  &>> $LOGFILE
VALIDATE $? "make directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip  &>> $LOGFILE
VALIDATE "zipping the payment folder"

cd /app &>> $LOGFILE
VALIDATE $? "change directory"

unzip -o /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "unzipping directory"

pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "Install the requirement in pip"

cp /home/centos/ecommerce-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "copied payment service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Reloading the payment"

systemctl enable payment &>> $LOGFILE 
VALIDATE $? "Enabling payment"

systemctl start payment &>> $LOGFILE
VALIDATE $? "starting payment"