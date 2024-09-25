#!/bin/bash

#SSH into the Application Server
app_server_username="ubuntu"
app_server_ip="10.0.0.108"
ssh_key_path="/home/ubuntu/.ssh/WL4keys.pem"
file_path="/home/ubuntu/start_app.sh"

#Make sure the ssh key has the correct permissions
chmod 600 "$APP_SERVER_SSH_KEY"


# SSH into the Application Server and run the start_app.sh script
ssh -i "$APP_SERVER_SSH_KEY" "$APP_SERVER_USER@$APP_SERVER_IP" "bash $START_APP_SCRIPT_PATH"

