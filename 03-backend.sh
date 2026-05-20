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
timestamp=$(date +%Y-%m-%d-%H-%M-%S)
log_file="$log_folder/$log_name-$timestamp.log"

validate(){

    if [ $1 -ne 0 ]
    then
    echo -e "$2 ....$R Failure $N"
    else
    echo -e "$2 ....$G Success $N"
    fi
}

echo " The script execution started at....$timestamp" &>>$log_file
check

dnf installed nodejs &>>$log_file
if [ $? -ne 0 ]
then
    dnf module disable nodejs -y &>>$log_file
    validate $? "nodejs disabling"
    dnf module  enable nodejs:20 -y &>>$log_file
    dnf install nodejs -y &>>$log_file
    validate $? "nodejs installation"
else
    echo -e " Nodjs already installed...$Y Skipping $N"
fi

id expense &>>$log_file
if [ $? -ne 0 ]
then
    useradd expense &>>$log_file
    validate $? "expense user adding"
else
    echo -e "Expense User already existing...$Y Skipping $N"
fi

mkdir -p /app

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$log_file
validate $? "Downloading backend"

cd /app &>>$log_file

rm -rf /app/* &>>$log_file

unzip /tmp/backend.zip &>>$log_file
validate $? "unziping backend"

npm install &>>$log_file
validate $? "npm install"

cp /home/ec2-user/expense-shellscript/backend.service /etc/systemd/system/backend.service &>>$log_file

dnf install mysql -y &>>$log_file
validate $? "mysql installation"

mysql -h mysql.gt650.online -u root -pExpenseApp@1 < /app/schema/backend.sql &>>$log_file
validate $? "schema setting to mysql data-base"

systemctl daemon-reload &>>$log_file
validate $? "backend service reloaded"


systemctl enable backend &>>$log_file
validate $? "backend enabling"

systemctl restart backend &>>$log_file
validate $? "backend restart"