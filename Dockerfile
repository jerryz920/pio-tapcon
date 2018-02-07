FROM ubuntu

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

RUN apt-get update && apt-get install -y python-dev python-pip git

RUN apt-get update \
    && apt-get install -y --auto-remove --no-install-recommends curl openjdk-8-jdk libgfortran3 python-pip \
        && apt-get clean \
	    && rm -rf /var/lib/apt/lists/*

# Install MySQL.
RUN \
  apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server && \
    rm -rf /var/lib/apt/lists/* && \
				sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf && \
				sed -i 's/^\(log_error\s.*\)/# \1/' /etc/mysql/my.cnf && \
				mkdir -p /var/run/mysqld && \
				chown mysql:mysql /var/run/mysqld && \
				echo "mysqld_safe &" > /tmp/config && \
				echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config && \
				echo "mysql -e 'GRANT ALL PRIVILEGES ON *.* TO \"root\"@\"%\" WITH GRANT OPTION;'" >> /tmp/config && \
				echo "mysql -e 'CREATE DATABASE pio;'" >> /tmp/config && \
				echo "mysql -e 'GRANT ALL PRIVILEGES ON pio.* TO \"pio\"@\"%\" identified by \"pio\" WITH GRANT OPTION;'" >> /tmp/config && \
				echo "mysql -e 'GRANT ALL PRIVILEGES ON pio.* TO \"pio\"@\"localhost\" identified by \"pio\" WITH GRANT OPTION;'" >> /tmp/config && \
				bash /tmp/config && \
				rm -f /tmp/config

# Install MySQL-router for external access, and with ABAC control
RUN apt-get update && apt-get install -y sudo vim net-tools ssh wget build-essential libmysql-java libmysqlclient-dev cmake && \
	pip install setuptools && pip install MySQL-python 
RUN apt-get install libcurl4-openssl-dev
RUN git clone https://github.com/jerryz920/mysql-router /opt/mysql-router && \
	cd /opt/mysql-router && git checkout -b dev --track remotes/origin/dev && mkdir build && \
	cd build && cmake .. && \
	make -j && \
	make install


ENV PIO_VERSION 0.11.0
ENV SPARK_VERSION 2.1.0
ENV ELASTICSEARCH_VERSION 1.4.4

ENV PIO_HOME /opt/PredictionIO-${PIO_VERSION}-incubating
ENV PATH=${PIO_HOME}/bin:$PATH

# build PIO from source with 
RUN git clone https://github.com/apache/incubator-predictionio.git pio-src && \
    cd pio-src && git checkout release/0.11.0 && \
    ls && ./make-distribution.sh -Dscala.version=2.11.8 -Dspark.version=2.1.0 -Delasticsearch.version=1.4.4 && \
    mv PredictionIO-0.11.0-incubating.tar.gz /opt/ && \
    cd /opt/ && \
    tar xf PredictionIO-0.11.0-incubating.tar.gz

# do we really need this when using standalone cluster?
RUN cd /opt/PredictionIO-0.11.0-incubating/ && mkdir vendors && cd vendors && \
	wget http://d3kbcqa49mib13.cloudfront.net/spark-2.1.0-bin-hadoop2.6.tgz && \
	tar xf spark-2.1.0-bin-hadoop2.6.tgz && \
	wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.4.tar.gz && \
	tar xf elasticsearch-1.4.4.tar.gz && \
        echo "cluster.name: predictionio" >> elasticsearch-1.4.4/config/elasticsearch.yml && \
	echo "network.host: 127.0.0.1">> elasticsearch-1.4.4/config/elasticsearch.yml

# set up a template
RUN mkdir /pioapp && cd /pioapp/ && git clone https://github.com/jerryz920/incubator-predictionio-template-attribute-based-classifier.git . && \
	git checkout pio-0.11.0 && \
	sed -i "s/test6/classify/" engine.json 
 

# Define mountable directories.
VOLUME ["/etc/mysql", "/var/lib/mysql"]

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["/opt/all.sh"]
EXPOSE 3307
EXPOSE 7070

COPY files/pio-env.sh ${PIO_HOME}/conf/pio-env.sh

RUN git clone https://github.com/jerryz920/webcli /opt/webcli && \
	cd /opt/webcli/ && \
	pip install setuptools && \
	pip install -r requirements.txt && \
	python setup.py install

RUN pip install predictionio
	 #pio template get apache/incubator-predictionio-template-similar-product MySimilarProduct --version "" --name "" --package "" --email ""
COPY all.sh /opt/
COPY old.sh /opt/
EXPOSE 4040
RUN cd /pioapp && git pull origin pio-0.11.0

ENTRYPOINT ["/bin/bash", "-c"]

