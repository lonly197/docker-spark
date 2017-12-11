FROM lonly/docker-alpine-python:3.6.3-slim

ARG VERSION=2.2.1-slim
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

FROM lonly/docker-alpine-java:openjdk-8u131

# Define spark environment
ENV SPARK_HOME=/usr/local/spark \
    SPARK_CONF_DIR=${SPARK_HOME}/conf \
    PYTHONPATH=${SPARK_HOME}/python \
    PATH=${PATH}:${SPARK_HOME}/bin:${PYTHONPATH}:${PYTHONPATH}/python/lib/py4j-0.9-src.zip

# Install Spark Package
RUN set -x \
    ## Define variant
    && SPARK_VERSION=2.2.1 \
    && HADOOP_VERSION=2.7 \
    ## Install base dependency lib 
    # && apk add --no-cache --upgrade --virtual=build-dependencies openssl ca-certificates tar \
    # && update-ca-certificates \
    ## Download spark bin
    && wget http://mirrors.hust.edu.cn/apache/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && tar -zxvf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /tmp \
    && mv /tmp/spark-* ${SPARK_HOME} \
    ## Clean
    # && apk del build-dependencies \
    && rm -rf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz\
    && rm -rf /root/.cache \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

## Setting Environment
RUN set -x \
    ## Add profile
    && env \
       | grep -E '^(JAVA|HADOOP|PATH|YARN|SPARK|PYTHON)' \
       | sed 's/^/export /g' \
       > ~/.profile \
    && cp ~/.profile /etc/profile.d/spark \
    && sed -i 's@${JAVA_HOME}@'${JAVA_HOME}'@g' ${SPARK_HOME}/bin/load-spark-env.sh \
    ## Chmod user permission
    && chown -R root:root ${SPARK_HOME} \
    ## Make soft link
    && ln -s ${SPARK_CONF_DIR} /etc/spark \
    ## Clean
    && rm -rf /root/.cache \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

WORKDIR ${SPARK_HOME}