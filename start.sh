#!/bin/bash

# Start the port number at 8000
PORT=8000

# Define the directory to check
DIR_NAME="q"

# Declare an array of processes
array=(
  "discovery" 
  "fx_rdb" 
  "fxopt_rdb" 
  "fx_hdb" 
  "fxopt_hdb" 
  "fx_rts" 
  "crypto_feed" 
  "taq_feed"
  )

# Check for a directory in the current working directory
if [ -d "$DIR_NAME" ]; then
  cd "$DIR_NAME"
  # Create the logs directory if it doesn't exist
  if [ ! -d logs ]; then
    mkdir logs
  else
    # Clear out the contents of the logs directory
    rm -rf logs/*
  fi
else
  echo "Directory $DIR_NAME not found in current working directory."
  exit 1
fi

# Loop through the array
for SERVICE in "${array[@]}"
do
  if [ "$SERVICE" == "discovery" ]; then
    echo -e "Starting the service $SERVICE as a background kdb+ process"
    nohup q init/init.q -service $SERVICE -heartbeat 0 </dev/null > logs/${SERVICE}.log 2>&1 &
  else
    echo -e "Starting the service $SERVICE as a background kdb+ process"
    nohup q init/init.q -service $SERVICE -heartbeat 1 -p $PORT </dev/null > logs/${SERVICE}.log 2>&1 &
  fi
  # Increment the port number by 1
  PORT=$((PORT + 1))
done

echo -e "Bringing up web ui container..."
docker-compose up -d
#Get private IP
private_ip=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')
echo -e "Please use the following connection details when using the web ui.... ${private_ip}:9090"
