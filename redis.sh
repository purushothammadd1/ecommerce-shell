#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
exec &>$LOGFILE

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
    exit 1 #you can give other than 0
else
    echo -e "$G You are root user $N"
fi #fi means reverse of if, indicating condition end


# dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y 
# VALIDATE $? "Installing remi release"

# dnf module enable redis:remi-6.2 -y
# VALIDATE $? "enabling redis"

dnf install redis -y
VALIDATE $? "installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf
VALIDATE $? "allowing remote connections"

sed -i 's/protected-mode yes/protected-mode no/g' /etc/redis.conf
VALIDATE $? "Disabling protected mode"

systemctl enable redis
VALIDATE $? "enabled redis"

systemctl start redis
VALIDATE $? "started redis"

echo -e "$G Redis setup completed successfully $N"