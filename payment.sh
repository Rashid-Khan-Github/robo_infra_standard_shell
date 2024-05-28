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

yum install python36 gcc python3-devel -y  &>> $LOGFILE

VALIDATE $? "Installing Python 3.6 !"

useradd roboshop  &>> $LOGFILE

VALIDATE $? "Adding Roboshop User.."

mkdir /app  &>> $LOGFILE

VALIDATE $? "Creating /app dir.."

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip  &>> $LOGFILE

VALIDATE $? "Downloading Artifacts.."

cd /app  &>> $LOGFILE

VALIDATE $? "Movin into /app dir.."

unzip /tmp/payment.zip  &>> $LOGFILE

VALIDATE $? "Unzipping Artifacts.."

pip3.6 install -r requirements.txt  &>> $LOGFILE

VALIDATE $? "Installing Dependencies from requirements.txt !.."

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service  &>> $LOGFILE

VALIDATE $? "Copying Payment Service file to /etc/systemd/system.."

systemctl daemon-reload  &>> $LOGFILE

VALIDATE $? "Reloading System Daemon for service refresh"

systemctl enable payment  &>> $LOGFILE

VALIDATE $? "Enabling Payment service.."

systemctl start payment  &>> $LOGFILE

VALIDATE $? "Starting Payment service.."