#/bin/bash

set -x

# Fetch the CIP / SIP environment variables and use them for the startup of the ca-gateway

# SIP is either already set as environment variable or we try to fetch it from the /etc/hosts file
SIP=${SIP:-$(cat /etc/hosts | grep $(hostname) | awk 'END{print $1}')}

# CIP is set as environment variable, otherwise we use a fixed broadcast address here:
CIP=${CIP:-172.20.255.255}

echo CIP=$CIP SIP=$SIP

/epics/ca-gateway/bin/${EPICS_HOST_ARCH}/gateway \
  -cip $CIP \
  -sip $SIP \
  -debug 1 \
  -log /dev/stdout \
  -prefix gw \
  -pvlist ./config/pvlist \
  -access ./config/access

# further options:
#  -debug 50 \
