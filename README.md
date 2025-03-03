# POC CDC Oracle x Debezium x Kafka

## Containers

### Criar a rede
```bash
podman network create cdc-network
```

### Cria os storages
```bash
podman volume create kafka_connect_data
podman volume create oracle_data
```

### Iniciar o container Oracle
```bash
podman run -d --name oracle-xe ^
  --network cdc-network ^
  -e ORACLE_PWD=oracle ^
  -e ORACLE_CHARACTERSET=AL32UTF8 ^
  -p 1521:1521 ^
  -p 5500:5500 ^
  -v oracle_data:/opt/oracle/oradata ^
  -v /c/fontes/clientes/eu/podman-cdc-oracle-kafka/oracle-scripts:/opt/oracle/scripts ^
  container-registry.oracle.com/database/express:21.3.0-xe
```

### Iniciar o container Zookeeper
```bash 
podman run -d --name zookeeper ^
  --network cdc-network ^
  -e ZOOKEEPER_CLIENT_PORT=2181 ^
  -p 2181:2181 ^
  confluentinc/cp-zookeeper:7.4.0
```

### Iniciar o container Kafka
```bash 
podman run -d --name kafka ^
  --network cdc-network ^
  -e KAFKA_BROKER_ID=1 ^
  -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 ^
  -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka:9092 ^
  -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 ^
  -p 9092:9092 ^
  confluentinc/cp-kafka:7.4.0
```

### Iniciar o container Kafka Connect
```bash 
podman run -d --name kafka-connect ^
  --network cdc-network ^
  -e BOOTSTRAP_SERVERS=kafka:9092 ^
  -e GROUP_ID=1 ^
  -e CONFIG_STORAGE_TOPIC=connect-configs ^
  -e OFFSET_STORAGE_TOPIC=connect-offsets ^
  -e STATUS_STORAGE_TOPIC=connect-status ^
  -e KEY_CONVERTER=org.apache.kafka.connect.json.JsonConverter ^
  -e VALUE_CONVERTER=org.apache.kafka.connect.json.JsonConverter ^
  -p 8083:8083 ^
  -v kafka_connect_data:/kafka/connect ^
  -v /c/fontes/clientes/eu/podman-cdc-oracle-kafka/debezium-libs/ojdbc11.jar:/kafka/libs/ojdbc11.jar ^
  debezium/connect:2.5
```

## Execução

### Passo 1 - Executar procedimento com o banco de dados (Habilita CDC e cria usuário)
```bash 
podman exec -it oracle-xe sqlplus sys/oracle@localhost:1521/XEPDB1 as sysdba @/opt/oracle/scripts/oracle-setup.sql
```

### Passo 2 - Registrar o connector no Kafka
```bash 
chmod +x register_connector.sh
./register_connector.sh
```

### Testando a Replicação, criando uma tabela nova e inserindo dados
```bash 
podman exec -it oracle-xe sqlplus C##cdc_user/cdc_password@localhost:1521/XEPDB1 @/opt/oracle/scripts/create-table.sql
```

#### Database UI
```bash
podman run -d --name adminer --network cdc-network -p 8081:8080 -e ADMINER_DEFAULT_SERVER=oracle-xe -e ADMINER_DESIGN=nette docker.io/library/adminer:latest
```

### Verificar a replicação no Kafka
```bash 
podman exec -it kafka kafka-console-consumer --bootstrap-server kafka:9092 --topic oracle-cdc.C__CDC_USER.TABLE_EXAMPLE --from-beginning
```
#### Kafka-UI
```bash
podman run -d --name kafka-ui --network cdc-network -p 8080:8080 -e KAFKA_CLUSTERS_0_NAME=cdc-cluster -e KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=kafka:9092 provectuslabs/kafka-ui:latest
```

