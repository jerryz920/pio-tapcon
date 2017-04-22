#!/bin/bash
export PIO_VERSION=0.11.0
export SPARK_VERSION=2.1.0
export ELASTICSEARCH_VERSION=1.4.4

export PIO_HOME=/opt/PredictionIO-${PIO_VERSION}-incubating
export PATH=${PIO_HOME}/bin:$PATH
service mysql start

# configure spark cluster

if [ -z SPARK_HOST ]; then
  echo "must specify SPARK_HOST"
  exit 2
fi

echo "$SPARK_HOST:7070" > /spark-discovery
echo "0.0.0.0 predictionio" >> /etc/hosts

pio-start-all

mgmt-proxy pio &

