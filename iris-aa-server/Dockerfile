ARG IMAGE=store/intersystems/iris-aa-community:2020.3.0AA.331.0
ARG IMAGE=intersystemsdc/iris-aa-community:2020.3.0AA.331.0-zpm
FROM $IMAGE
LABEL maintainer="Thomas Dyar <Thomas.Dyar@intersystems.com>"

USER root
RUN mkdir /data \
	&& chown irisowner /data
USER irisowner

# copy files
COPY data /data
COPY src /data/src
COPY src-post-install /data/src-post-install
COPY iris.script /tmp/iris.script
COPY irisnative-1.2.0-cp34-abi3-linux_x86_64.whl /tmp/irisnative-1.2.0-cp34-abi3-linux_x86_64.whl

# special extract treatment for hate-speech dataset
# RUN mkdir /data/hate-speech/ \
#	&& tar -xf /data/hate-speech.tar -C /data/

# load demo stuff
RUN iris start IRIS \
	&& iris session IRIS < /tmp/iris.script

# RUN rm -r /data/*
