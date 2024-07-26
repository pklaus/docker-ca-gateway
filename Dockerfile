## ===============================
#  1st stage: Download and Extract
FROM alpine AS download-extract

RUN apk update && apk add git
RUN git clone --branch R2-1-3-0 --depth 1 -c advice.detachedHead=false \
      https://github.com/epics-extensions/ca-gateway.git /ca-gateway
RUN git clone --branch v4.13.3 --depth 1 -c advice.detachedHead=false \
      https://github.com/epics-modules/pcas.git /epics/support/pcas

RUN rm -rf /ca-gateway/.git; rm -rf /epics/support/pcas/.git


## ===============================
#  2nd stage: build the CA Gateway
FROM ghcr.io/epics-containers/epics-base-developer:7.0.8ec2 AS builder

# Download the EPICS CA Gateway
COPY --from=download-extract /ca-gateway /epics/src/ca-gateway
COPY --from=download-extract /epics/support/pcas /epics/support/pcas

RUN cd /epics/support/pcas \
 && echo "EPICS_BASE=/epics/epics-base" > configure/RELEASE.local \
 && make -j$(nproc)
RUN cd /epics/src/ca-gateway \
 && echo "EPICS_BASE=/epics/epics-base" > configure/RELEASE.local \
 && echo "PCAS=/epics/support/pcas" >> configure/RELEASE.local \
 && echo "INSTALL_LOCATION=/epics/ca-gateway" > configure/CONFIG_SITE.local \
 && make -j$(nproc)

# Install debugging tools to use this target as a debug container
RUN apt update && apt install -y net-tools tcpdump iproute2 iputils-ping vim

## ======================================
# 3rd stage: "dockerize" the application - copy executable, lib dependencies
#            to a new root folder. For more information, read
#            https://blog.oddbit.com/post/2015-02-05-creating-minimal-docker-images/
FROM builder AS dockerizer

# Install the latest commit of dockerize (2021/07/06)
RUN pip install git+https://github.com/larsks/dockerize@024b1a2

# Move the executable "gateway" to a more prominent location
RUN mv /epics/ca-gateway/bin/*/gateway /epics/
RUN useradd scs

# Dockerize
RUN dockerize -L preserve -n -u scs -o /ca-gateway_root --verbose /epics/gateway \
 && find /ca-gateway_root/ -ls \
 && rm /ca-gateway_root/Dockerfile \
 # /epics is owned by scs in this image and should also be in later one:
 && chown -R scs:users /ca-gateway_root/epics

ENTRYPOINT ["/epics/gateway"]

## =========================================
#  4th stage: Finally put together our image
#             from scratch for minimal size.
FROM scratch AS final

# User scs gives us a non-root user to run the gateway
USER scs

COPY --from=dockerizer /ca-gateway_root /

# Does this make sense for gateway? So that providing -cip for the gateway command is optional?
ENV EPICS_CA_AUTO_ADDR_LIST=YES

ENV PATH=/

WORKDIR /epics

ENTRYPOINT ["/epics/gateway"]
#CMD ["-h"]
#CMD ["-help"]
