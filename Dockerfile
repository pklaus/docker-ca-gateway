FROM alpine AS download-extract

RUN apk update && apk add git
RUN git clone --branch R2-1-2-0 --depth 1 https://github.com/epics-extensions/ca-gateway.git /ca-gateway
RUN rm -rf /ca-gateway/.git

FROM pklaus/epics_base:7.0.4_debian AS builder

# this is default in the base image - just repeating it explicitly:
USER scs

COPY --chown=scs:users --from=download-extract /ca-gateway /epics/src/ca-gateway
RUN cd /epics/src/ca-gateway \
 && echo "EPICS_BASE=/epics/base" > configure/RELEASE.local \
 && echo "PCAS=/epics/base/modules/pcas" >> configure/RELEASE.local \
 && echo "INSTALL_LOCATION=/epics/ca-gateway" > configure/CONFIG_SITE.local \
 && make -j$(nproc)

# The gateway executable is now to be found in:
# /epics/ca-gateway/bin/${EPICS_HOST_ARCH}/gateway

# no need to keep source code:
RUN rm -rf /epics/src

# Does this make sense for gateway? So that providing -cip for the gateway command is optional?
ENV EPICS_CA_AUTO_ADDR_LIST=YES

COPY start_gateway.sh /scs/
COPY pvlist /scs/config/
COPY access /scs/config/

WORKDIR /scs
CMD ./start_gateway.sh
