FROM localhost:5000/hadoop-test 

# dev tools to build tez
RUN apt-get update
RUN apt-get install -y npm \
    && rm -rf /var/lib/apt/lists/*


#Protobuf install
ENV PROTOBUF_VERSION 2.5.0
ENV PROTOBUF_URL https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOBUF_VERSION/protobuf-$PROTOBUF_VERSION.tar.gz

RUN set -x && \
    curl -fSL $PROTOBUF_URL -o /tmp/protobuf.tar.gz && \
    tar xvfz /tmp/protobuf.tar.gz -C /usr/local/ && \
    rm /tmp/protobuf.tar.gz*
RUN cd /usr/local/protobuf-2.5.0 && ./configure &&  make && make install
RUN ldconfig

# to run bower as root
#RUN echo '{ "allow_root": true }' > /root/.bowerrc

# install maven
#ENV MAVEN_VERSION 3.2.2
#RUN curl -s http://archive.apache.org/dist/maven/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar -xz -C /usr/local/
#RUN cd /usr/local \
#    && ln -s apache-maven-${MAVEN_VERSION} maven
#ENV MAVEN_HOME /usr/local/maven
#ENV PATH $PATH:$MAVEN_HOME/bin

# download tez code, compile and copy jars
ENV TEZ_VERSION 0.7.1
ENV TEZ_HOME /usr/local/tez
#ENV TEZ_DIST /usr/local/tez/tez-dist/target/tez-${TEZ_VERSION}
ADD http://www.apache.org/dist/tez/${TEZ_VERSION}/apache-tez-${TEZ_VERSION}-bin.tar.gz /usr/local/
RUN cd /usr/local \
    && tar xvf apache-tez-${TEZ_VERSION}-bin.tar.gz \
    && ln -s /usr/local/apache-tez-${TEZ_VERSION}-bin ${TEZ_HOME} \
    && chown root -R /usr/local/apache-tez-${TEZ_VERSION}-bin \
    && rm -f apache-tez-${TEZ_VERSION}-bin.tar.gz
    
RUN $BOOTSTRAP \
    && $HADOOP_PREFIX/bin/hadoop dfsadmin -safemode leave \
    && $HADOOP_PREFIX/bin/hadoop fs -mkdir /tez \
    && $HADOOP_PREFIX/bin/hadoop fs -put ${TEZ_HOME}/*.jar /tez \
    && $HADOOP_PREFIX/bin/hadoop fs -put ${TEZ_HOME}/share/ /tez \
    && $HADOOP_PREFIX/bin/hadoop fs -put ${TEZ_HOME}/lib/ /tez \
    && $HADOOP_PREFIX/bin/hadoop fs -mkdir -p /tmp/logs/root/logs

# add tez specific configs
ADD tez-site.xml $HADOOP_PREFIX/etc/hadoop/tez-site.xml
ADD mapred-site.xml $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
ADD yarn-site.xml $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
ADD hdfs-site.xml $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml

# environment settings
RUN echo 'TEZ_JARS=/usr/local/tez/*' >> $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN echo 'TEZ_LIB=/usr/local/tez/lib/*' >> $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN echo 'TEZ_CONF=/usr/local/hadoop/etc/hadoop' >> $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN echo 'export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$TEZ_CONF:$TEZ_JARS:$TEZ_LIB' >> $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

# remove this later
ENV PATH $PATH:$HADOOP_PREFIX/bin

# execute hadoop bootstrap script
CMD ["/etc/bootstrap.sh", "-d"]
