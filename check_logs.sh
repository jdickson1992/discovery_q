#!/bin/bash

# Define the logs directory
LOG_DIR=$(pwd)/logs

# Check if the logs directory exists
if [ ! -d "$LOG_DIR" ]; then
  echo "The logs directory does not exist."
  exit 1
fi

# Get a list of service names
services=($(ls $LOG_DIR | sed 's/.log//g'))

# Present the service names to the user
echo "Available services:"
for i in "${!services[@]}"; do
  echo "$((i + 1)). ${services[i]}"
done

# Ask the user to choose a service
read -p "Choose a service to check the logs for [select a number]: " choice

# Get the chosen service name
chosen_service=${services[choice-1]}

# Check if the chosen service exists
if [ ! -f "$LOG_DIR/$chosen_service.log" ]; then
  echo "The chosen service does not exist."
  exit 1
fi

# Tail the logs for the chosen service
echo -e "Tailing logs for the service $chosen_service:\n"
tail -f "$LOG_DIR/$chosen_service.log"
