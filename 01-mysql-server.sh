#!/bin/bash

user=$(id -u)
if [ $user -ne 0 ]
then
    echo " Sudo access needed to execute this script "
    exit 1
fi

dnf list installed mysql-server
if [ $? -ne 0 ]
then
    dnf install mysql-server -y
    if [ $? -ne 0 ]
    then
        echo " Mysql-server installation....Failure "
    else
        echo " Mysql-server installation....Success"
    fi
else
    echo " mysql-server already installed "
fi

systemctl enable mysqld
if [ $? -ne 0 ]
then
    echo " mysql enable failure "
else
    echo " mysql enable success "
fi
systemctl start mysqld
if [ $? -ne 0 ]
then
    echo " mysql start failure "
else
    echo " mysql start success "
fi

mysql_secure_installation --set-root-pass ExpenseApp@1
if [ $? -ne 0 ]
then
    echo " setting root password failure "
else
    echo " setting root password success "
fi