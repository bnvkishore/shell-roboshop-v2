#!/bin/bash

app_name="shipping"
source ./common.sh
check_root
app_setup
java_setup
syetemd_setup

dnf install mysql -y &>>$LOGS_FILE
VALIDATE $? "Installing mysql client"

mysql -h $MYSQL_HOST -u root -pRoboShop@1 -e "use cities" &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOGS_FILE
    VALIDATE $? "Data loaded successfully"
else
    echo -e "Data already loaded ... $Y SKIPPING $N"
fi

app_restart
print_total_time