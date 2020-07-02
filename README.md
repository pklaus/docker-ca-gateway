# EPICS CA Gateway in a Docker Container

The configuration files pvlist / access are placed in `/scs/config`,
so when deploying the image, you can bind-mount a different set
of files to that directory.
More detailed examples for the configuration files can be found here:
<https://github.com/epics-extensions/ca-gateway/tree/master/example>

This Dockerfile was inspired by prior work of F.Feldbauer.


## Synopsis

```
$ docker run --rm pklaus/ca-gateway -h

Bad option: -h

Bad command line
/epics/gateway -h

Usage: /epics/gateway followed by the these options:
        [-debug value ]
        [-log file_name ]
        [-pvlist file_name ]
        [-access file_name ]
        [-command file_name ]
        [-putlog file_name ]
        [-report file_name ]
        [-home directory ]
        [-sip IP_address ]
        [-cip IP_address_list ]
        [-signore IP_address_list ]
        [-sport CA_server_port ]
        [-cport CA_client_port ]
        [-connect_timeout seconds ]
        [-inactive_timeout seconds ]
        [-dead_timeout seconds ]
        [-disconnect_timeout seconds ]
        [-reconnect_inhibit seconds ]
        [-server (start as server) ]
        [-uid user_id_number ]
        [-gid group_id_number ]
        [-ro]
        [-prefix statistics_prefix ]
        [-mask event_mask ]
        [-no_cache (no caching) ]
        [-archive archive monitor ]
        [-help]

Defaults are:
        debug=0
        home=/epics
        log=gateway.log
        access=NULL
        pvlist=NULL
        command=NULL
        putlog=NULL
        report=gateway.report
        dead=120
        connect=1
        disconnect=7200
        reconnect=300
        inactive=7200
        mask=va
        caching = disabled
        archive monitor = disabled
        user id=1000
        group id=100
  (The default filenames depend on which files exist in home)
```

## CLI Help

```
$ docker run --rm pklaus/ca-gateway -help

-debug value: Enter value between 0-100.  50 gives lots of
 info, 1 gives small amount.

-pvlist file_name: Name of file with all the allowed PVs in it
 See the sample file gateway.pvlist in the source distribution
 for a description of how to create this file.
-access file_name: Name of file with all the EPICS access
 security rules in it.  PVs in the pvlist file use groups
 and rules defined in this file.
-log file_name: Name of file where all messages from the
 gateway go, including stderr and stdout.

-command file_name: Name of file where gateway command(s) go
 Commands are executed when a USR1 signal is sent to gateway.

-putlog file_name: Name of file where gateway put logging goes.
 Put logging is specified with TRAPWRITE in the access file.

-report file_name: Name of file where gateway reports go.
 Reports are appended to this file if it exists.

-home directory: Home directory where all your gateway
 configuration files are kept where log and command files go.

-sip IP_address: IP address that gateway's CA server listens
 for PV requests.  Sets env variable EPICS_CAS_INTF_ADDR.

-signore IP_address_list: IP address that gateway's CA server
 ignores.  Sets env variable EPICS_CAS_IGNORE_ADDR_LIST.

-cip IP_address_list: IP address list that the gateway's CA
 client uses to find the real PVs.  See CA reference manual.
 This sets environment variables EPICS_CA_AUTO_LIST=NO and
 EPICS_CA_ADDR_LIST.

-sport CA_server_port: The port which the gateway's CA server
 uses to listen for PV requests.  Sets environment variable
 EPICS_CAS_SERVER_PORT.

-cport CA_client_port:  The port which the gateway's CA client
 uses to find the real PVs.  Sets environment variable
 EPICS_CA_SERVER_PORT.

-connect_timeout seconds: The amount of time that the
 gateway will allow a PV search to continue before marking the
 PV as being not found.

-inactive_timeout seconds: The amount of time that the gateway
 will hold the real connection to an unused PV.  If no gateway
 clients are using the PV, the real connection will still be
 held for this long.

-dead_timeout seconds:  The amount of time that the gateway
 will hold requests for PVs that are not found on the real
 network that the gateway is using.  Even if a client's
 requested PV is not found on the real network, the gateway
 marks the PV dead, holds the request and continues trying
 to connect for this long.

-disconnect_timeout seconds:  The amount of time that the gateway
 will hold requests for PVs that were connected but have been
 disconnected. When a disconnected PV reconnects, the gateway will
 broadcast a beacon signal to inform the clients that they may
 reconnect to the gateway.

-reconnect_inhibit seconds:  The minimum amount of time between
 additional beacons that the gateway will send to its clients
 when channels from the real network reconnect.

-server: Start as server. Detach from controlling terminal
 and start a daemon that watches the gateway and automatically
 restarts it if it dies.
-mask event_mask: Event mask that is used for connections on the
 real network: use any combination of v (value), a (alarm), l (log).
 Default is va (forward value and alarm change events).
-prefix string: Set the prefix for the gateway statistics PVs.
 Defaults to the hostname the gateway is running on.
-uid number: Run the server with this id, server does a
 setuid(2) to this user id number.

-gid number: Run the server with this id, server does a
 setgid(2) to this group id number.

-no_cache: Disables caching. Every get request will be forwarded to
 the ioc and monitor will be created only if needed.
-archive: Enables archive monitor. Additional log event monitor is
 is created.
```
