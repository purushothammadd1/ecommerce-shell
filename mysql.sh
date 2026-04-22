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

dnf module disable mysql -y &>> $LOGFILE
VALIDATE $? "Disable current mysql version"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE
VALIDATE $? "Copyied MySQL repo"

dnf install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "Installing MySql server"

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "enabling mysql server"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "Starting MySQL server"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Setting MySQL Root Password"

mysql -uroot -pRoboShop@1