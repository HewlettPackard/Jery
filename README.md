# Jery
A Python 2.7 based simple database workload generator for Oracle Databases

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

However, JERY is not a benchmark tool

##Used Libraries

- Tkinter
- cx_Oracle
- threading
- ConfigParser

##Oracle Client install
- copy file from /oracle
- rpm -ivh oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm
- echo export LD_LIBRARY_PATH=/usr/lib/oracle/11.2/client64/lib

##cx_Oracle python extension install
(Oracle Client needs to be installed)
- copy file from /oracle
- rpm -ivh ocx_Oracle-5.2.1-11g-py27-1.x86_64.rpm