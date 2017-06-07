#JERY
JERY is a Python 2.7 based simple database workload generator for Oracle and Enterprise Databases. It is designed to run in a special Docker image and it is streaming it's GUI through x11 to your host OS.

<img src="./img/screenshot.jpg" height="500">

##Table of Contents
- [Requirements](#Requirements)
- [Installation](#Installation) 
- [What is Jery?](#WhatisJery)
- [Used Libraries](#UsedLibraries)
- [Oracle Client install](#OracleClientinstall)
- [cx_Oracle python extension install](#cx_Oraclepythonextensioninstall)

<a name="Requirements"/>
##Requirements
JERY is meant to run on Linux Systems only (primarily RHEL and CentOs). For this reason the following installation guide is maily for RHEL. Since JERY is running in a Docker image, a recent version of Docker needs to be installed on the system.

<a name="Installation"/>
##Installation
JERY can either be downloaded from this GitHub page or from a Docker registry. These possibilities are discribed in the following.

__1) Download latest build from GitHub page and import image__
- download the latest [release](https://github.hpe.com/marcel-jakob/jery/releases) from this GitHub page
- unzip the build file
- open a new terminal and navigate to the unzipped file _(jerydocker.tar)_
- import the unzipped file with ```docker load < jerydocker.tar```
- download the run script and execute it

__2) Download and import latest build from a the Docker registry__


<a name="WhatisJery"/>
##What is Jery?

- Dedicated to Oracle in phase 1
- Mimic Business Intelligence workload (100% massive read)
- Cluster aware
- Create its own test schema based of “SCOTT” data
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
