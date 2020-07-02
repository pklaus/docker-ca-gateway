FROM pklaus/epics_base:7.0.4_debian

ENV DEBIAN_FRONTEND noninteractive
USER root
RUN apt-get update \
 && apt-get install -qqy --no-install-recommends \
      git \
 && true

USER scs
RUN git clone --branch R2-1-2-0 --depth 1 https://github.com/epics-extensions/ca-gateway.git /epics/src/ca-gateway \
 && cd /epics/src/ca-gateway \
 && echo "EPICS_BASE=/epics/base" > configure/RELEASE.local \
 && echo "PCAS=/epics/base/modules/pcas" >> configure/RELEASE.local \
 && echo "INSTALL_LOCATION=/epics/ca-gateway" > configure/CONFIG_SITE.local \
 && make -j$(nproc) \
 && rm -rf /epics/src \
 && cd /epics/ca-gateway/bin/${EPICS_HOST_ARCH}

# Does this make sense for gateway? So that providing -cip for the gateway command is optional?
ENV EPICS_CA_AUTO_ADDR_LIST=YES

COPY start_gateway.sh /scs/
COPY pvlist /scs/config/
COPY access /scs/config/

WORKDIR /scs
CMD ./start_gateway.sh
