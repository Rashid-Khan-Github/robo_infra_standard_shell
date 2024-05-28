#! /bin/bash

USERID=$(id -u)

DATE=$(date +%F)
SCRIPT_NAME=$0
LOGDIR=/tmp
LOGFILE=$LOGDIR/$SCRIPT_NAME-$DATE.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#check whether the user is root -->

if [ $USERID -ne 0 ]
then
    echo -e "$R Error :: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2....$R Failure $N"
        exit 1
    else
        echo -e "$2....$G Success $N"
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copied MongoDB repo into yum.repos.d"

yum install mongodb-org -y &>> $LOGFILE
VALIDATE $? "MongoDB Installation"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "Enabling MongoDB"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
VALIDATE $? "Changing MongoDB access from external server"

systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarting MongoDB"

