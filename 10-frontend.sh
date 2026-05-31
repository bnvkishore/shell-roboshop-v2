#!/bin/bash
app_name="frontend"
source ./common.sh
check_root

dnf module disable nginx -y &>>$LOGS_FILE
dnf module enable nginx:1.24 -y &>>$LOGS_FILE
dnf install nginx -y &>>$LOGS_FILE
VALIDATE $?  "Installing nginx server"

rm -rf /usr/share/nginx/html/* 
VALIDATE $?  "Removed defalut code"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $?  "Downloaded and extracted frontend code"

rm -rf /etc/nginx/nginx.conf
VALIDATE $?  "Removed Default conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $?  "Copied roboshop nginx conf"

systemctl enable nginx &>>$LOGS_FILE
systemctl restart nginx 
VALIDATE $? "Enable and restart nginx"

print_total_time


