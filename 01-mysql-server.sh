#!/bin/bash

user=$(id -u)
if [ $user -ne 0 ]
then
    echo " Sudo access needed to execute this script "
    exit 1
fi

validate (){
    if [ $1 -ne 0 ]
    then
        echo " $2....Failure "
    else
        echo " $2....Success"
    fi
}

mkdir -p /var/log/expense-log

log_folder="/var/log/expense-log"
logfile=$(echo $0)
file_name=$(echo $logfile | cut -d "." -f1)
timestamp=$(date +%Y-%m-%d-%H-%M-%S)
final_log="$log_folder/$file_name-$timestamp.log"
echo "script started executing at $timestamp" &>>$final_log

dnf list installed mysql-server &>>$final_log
if [ $? -ne 0 ]
then
    dnf install mysql-server -y &>>$final_log
    validate $? "Mysql-server installation"
else
    echo " mysql-server already installed "
fi

systemctl enable mysqld &>>$final_log
validate $? "mysql enable"
systemctl start mysqld &>>$final_log
validate $? "mysql start"

mysql -h 13.217.226.103 -u root -pExpenseApp@1 -e 'show databases;' &>>$final_log
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1
    validate $? "setting root password"
else
    echo " mysql-server password already set "
fi