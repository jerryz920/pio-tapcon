#!/bin/bash
export PIO_VERSION=0.11.0
export SPARK_VERSION=2.1.0
export ELASTICSEARCH_VERSION=1.4.4

export PIO_HOME=/opt/PredictionIO-${PIO_VERSION}-incubating
export PATH=${PIO_HOME}/bin:$PATH
service mysql start

# configure mysql-router
MY_IP=`ifconfig eth0 | awk '/inet addr/{print substr($2,6)}'`
# This is the object to test
ABAC_ID=${ABAC_ID:-alice:pio-obj}
ABAC_PID=${ABAC_PID:-"152.3.145.138:4144"}
ABAC_PORT=${ABAC_PORT:-19851}
ABAC_HOST=${ABAC_HOST:-10.10.1.39}
ABAC_TEST_PORT=${ABAC_TEST_PORT:-0}
ABAC_TEST_IP=${ABAC_TEST_IP:-10.10.1.41}
IMAGE_ID=${DOCKER_IMAGE:noimage}

curl http://10.10.1.39:19851/postImageProperty -d "{ \"principal\": \"152.3.145.38:444\", \"otherValues\": [\"sparkimg\", \"*\", \"pio\"] }"
curl http://10.10.1.39:19851/postObjectAcl -d "{ \"principal\": \"alice\",  \"otherValues\": [\"alice:pio-obj\", \"pio\"] }"


if [ -z $ABAC_HOST ]; then
  echo "must specify ABAC_HOST"
  exit 1
fi

cd /opt/mysql-router
git pull origin dev

cd /opt/mysql-router && git pull origin dev && mkdir -p build
  cd build && cmake .. && \
  make -j && \
  make install

sed -e 's/MY_IP/'$MY_IP'/' -e 's/ABAC_ID/'$ABAC_ID'/' -e 's/ABAC_PID/'$ABAC_PID'/' -e 's/ABAC_HOST/'$ABAC_HOST'/' -e 's/ABAC_PORT/'$ABAC_PORT'/' -e 's/localhost/127.0.0.1/' -e 's/read-only/read-write/' /opt/mysql-router/default-config > /opt/mysql-router-config
sed -i 's/abac_enabled = 0/abac_enabled = 1/' /opt/mysql-router-config
# dont use these now
echo "abac_test_port = $ABAC_TEST_PORT" >> /opt/mysql-router-config
echo "abac_test_ip = $ABAC_TEST_IP" >> /opt/mysql-router-config

mysqlrouter -c /opt/mysql-router-config &

# configure spark cluster

if [ -z SPARK_HOST ]; then
  echo "must specify SPARK_HOST"
  exit 2
fi

echo "$SPARK_HOST:7070" > /spark-discovery
echo "0.0.0.0 predictionio" >> /etc/hosts

pio-start-all

mgmt-proxy pio 
