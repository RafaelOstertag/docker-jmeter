# inspired by https://github.com/hauptmedia/docker-jmeter  and
# https://github.com/hhcordero/docker-jmeter-server/blob/master/Dockerfile
FROM alpine:3.9

LABEL maintainer="rafi@uengel.ch"

ARG JMETER_VERSION="5.1.1"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz
ENV	JMETER_PLUGINS_MANAGER_VERSION  1.3
ENV CMDRUNNER_VERSION 2.2
ENV JSON_LIB_VERSION 2.4
ENV JSON_LIB_FULL_VERSION ${JSON_LIB_VERSION}-jdk15
ENV TZ ${TZ:-Europe/Zurich}

RUN    apk update \
	&& apk upgrade \
	&& apk add ca-certificates \
	&& update-ca-certificates \
	&& apk add --update openjdk8-jre tzdata curl unzip bash \
	&& apk add --no-cache nss \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /tmp/dependencies  \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
	&& mkdir -p /opt  \
	&& tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
	&& rm -rf /tmp/dependencies \
	&& echo "downloading jmeter plugins manager" \
	&& curl --location --silent --output ${JMETER_HOME}/lib/ext/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER_VERSION}.jar http://search.maven.org/remotecontent?filepath=kg/apc/jmeter-plugins-manager/${JMETER_PLUGINS_MANAGER_VERSION}/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER_VERSION}.jar \
	&& curl --location --silent --show-error --output ${JMETER_HOME}/lib/cmdrunner-${CMDRUNNER_VERSION}.jar http://search.maven.org/remotecontent?filepath=kg/apc/cmdrunner/${CMDRUNNER_VERSION}/cmdrunner-${CMDRUNNER_VERSION}.jar \
    && curl --location --silent --show-error --output ${JMETER_HOME}/lib/json-lib-${JSON_LIB_FULL_VERSION}.jar https://search.maven.org/remotecontent?filepath=net/sf/json-lib/json-lib/${JSON_LIB_VERSION}/json-lib-${JSON_LIB_FULL_VERSION}.jar \
	&& java -cp ${JMETER_HOME}/lib/ext/jmeter-plugins-manager-${JMETER_PLUGINS_MANAGER_VERSION}.jar org.jmeterplugins.repository.PluginManagerCMDInstaller \
	&& echo "done downloading, now installing plugins" \
	&& ${JMETER_HOME}/bin/PluginsManagerCMD.sh install jpgc-casutg=2.9,\
	&& ${JMETER_HOME}/bin/PluginsManagerCMD.sh status \
	&& chmod +x ${JMETER_HOME}/bin/*.sh \
	&& rm -fr /tmp/*

# Set global PATH such that "jmeter" command is found
ENV PATH $PATH:$JMETER_BIN

# Entrypoint has same signature as "jmeter" command
COPY entrypoint.sh /

WORKDIR	${JMETER_HOME}

ENTRYPOINT ["/entrypoint.sh"]
