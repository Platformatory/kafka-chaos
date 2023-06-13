#!/bin/bash

# Check if the topic argument, interval argument, and mode argument are provided
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Error: Please provide a topic name, an interval (in minutes), and a mode ('leader' or 'isr') as arguments."
  echo "Usage: $0 <topic> <interval> <mode>"
  echo "  <topic>    : The Kafka topic name"
  echo "  <interval> : The interval in minutes"
  echo "  <mode>     : 'leader' to stop the leader broker, 'isr' to stop the ISR brokers"
  exit 1
fi

# Assign the topic argument, interval argument, and mode argument to variables
topic="$1"
interval_minutes="$2"
mode="$3"

# Validate the mode argument
if [[ "$mode" != "leader" && "$mode" != "isr" ]]; then
  echo "Error: Invalid mode argument. Mode must be either 'leader' or 'isr'."
  exit 1
fi

# Define the function to stop the Docker container
stop_docker_container() {
  docker_container="kafka$1"
  docker stop "$docker_container"
  echo "Broker $1 stopped at $(date +"%Y-%m-%d %H:%M:%S")"
}

# Define the function to extract topic information
extract_topic_info() {
  # Run the command and capture its output
  command_output=$(kafka-topics --bootstrap-server localhost:9092 --describe --topic "$topic")

  min_insync_replicas=$(echo "$command_output" | grep -oE 'Configs: min.insync.replicas=[^[:space:]]+' | awk -F "=" '{print $2}')
  leader_partition_0=$(echo "$command_output" | grep -oE 'Partition: 0\s+Leader: [^[:space:]]+' | awk '{print $NF}')
  isr_partitions=$(echo "$command_output" | grep -oE 'Partition: 0\s+Leader: \d+\s+Replicas: [[:digit:],]+\s+Isr: [^[:space:]]+' | awk '{print $NF}' | awk -F ',' '{for(i=1; i<=NF; i++) print $i}')

  if [[ "$mode" == "leader" ]]; then
    broker=$(echo "$leader_partition_0" | awk -F ':' '{print $NF}')
    stop_docker_container "$broker"
  elif [[ "$mode" == "isr" ]]; then
    for ((i=0; i<min_insync_replicas; i++))
    do
      broker=$(echo "$isr_partitions" | awk -F ':' '{print $1}' | sed -n "$((i+1))p")
      stop_docker_container "$broker"
    done
  fi
}

# Execute the script at the specified interval
while true; do
  echo "Running kafka chaos..."
  extract_topic_info
  sleep "$(($interval_minutes * 60))"
done
