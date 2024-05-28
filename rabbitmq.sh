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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash  &>> $LOGFILE

VALIDATE $? "Downloading Vendor Script for RabbitMQ.. !"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh |  bash &>> $LOGFILE

VALIDATE $? "Setting Up RabbitMq Yum Repository.. !"

yum install rabbitmq-server -y  &>> $LOGFILE

VALIDATE $? "Installing RabbitMQ..!"

systemctl enable rabbitmq-server  &>> $LOGFILE

VALIDATE $? "Enabling Rabbit MQ"

systemctl start rabbitmq-server  &>> $LOGFILE

VALIDATE $? "Starting Rabbit MQ.."

rabbitmqctl add_user roboshop roboshop123  &>> $LOGFILE

VALIDATE $? "Creating User for RabbitMQ for connection..!"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>> $LOGFILE

VALIDATE $? "Setting Permissions for Rabbit MQ.."