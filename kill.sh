#!/bin/bash

# Define the search string
search_string="init/init.q"

# Get a list of running processes
# messy - refactor later
processes=$(ps -ef | awk '{print $2 " " $8 " " $9 " " $10 " " $11 " " $12 " " $13 " " $14 " " $15 " " $16}')
# Store the PIDs of matching processes in an array
matching_pids=()
while read line; do
  command=$(echo $line | awk '{out="";for(i=2;i<=NF;i++){out=out" "$i}; print out}')
  pid=$(echo $line | awk '{print $1}')
  if [[ "$command" == *"$search_string"* ]]; then
    matching_pids+=($pid)
  fi
done <<< "$processes"

# Ask the user whether they want to kill all matching processes or just one random process
echo "Found ${#matching_pids[@]} matching processes."
echo "Kill all matching processes (a) or kill a random process (r)?"
read user_input

# Kill all matching processes or just one random process
if [[ "$user_input" == "a" ]]; then
  for pid in "${matching_pids[@]}"; do
    echo "Killing process with PID $pid"
    kill $pid
  done
  echo "Bringing down web ui container"
  docker-compose down
elif [[ "$user_input" == "r" ]]; then
  if [ ${#matching_pids[@]} -gt 0 ]; then
    random_index=$((RANDOM % ${#matching_pids[@]}))
    random_pid=${matching_pids[$random_index]}
    echo "Killing process with PID $random_pid"
    kill $random_pid
  else
    echo "No matching processes found."
  fi
else
  echo "Invalid input."
fi
