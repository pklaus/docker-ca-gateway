# EPICS CA Gateway in a Docker Container

The configuration files pvlist / access are placed in `/scs/config`,
so when deploying the image, you can bind-mount a different set
of files to that directory.
More detailed examples for the configuration files can be found here:
<https://github.com/epics-extensions/ca-gateway/tree/master/example>

This Dockerfile was inspired by prior work of F.Feldbauer.
