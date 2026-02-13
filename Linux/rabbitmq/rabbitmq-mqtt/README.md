# RabbitMQ (single node) with MQTT via Docker Compose

## Ports
- AMQP: 5672
- Management UI: 15672
- MQTT: 1883
- MQTT over WebSockets (optional): 15675

## Start
```bash
mkdir -p data
docker compose up -d
```

## Verify plugins
```bash
docker exec -it rabbitmq rabbitmq-plugins list | egrep "rabbitmq_mqtt|rabbitmq_web_mqtt"
```

## Management UI
- http://localhost:15672
- user/pass: admin / admin123456

## MQTT test (mosquitto_pub/sub)
Subscribe:
```bash
mosquitto_sub -h 127.0.0.1 -p 1883 -u admin -P admin123456 -t test/topic
```

Publish:
```bash
mosquitto_pub -h 127.0.0.1 -p 1883 -u admin -P admin123456 -t test/topic -m "hello"
```

## Stop
```bash
docker compose down
```

## Clean data (DANGER)
```bash
docker compose down
rm -rf ./data
```

## Subnet overlap
If you see `Pool overlaps with other one on this address space`, change subnet in docker-compose.yml to e.g. 10.66.0.0/16.


docker网络内部访问一般看的是 service name / container_name（Compose DNS），不是 hostname
