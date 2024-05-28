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

# check whether the user is root -->

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

yum module disable mysql -y  &>> $LOGFILE

VALIDATE $? "Disabling Default yum MySQL.."

cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo  &>> $LOGFILE

VALIDATE $? "Adding New MySql Repo.."

yum install mysql-community-server -y  &>> $LOGFILE

VALIDATE $? "Installing MySql Community Edition 5.7.."

systemctl enable mysqld  &>> $LOGFILE

VALIDATE $? "Enabling Mysql.."

systemctl start mysqld  &>> $LOGFILE

VALIDATE $? "Starting Mysql.."

mysql_secure_installation --set-root-pass RoboShop@1  &>> $LOGFILE

VALIDATE $? "Setting Root Password.."
