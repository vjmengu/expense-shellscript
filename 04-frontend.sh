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

dnf installed nginx &>>$log_file

if [ $? -ne 0 ]
then
    dnf install nginx -y &>>$log_file
    validate $? "nginx installation"
    systemctl enable nginx &>>$log_file
    validate $? "enabling nginx"
else
    echo -e "nginx already installed...$Y Skipping $N)
fi

rm -rf /usr/share/nginx/html/* &>>$log_file
validate $? "removing existing html files"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$log_file
validate $? "Downloading Latest code"

cd /usr/share/nginx/html &>>$log_file
validate $? "moving to html directory"

unzip /tmp/frontend.zip &>>$log_file
validate $? "unzipped frontend html"

cp /home/ec2-user/expense-shellscript/expense.conf /etc/nginx/default.d/expense.conf &>>$log_file
validate $? " copied expense conf "

systemctl restart nginx &>>$log_file
validate $? " restarted nginx "