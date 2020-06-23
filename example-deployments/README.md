# Example Deployments of the CA Gateway on Docker

This folder contains three docker-compose example deployments:

* [internal](./internal/)  
  Here, two networks are created in the docker-compose file:
  one called `epics_field` that's supposed to contain the field layer IOCs
  (IOCs connected to your devices etc.)
  The other one is called `a_epics_supervisory` and contains the supervisory
  (e.g. archiving, visulization, control).
  In between sits the ca-gateway, connecting those two Docker-internal networks.
  In addition, the ports of the CA Gateway server side are forwarded to the host,
  which may be useful in one case or the other.
* [host](./host)  
  In this example, the ca-gateway is run with `network_mode: host` in the
  docker-compose file (which corresponds to `--network=host` for a `docker run` cmd).
  This is especially useful if the the host is connected to two different external networks
  (external meaning not defined by Docker) and it shall serve as the CA Gateway between those.
  *Note*, that we still create another Docker network with an example IOC just to be
  able to also test this scenario on a computer with just a single network.
* [hybrid](./hybrid/)
  In this example, the Gateway is started with "macvlan" networking to
  simplify connecting external (VLAN) networks.
