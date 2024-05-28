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


yum install nginx -y &>> $LOGFILE

VALIDATE $? "Installing Nginx.."

systemctl enable nginx &>> $LOGFILE

VALIDATE $? "Enabling Nginx.."

systemctl start nginx &>> $LOGFILE

VALIDATE $? "Starting Nginx.."

rm -rf /usr/share/nginx/html/* &>> $LOGFILE

VALIDATE $? "Removing Default HTML Files.."

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE

VALIDATE $? "Downloading the artifacts.."

cd /usr/share/nginx/html &>> $LOGFILE

VALIDATE $? "Moving into default HTML Dir.."

unzip /tmp/web.zip &>> $LOGFILE

VALIDATE $? "Unzipping Artifacts.."

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE

VALIDATE $? "Copying Roboshop config.."

systemctl restart nginx &>> $LOGFILE

VALIDATE $? "Restarting Nginx"