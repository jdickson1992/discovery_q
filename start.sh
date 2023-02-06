#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No color

# Start the port number at 8000
PORT=8000

# Define the directory to check
DIR_NAME="q"

# Define a log directory
LOG_DIR=$(pwd)/logs

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

# Create the logs directory if it doesn't exist
if [ ! -d $LOG_DIR ]; then
    mkdir $LOG_DIR
else
   # Clear out the contents of the logs directory
    rm -rf ${LOG_DIR}/*
fi

# Check for a directory in the current working directory
if [ -d "$DIR_NAME" ]; then
  cd "$DIR_NAME"
else
  echo -e "${RED}Directory $DIR_NAME not found in current working directory.${NC}"
  exit 1
fi

# Check q command is set
#if ! command -v q > /dev/null; then
#  echo -e "${RED}q not found! Do you have it pointing at an alias?${NC}"
#  exit 1
#fi

# Loop through the array
for SERVICE in "${array[@]}"
do
  if [ "$SERVICE" == "discovery" ]; then
    echo -e "${YELLOW}Starting the service ${GREEN}$SERVICE${YELLOW} as a background kdb+ process${NC}"
    nohup rlwrap q -service $SERVICE -heartbeat 0 </dev/null > ${LOG_DIR}/${SERVICE}.log 2>&1 &
  else
    echo -e "${YELLOW}Starting the service ${GREEN}$SERVICE${YELLOW} as a background kdb+ process${NC}"
    nohup rlwrap q init/init.q -service $SERVICE -heartbeat 1 -p $PORT </dev/null > ${LOG_DIR}/${SERVICE}.log 2>&1 &
  fi
  # Increment the port number by 1
  PORT=$((PORT + 1))
done

echo -e "${BLUE}Bringing up web ui container...${NC}"
docker-compose up -d
#Get private IP
private_ip=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -n 1)
echo -e ""
echo -e "${GREEN}Please connect to the web UI on: ${BLUE}localhost:10000${NC}"
echo -e "${GREEN}When inside the UI, please connect to the discovery service using the the following handle: ${BLUE}${private_ip}:9090${NC}"
echo -e ""

# Reset the port number to 8000
PORT=8000

# Loop through the array and print out each item
for SERVICE in "${array[@]}"; do
  echo -e "${BLUE}Service: ${YELLOW}$SERVICE${BLUE} Port: ${YELLOW}$PORT${NC}"
  PORT=$((PORT + 1))
done