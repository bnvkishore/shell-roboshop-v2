#!/bin/bash

app_name=catalogue
source ./common.sh
check_root

app_setup
nodejs_setup
syetemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
VALIDATE $? "Added mongo repo"

dnf install mongodb-mongosh -y &>>$LOGS_FILE
VALIDATE $? "Installed MongoDB client"

INDEX=$(mongosh --host mongodb.daws90.shop --eval 'db.getMongo().getDBNames().indexOf("catalogue")') &>>$LOGS_FILE
if [ $INDEX -lt 0 ]; then
    mongosh --host mongodb.daws90.shop </app/db/master-data.js &>>$LOGS_FILE
    VALIDATE $? "Load products"
else 
    echo -e "Products alread loaded ... $Y SKIPPING $N"
fi

app_restart

print_total_time