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

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE

VALIDATE $? "Setting up NPM source"

yum install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing NodeJS"


# once the user is created, if you run the script again it will fail during validation
# because user will be already present.
# Hence, First check the user is already present, if not then create the user.

# ROBOUSER=$(id roboshop)
# if [$ROBOUSER -ne 0]
# then
#     echo "Roboshop user is already available on your machine.." &>> $LOGFILE
#     exit 1
# else
#     useradd roboshop &>> $LOGFILE
#     echo "Roboshop user created..." &>> $LOGFILE

useradd roboshop &>> $LOGFILE


mkdir /app &>> $LOGFILE

VALIDATE $? "Creating /app dir.."

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "Donwloading user artifact.."

cd /app &>> $LOGFILE

VALIDATE $? "Moving into /app dir.."

unzip /tmp/user.zip &>> $LOGFILE

VALIDATE $? "Unzipping artifacts.."

npm install  &>> $LOGFILE

VALIDATE $? "Installing Dependencies.."

# give absolute path of user.service because we are inside /app
cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "Copying user.service file for creating service.."

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Reloading systemd to catch all services.."

systemctl enable user &>> $LOGFILE

VALIDATE $? "Enabling user Service.."

systemctl start user &>> $LOGFILE

VALIDATE $? "Starting user service.."

cp  /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copying mongo repository for mongo-shell.."

yum install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing Mongo Shell Client.."

mongo --host mongodb.bsebregistration.com </app/schema/user.js &>> $LOGFILE

VALIDATE $? "Loading user data into mongoDB.."