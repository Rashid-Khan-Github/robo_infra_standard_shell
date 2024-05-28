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

yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y  &>> $LOGFILE

VALIDATE $? "Installing Redis Repository.."

yum module enable redis:remi-6.2 -y  &>> $LOGFILE

VALIDATE $? "Choosing Redis 6.2 from repository.."

yum install redis -y  &>> $LOGFILE

VALIDATE $? "Installing Redis 6.2.."

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf /etc/redis/redis.conf  &>> $LOGFILE

VALIDATE $? "Allowing any remote connections to redis.."

systemctl enable redis  &>> $LOGFILE

VALIDATE $? "Enabling Redis.."

systemctl start redis  &>> $LOGFILE

VALIDATE $? "Starting Redis.."
