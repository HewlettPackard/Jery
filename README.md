#JERY
JERY is a Python 2.7 based simple database workload generator for Oracle and Enterprise Databases. It is designed to run in a special Docker image and it is streaming it's GUI through x11 to your host OS.

<img src="./img/screenshot.jpg" height="500">

##Table of Contents
- [Requirements](#Requirements)
- [Installation](#Installation) 
- [What is Jery?](#WhatisJery)
- [Used Libraries](#UsedLibraries)
- [Adding an insecure Docker registry](#AddinganinsecureDockerregistry)

<a name="Requirements"/>
##Requirements
JERY is meant to run on Linux Systems only (primarily RHEL and CentOs). For this reason the following installation guide is maily for RHEL. Since JERY is running in a Docker image, a recent version of Docker needs to be installed on the system.

<a name="Installation"/>
##Installation
JERY can either be downloaded from this GitHub page or from a Docker registry. These possibilities are discribed in the following.

__1) Download latest build from GitHub page and import image__
- download the latest release from this GitHub page [_(download)_](https://github.hpe.com/marcel-jakob/jery/releases)
- unzip the build file
- open a new terminal and navigate to the unzipped file _(jerydocker.tar)_
- import the unzipped file with ```docker load < jerydocker.tar```
- download the run script and execute it [_(download)_]()

__2) Download and import latest build from a the Docker registry__


      _From within the HPE network_

      1. Open a new terminal and type ```sudo su```
      2. Login to HPE Docker Hub with your Windows NT credentials: ```Docker login hub.docker.hpecorp.net```
      3. Pull the jerydocker image with the command: ```docker pull hub.docker.hpecorp.net/oraclekc/jery:latest```

      _From within the EPC network_

      1. Open a new terminal and type ```sudo su```
      2. Add dockerregistry.oracle.epc.ext.hpe.com:5000 as an insecure registry [_(howto)_](https://github.hpe.com/marcel-jakob/jery/blob/master/docker/README.md#adding-an-insecure-docker-registry) 
      3. Execute the command: ```docker pull dockerregistry.oracle.epc.ext.hpe.com:5000/jerydocker```

- download the run script and execute it [_(download)_]()

<a name="WhatisJery"/>
##What is Jery?

- Dedicated to Oracle and Enterprise DB
- Mimic Business Intelligence workload (100% massive read)
- Cluster aware
- Create its own test schema based of "SCOTT" data
- Generate CPU intensive activity
- Generate high IO rate (tunable)
- Can be user in user mode or in sysdba mode
- Provide:
    - execution time for critical query
    - Number of transaction per minute
    - Total number of transaction per run
    - System statistics
- Snapshot for AWR report
- Ideal for:
    - System demonstration
    - Calibration
    - Performance comparison

_However, JERY is not a benchmark tool_

<a name="UsedLibraries"/>
##Used Libraries

- [Tkinter](http://tkinter.unpythonic.net/wiki/)
- [cx_Oracle](https://cx-oracle.readthedocs.io/en/latest/)
- [threading](https://docs.python.org/2/library/threading.html)
- [ConfigParser](https://docs.python.org/2/library/configparser.html)
- [psycopg2](http://initd.org/psycopg/)


<a name="AddinganinsecureDockerregistry"/>
##Adding an insecure Docker registry
There are two options for adding a registry with no authorization to docker running on RHEL7 (on client which wants to push/pull to registry)
####Start docker daemon with --insecure-registry
```$ dockerd --insecure-registry= dockerregistry.oracle.epc.ext.hpe.com:5000```
####Edit config of service to add --insecure-registry <br>
Refer to https://docs.docker.com/engine/admin/ (CentOS / Red Hat Enterprise Linux / Fedora > Configuring Docker) <br>
```$ sudo mkdir /etc/systemd/system/docker.service.d``` <br>
```$ sudo nano /etc/systemd/system/docker.service.d/docker.conf``` <br><br>
Add the following to docker.conf: <br>
```
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -–insecure-registry=dockerregistry.oracle.epc.ext.hpe.com:5000
```
And reload + restart the Docker daemon
```$ sudo systemctl daemon-reload```<br>
```$ sudo systemctl restart docker```<br><br>
Check if “dockerregistry.oracle.epc.ext.hpe.com:5000” is added to point “Insecure Registries” of docker info:<br>
```$ docker info```
