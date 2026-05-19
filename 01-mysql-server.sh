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

dnf list installed mysql-server
if [ $? -ne 0 ]
then
    dnf install mysql-server -y
    validate $? "Mysql-server installation"
else
    echo " mysql-server already installed "
fi

systemctl enable mysqld
validate $? "mysql enable"
systemctl start mysqld
validate $? "mysql start"

mysql -h 13.217.226.103 -u root -pExpenseApp@1 -e 'show databases;'
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1
    validate $? "setting root password"
else
    echo " mysql-server password already set "
fi