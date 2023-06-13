# Intro

This scaffold sets up 3 zookeepers and 5 kafka brokers. It contains a `chaos.sh` script to introduce deterministic chaos in the kafka cluster.


# How to use

1. First, boot up the cluster.

```bash
docker-compose up
```


2. Create a test topic.

```bash
kafka-topics --bootstrap-server localhost:9092 --topic first_topic --create --partitions 3 --replication-factor 2
```


3. Optionally, add min in sync replicas for the topic.

```bash
kafka-configs --bootstrap-server localhost:9092 --alter --entity-type topics --entity-name first_topic --add-config min.insync.replicas=2
```


4. Run the chaos script for this topic.


```bash
./chaos.sh first_topic 5 leader
```

This will bring down the broker containing the leader partition for `first_topic` every 5 minutes.

# Helpers

You can bring up a downed broker using this command:

```bash
docker-compose -f docker-compose.yml up kafka2 -d
```

Where `kafka2` was the downed broker.

# Scenarios

1. Take the leader out

Set unclean leader election to false.

Boot the cluster. Write producer and consumer in Java/Python/Golang which will produce/consume and handle errors and exceptions in a graceful manner.

While produce/consume happens, use the chaos script to bring the broker with the leader partition down.

Ensure the produce/consume cycle happens in spite of this.

2.

a. Take the min ISRs out

Set unclean leader election to true.

Boot the cluster. Write producer and consumer in Java/Python/Golang which will produce/consume and handle errors and exceptions in a graceful manner.

While produce/consume happens, use the chaos script to bring down the brokers with ISRs.

Ensure the produce/consume cycle happens in spite of this.

b. Take the min ISRs out

Set unclean leader election to true.

Boot the cluster. Write producer and consumer in Java/Python/Golang which will produce/consume and handle errors and exceptions in a graceful manner.

While produce/consume happens, use the chaos script to bring the broker with the leader partition down.

Ensure the produce/consume cycle happens in spite of this.

**NOTE** ensure `acks=all` for all the above scenarios.

3. Consumer chaos.

Boot the cluster. Write producer and consumer in Java/Python/Golang which will produce/consume and handle errors and exceptions in a graceful manner.

Use the chaos script to bring down leader broker of consumer_offsets topic.

Ensure that consumer handles this gracefully.

# TODO
1. Add grafana/prometheus metrics.
