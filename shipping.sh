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

yum install maven -y &>> $LOGFILE

VALIDATE $? "Installing Maven.."

useradd roboshop  &>> $LOGFILE

mkdir /app &>> $LOGFILE

VALIDATE $? "Creating /app dir.."

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "Downloading Shipping Artifacts.."

cd /app &>> $LOGFILE

VALIDATE $? "Moving into /app dir.."

unzip /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "Unzipping Artifacts.."

mvn clean package &>> $LOGFILE

VALIDATE $? "Packaging Shipping app.."

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? "Renaming shipping jar.."

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "Copying Shipping service.."

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Reloading Systemctl.."

systemctl enable shipping  &>> $LOGFILE

VALIDATE $? "Enabling Shipping.."

systemctl start shipping &>> $LOGFILE

VALIDATE $? "Starting Shipping.."

yum install mysql -y &>> $LOGFILE

VALIDATE $? "Installing MySql Client.."

mysql -h mysql.bsebregistration.com -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>> $LOGFILE

VALIDATE $? "Loading Countries and Cities Info.."

systemctl restart shipping &>> $LOGFILE

VALIDATE $? "Restarting Shipping Service.."