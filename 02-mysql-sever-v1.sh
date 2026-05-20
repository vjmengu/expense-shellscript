check() {
USER=$(id -u)
if [ $USER -ne 0 ]
then
    echo " Sudo access needed to run this script "
    exit 1
fi
}

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

mkdir -p /var/log/expense-logs
LOGFOLDER="/var/log/expense-logs"
FILE_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGFOLDER/$FILE_NAME-$TIMESTAMP.log"

validate(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ....$R Failluer $N"
    else
        echo -e "$2 ....$G Success $N"
    fi
}

check

echo "Script started execution....$TIMESTAMP" &>>$LOG_FILE

dnf installed mysql-server &>>$LOG_FILE
if [ $? -ne 0 ]
then
    dnf install mysql-server -y &>>$LOG_FILE
    validate $? "mysql-server installation"
else
    echo -e "$Y mysql-server already installed $N"
fi

systemctl start mysqld &>>$LOG_FILE
validate $? "$Y mysql-server started $N"

systemctl enable mysqld &>>$LOG_FILE
validate $? "$Y mysql-sever enabled $N"

mysql -h mysql.gt650.online -u root -pExpenseApp@1 -e "show databases;" &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
    validate $? "password setting"
else
    echo "$Y mysql password already set Skipping $N"
fi
