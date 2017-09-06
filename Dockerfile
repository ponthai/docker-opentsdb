FROM openjdk:8-jdk

ARG BUILD_DATE
ARG VCS_REF

ENV VCS_REF=${VCS_REF}

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="OpenTSDB" \
      org.label-schema.description="OpenTSDB image for Google Container Engine and BigTable" \
      org.label-schema.url="http://opentsdb.net/" \
      org.label-schema.vcs-url="https://github.com/ciandt-d1/docker-opentsdb.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0"

RUN useradd opentsdb && \
    apt-get update && \
    apt-get install --no-install-recommends -y build-essential autoconf automake gnuplot-nox git && \
    apt-get clean && \
    git clone https://github.com/OpenTSDB/opentsdb.git /opt/opentsdb && \
    cd /opt/opentsdb && \
    chmod +x build-bigtable.sh && \
    ./build-bigtable.sh && \
    ./build-bigtable.sh install && \
    curl -sL "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64" > /usr/sbin/gosu && \
    echo "5b3b03713a888cee84ecbf4582b21ac9fd46c3d935ff2d7ea25dd5055d302d3c  /usr/sbin/gosu" | sha256sum -c && \
    chmod +x /usr/sbin/gosu

RUN cd /usr/local/share/opentsdb/lib && \
    { curl -O "http://central.maven.org/maven2/com/github/ankurcha/google-cloud-logging-logback-slf4j/1.1.6/google-cloud-logging-logback-slf4j-1.1.6.jar"; \
      curl -O "http://central.maven.org/maven2/ch/qos/logback/contrib/logback-json-core/0.1.5/logback-json-core-0.1.5.jar"; \
      cd -; }

COPY ./logback.xml /etc/opentsdb/logback.xml
COPY ./run.sh /run.sh
COPY ./unprivileged.sh /unprivileged.sh

VOLUME /var/cache/opentsdb

ENTRYPOINT ["/run.sh"]
