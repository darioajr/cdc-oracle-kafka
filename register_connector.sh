#!/bin/bash

curl -X POST "http://localhost:8083/connectors" -H "Content-Type: application/json" -d '{
  "name": "oracle-cdc",
  "config": {
    "connector.class": "io.debezium.connector.oracle.OracleConnector",
    "tasks.max": "1",
    "database.hostname": "oracle-xe",
    "database.port": "1521",
    "database.user": "C##cdc_user",
    "database.password": "cdc_password",
    "database.dbname": "XEPDB1",
    "database.pdb.name": "XEPDB1",
    "database.server.name": "oracle-xe",
    "database.history.kafka.bootstrap.servers": "kafka:9092",
    "database.history.kafka.topic": "schema-changes",
    "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
    "schema.history.internal.kafka.topic": "schema-changes",
    "table.include.list": "C##CDC_USER.TABLE_EXAMPLE",
    "log.mining.strategy": "online_catalog",
    "topic.prefix": "oracle-cdc",
    "database.connection.adapter": "logminer",
    "database.connection.url": "jdbc:oracle:thin:@oracle-xe:1521/XEPDB1"
  }
}'
