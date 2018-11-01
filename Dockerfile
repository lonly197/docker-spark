FROM openjdk:8u181-jdk-alpine3.8

ARG VERSION=2.3.2-slim
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

# Define spark environment
ENV SPARK_HOME=/usr/local/spark \
    SPARK_CONF_DIR=${SPARK_HOME}/conf \
    PYTHONPATH=${SPARK_HOME}/python \
    PATH=${PATH}:${SPARK_HOME}/bin:${PYTHONPATH}:${PYTHONPATH}/python/lib/py4j-0.10.7-src.zip

# Install Spark Package
RUN set -x \
    ## Define variant
    && SPARK_VERSION=2.3.2 \
    && HADOOP_VERSION=2.7 \
    ## Download spark bin
    && mirror_url=$( \
    wget -q -O - "http://www.apache.org/dyn/closer.lua/?as_json=1" \
    | grep "preferred" \
    | sed -n 's#.*"\(http://*[^"]*\)".*#\1#p' \
    ) \
    && wget ${mirror_url}spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
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

# Define python environment 
ENV	PATH=/usr/local/bin:$PATH \
    ## http://bugs.python.org/issue19846
    ## > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
    LANG=C.UTF-8

# Install python
RUN	set -x \
    ## Update apk
    && apk update \
    ## Define Variant
    && PYTHON_VERSION=3.6.3-r9 \	
    ## Install Python package
    && apk add --no-cache --upgrade --virtual=build-dependencies --repository http://mirrors.ustc.edu.cn/alpine/v3.6/edge/ --allow-untrusted python3 \
    && python3 -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    && pip3 install --upgrade pip setuptools \
    && if [[ ! -e /usr/bin/pip ]]; then ln -s pip3 /usr/bin/pip ; fi \
    && if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi \
    ## Install py4j
    && pip install --upgrade --no-cache-dir py4j \
    ## Cleanup
    && apk del build-dependencies \
    && rm -rf /root/.cache \
    && rm -rf *.tgz *.tar *.zip \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

WORKDIR ${SPARK_HOME}

EXPOSE 8088 4040