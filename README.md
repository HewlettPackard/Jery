[![Github All Releases](https://img.shields.io/github/downloads/HewlettPackard/Jery/total.svg)](https://github.com/HewlettPackard/Jery)
[![Docker Pulls](https://img.shields.io/docker/pulls/oraclekc/jery.svg)](https://hub.docker.com/r/oraclekc/jery/)
 

# JERYe
JERYe is a JERY v1.0 based  [TPC-E](http://www.tpc.org/tpce/) like benchmark for Oracle Databases. It is designed to run in a special Docker image and it is streaming it's GUI through x11 to your host OS. 

<img src="./img/screenshot.jpg" height="500">
<br></br>
<img src="./logo/jery.png" height="300">

## Table of Contents
- [What is JERYe?](#WhatisJery)
- [Requirements](#Requirements)
- [Installation](#Installation) 
- [Used Libraries](#UsedLibraries)
- [Adding an insecure Docker registry](#AddinganinsecureDockerregistry)


<a name="WhatisJery"/>

## What is JERYe?

- mimics  the [TPC-E benchmark](http://www.tpc.org/tpce/)
- based on [JERY v1.0](https://hub.docker.com/r/oraclekc/jery/)
- implementing the TPC-E Standard Specifications v1.14.0

<a name="Requirements"/>

## Requirements
JERY is meant to run on Linux Systems only (primarily RHEL and CentOS). For this reason the following installation guide is mainly for RHEL. Since JERY is running in a Docker image, a recent version of Docker needs to be installed on the system.

### Docker installation on RHEL
1) Log into your machine as a user with sudo or root privileges   
2) Make sure your existing yum packages are up-to-date  
```shell
$ sudo yum update
```
3) Add the yum repo by yourself  
```shell
$ sudo tee /etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
```
4) Install the Docker package
 ```shell
$ sudo yum install docker-engine
```
5) Start the Docker daemon
```shell
$ sudo service docker start
```
6) Verify docker is installed correctly by running a test image in a container
```shell
$ sudo docker run hello-world
Unable to find image 'hello-world:latest' locally
 latest: Pulling from hello-world
 a8219747be10: Pull complete
    91c95931e552: Already exists
    hello-world:latest: The image you are pulling has been verified. Important: image verification is a tech preview feature and should not be relied on to provide security.
    Digest: sha256:aa03e5d0d5553b4c3473e89c8619cf79df368babd1.7.1cf5daeb82aab55838d
    Status: Downloaded newer image for hello-world:latest
    Hello from Docker.
    This message shows that your installation appears to be working correctly.

    To generate this message, Docker took the following steps:
     1. The Docker client contacted the Docker daemon.
     2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
        (Assuming it was not already locally available.)
     3. The Docker daemon created a new container from that image which runs the
        executable that produces the output you are currently reading.
     4. The Docker daemon streamed that output to the Docker client, which sent it
        to your terminal.

    To try something more ambitious, you can run an Ubuntu container with:
     $ docker run -it ubuntu bash

    For more examples and ideas, visit:
     http://docs.docker.com/userguide/
```
> \* copied from http://docs.master.dockerproject.org/engine/installation/linux/rhel/

Docker install guides for other linux distributions can be found under:
- [Installation on Ubuntu](http://docs.master.dockerproject.org/engine/installation/linux/ubuntulinux/)
- [Installation on CentOS](http://docs.master.dockerproject.org/engine/installation/linux/centos/)
- [Installation on Oracle Linux](http://docs.master.dockerproject.org/engine/installation/linux/oracle/)

<a name="Installation"/>

## Installation
JERY can either be downloaded from a Docker registry or from this GitHub page. These possibilities are described in the following.

### Option 1: RECOMMENDED Pull latest image from Docker Hub
1) Open a new terminal and type 

```shell
 sudo docker pull oraclekc/jery-e
```

<a name="UsedLibraries"/>

## Used Libraries

- [Tkinter](http://tkinter.unpythonic.net/wiki/)
- [cx_Oracle](https://cx-oracle.readthedocs.io/en/latest/)
- [threading](https://docs.python.org/2/library/threading.html)
- [ConfigParser](https://docs.python.org/2/library/configparser.html)
- [psycopg2](http://initd.org/psycopg/)
- [NumPy](http://www.numpy.org/)
- [paramiko](http://www.paramiko.org/)
