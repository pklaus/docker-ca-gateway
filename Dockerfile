FROM pklaus/epics_base:7.0.2.2_debian

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
 && apt-get install -qqy --no-install-recommends \
      git \
 && mkdir /epics/modules

RUN git clone --single-branch --branch v4.13.2 --depth 1 https://github.com/epics-modules/pcas.git /epics/src/pcas \
 && cd /epics/src/pcas \
 && echo "EPICS_BASE=/epics/base" > configure/RELEASE.local \
 && echo "INSTALL_LOCATION=/epics/modules/pcas" > configure/CONFIG_SITE.local \
 && make -j$(nproc) \
 && echo "/epics/modules/pcas/lib/${EPICS_HOST_ARCH}" >> /etc/ld.so.conf.d/epics.conf \
 && ldconfig \
 && git clone --branch R2-1-2-0 --depth 1 https://github.com/epics-extensions/ca-gateway.git /epics/src/ca-gateway \
 && cd /epics/src/ca-gateway \
 && echo "EPICS_BASE=/epics/base" > configure/RELEASE.local \
 && echo "PCAS=/epics/modules/pcas" >> configure/RELEASE.local \
 && echo "INSTALL_LOCATION=/epics/ca-gateway" > configure/CONFIG_SITE.local \
 && make -j$(nproc) \
 && rm -rf /epics/src \
 && cd /epics/ca-gateway/bin/${EPICS_HOST_ARCH}

RUN adduser -h /scs -s /bin/bash -D scs
USER scs

# Does this make sense for gateway? So that providing -cip for the gateway command is optional?
ENV EPICS_CA_AUTO_ADDR_LIST=YES

COPY start_gateway.sh /scs/
COPY pvlist /scs/config/
COPY access /scs/config/

WORKDIR /scs
CMD ./start_gateway.sh
