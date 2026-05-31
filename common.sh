#!/bin/bash

LOGS_DIR="/var/logs/roboshop"

sudo mkdir -p $LOGS_DIR
sudo chown -R ec2-user:ec2-user $LOGS_DIR
sudo chmod -R 755 $LOGS_DIR
LOGS_FILE="$LOGS_DIR/$0.log"
SCRIPT_DIR=$PWD

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date "+%Y-%m-%d %h:%M:%S")

echo -e "$TIMESTAMP [INFO] Script started"

check_root() {
    if [ $USERID -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $R Please run this script with root access $N" | tee -a $LOGS_FILE
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$TIMESTAMP [INFO] $2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

print_total_time(){
    echo -e "$TIMESTAMP [INFO] Script executed in $G $SECONDS seconds $N"
}

app_setup(){
    id roboshop &>>$LOGS_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
        VALIDATE $? "Creating roboshop system user"
    else
        echo -e "System user roboshop already created ... $Y SKIPPING $N"
    fi

    rm -rf /app 
    VALIDATE $? "Removing existing folder"

    rm -rf /tmp/$app_name.zip
    VALIDATE $? "Remove $app_name zip"

    mkdir -p /app &>>$LOGS_FILE
    VALIDATE $? "Creating app directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOGS_FILE
    cd /app 
    unzip /tmp/$app_name.zip &>>$LOGS_FILE
    VALIDATE $? "Downloaded and extracted $app_name code"
}

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOGS_FILE
    dnf module enable nodejs:20 -y &>>$LOGS_FILE
    dnf install nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Installing nodejs 20"
    npm install &>>$LOGS_FILE
    VALIDATE $? "Installing dependencies"
}

syetemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service &>>$LOGS_FILE
    VALIDATE $? "Created systemctl service"
    systemctl daemon-reload 
    systemctl enable $app_name &>>$LOGS_FILE
    VALIDATE $? "Enabled $app_name"
}

app_restart(){
    systemctl restart $app_name &>>$LOGS_FILE
    VALIDATE $? "$app_name restarting"
}

java_setup(){
    dnf install maven -y &>>$LOGS_FILE
    VALIDATE $? "Installing Maven"

    mvn clean package &>>$LOGS_FILE
    mv target/shipping-1.0.jar shipping.jar &>>$LOGS_FILE
    VALIDATE $? "Installing dependencies"
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
    VALIDATE $? "Installing Python"

    pip3 install -r requirements.txt &>>$LOGS_FILE
    VALIDATE $? "Installing dependencies"
}