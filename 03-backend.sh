#!/bin/bash
check(){
USER=$(id -u)
if [ $USER -ne 0 ]
then
    echo "Sudo access needed to run this script"
    exit 1
fi
}

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

mkdir -p "/var/log/expense-logs"
log_folder="/var/log/expense-logs"
log_name=$(echo $0 | cut -d "." -f1)
timstamp=$(date +%Y-%m-%d-%H-%M-%S)
log_file="$log_folder/$log_name-$timestamp.log"

validate(){

    if [ $1 -ne 0 ]
    then
    echo -e "$2 ....$R Failure $N"
    else
    echo -e "$2 ....$G Success $N"
    fi
}

echo " The script execution started at....$timestamp"
check

dnf installed nodejs
if [ $? -ne 0 ]
then
    dnf module disable nodejs
    validate $? "nodejs disabling"
    dnf install nodejs:20 -y
    validate $? "nodejs installation"
else
    echo -e " Nodjs already installed...$Y Skipping $N"
fi

id expense
if [ $? -ne 0 ]
then
    useradd expense
    validate $? "expense user adding"
else
    echo -e "Expense User already existing...$Y Skipping $N"
fi

mkdir -p /app

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
validate $? "Downloading backend"

cd /app

rm -rf /app/*

unzip /tmp/backend.zip
validate $? "unziping backend"

npm install
validate $? "npm install"

cp /home/ec2-user/expense-shellscript/backend.service /etc/systemd/system/backend.service

dnf install mysql
validate $? "mysql installation"

mysql -h mysql.gt650.online -u root -pExpenseApp@1 < /app/schema/backend.sql
validate $? "schema setting to mysql data-base"

systemctl daemon-reload
validate $? "backend service reloaded"


systemctl enable backend
validate $? "backend enabling"

systemctl restart backend
validate $? "backend restart"