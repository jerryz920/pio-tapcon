#!/bin/bash
export PIO_VERSION=0.11.0
export SPARK_VERSION=2.1.0
export ELASTICSEARCH_VERSION=1.4.4

export PIO_HOME=/opt/PredictionIO-${PIO_VERSION}-incubating
export PATH=${PIO_HOME}/bin:$PATH
service mysql start

# configure mysql-router
MY_IP=`ifconfig eth0 | awk '/inet addr/{print substr($2,6)}'`
ABAC_ID=${ABAC_ID:-$MY_IP:1985:abac}
ABAC_PID=${ABAC_PID:-"$MY_IP:1985"}
ABAC_PORT=${ABAC_PORT:-7777}
ABAC_HOST=${ABAC_HOST:-10.10.1.9}

curl http://10.10.1.9:7777/postImageProperty -d "{ \"principal\": \"10.10.1.36:1985\", \"otherValues\": [\"e9688bac9f0cd7eccac26825d50e9e17c9912a61\", \"https://github.com/jerryz920/incubator-predictionio-template-attribute-based-classifier\"] }"
curl http://10.10.1.9:7777/postObjectAcl -d "{ \"principal\": \"10.10.1.36:1985\",  \"otherValues\": [\"10.10.1.36:PIO\", \"https://github.com/jerryz920/incubator-predictionio-template-attribute-based-classifier\"] }"


if [ -z $ABAC_HOST ]; then
  echo "must specify ABAC_HOST"
  exit 1
fi


sed -e 's/MY_IP/'$MY_IP'/' -e 's/ABAC_ID/'$ABAC_ID'/' -e 's/ABAC_PID/'$ABAC_PID'/' -e 's/ABAC_HOST/'$ABAC_HOST'/' -e 's/ABAC_PORT/'$ABAC_PORT'/' -e 's/localhost/127.0.0.1/' -e 's/read-only/read-write/' /opt/mysql-router/default-config > /opt/mysql-router-config

mysqlrouter -c /opt/mysql-router-config &

# configure spark cluster

if [ -z SPARK_HOST ]; then
  echo "must specify SPARK_HOST"
  exit 2
fi

echo "$SPARK_HOST:7070" > /spark-discovery
echo "0.0.0.0 predictionio" >> /etc/hosts

pio-start-all

mgmt-proxy pio &
