FROM lonly/docker-alpine-python:3.6.3

ARG VERSION=2.2.0
ARG BUILD_DATE
ARG VCS_REF

LABEL \
    maintainer="lonly197@qq.com" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.license="Apache License 2.0" \
    org.label-schema.name="lonly/docker-spark" \
    org.label-schema.url="https://github.com/lonly197" \
    org.label-schema.description="Spark Docker Image based on Alpine Linux which is optimized for containers and light-weight." \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/lonly197/docker-spark" \
    org.label-schema.vcs-type="Git" \
    org.label-schema.vendor="lonly197@qq.com" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0"

# Install Python Package
RUN set -x \
    && pip install --upgrade --no-cache-dir \
        py4j \
    ## Clean
    && rm -rf /root/.cache \
    && rm -rf *.tgz *.tar *.zip \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

FROM lonly/docker-hadoop:2.9.0

ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*" \
    PATH=$PATH:$SPARK_HOME/bin

# Install Spark Package
RUN set -x \
    ## Download hadoop bin
    && mirror_url=$( \
        wget -q -O - "http://www.apache.org/dyn/closer.cgi/?as_json=1" \
        | grep "preferred" \
        | sed -n 's#.*"\(http://*[^"]*\)".*#\1#p' \
        ) \
    && wget -q -O - ${mirror_url}/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
        | tar -xzf - -C /tmp \
    && mv /tmp/hadoop-* ${HADOOP_HOME} \
    ## Make soft link
    && ln -s HADOOP_CONF_DIR /etc/hadoop \
    && ln -s /usr/local/hadoop-${HADOOP_VERSION} /usr/local/hadoop-${HADOOP_VERSION%.*} \