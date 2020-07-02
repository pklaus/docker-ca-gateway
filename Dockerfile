## ===============================
#  1st stage: Download and Extract
FROM alpine AS download-extract

RUN apk update && apk add git
RUN git clone --branch R2-1-2-0 --depth 1 -c advice.detachedHead=false \
      https://github.com/epics-extensions/ca-gateway.git /ca-gateway
RUN rm -rf /ca-gateway/.git


## ===============================
#  2nd stage: build the CA Gateway
FROM pklaus/epics_base:7.0.4_debian AS builder

# The scs user already exists in base image.
# We set it here explicitly to clarify file ownership.
USER scs

# Download the EPICS CA Gateway
COPY --chown=scs:users --from=download-extract /ca-gateway /epics/src/ca-gateway
RUN cd /epics/src/ca-gateway \
 && echo "EPICS_BASE=/epics/base" > configure/RELEASE.local \
 && echo "PCAS=/epics/base/modules/pcas" >> configure/RELEASE.local \
 && echo "INSTALL_LOCATION=/epics/ca-gateway" > configure/CONFIG_SITE.local \
 && make -j$(nproc)


## ======================================
# 3rd stage: "dockerize" the application - copy executable, lib dependencies
#            to a new root folder. For more information, read
#            https://blog.oddbit.com/post/2015-02-05-creating-minimal-docker-images/
FROM builder AS dockerizer
USER root

# Install Python and a Python2 compatible version of larsks/dockerize
RUN apt-get update && apt-get install -yq python python-pip rsync \
 && pip install https://github.com/larsks/dockerize/archive/a903419.zip

# Move the executable "gateway" to a more prominent location
RUN mv /epics/ca-gateway/bin/linux-x86_64/gateway /epics/

# Dockerize
RUN dockerize -L preserve -n -u scs -o /ca-gateway_root --verbose /epics/gateway \
 && find /ca-gateway_root/ -ls \
 && rm /ca-gateway_root/Dockerfile \
 # /epics is owned by scs in this image and should also be in later one:
 && chown -R scs:users /ca-gateway_root/epics


## =========================================
#  4th stage: Finally put together our image
#             from scratch for minimal size.
FROM scratch AS final

USER scs

COPY --from=dockerizer /ca-gateway_root /

# Does this make sense for gateway? So that providing -cip for the gateway command is optional?
ENV EPICS_CA_AUTO_ADDR_LIST=YES

ENV PATH=/

WORKDIR /epics

ENTRYPOINT ["/epics/gateway"]
#CMD ["-h"]
#CMD ["-help"]
