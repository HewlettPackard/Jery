FROM centos

#install pip for python
RUN yum update -y
RUN yum install -y wget
RUN wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm 
RUN rpm -ivh epel-release-7-8.noarch.rpm 
RUN yum install -y python-pip

#install libaio (is needed for Oracle Client)
RUN yum install -y libaio

#install Oracle client
ADD oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm oracle-client.rpm
RUN rpm -ivh oracle-client.rpm
RUN echo export LD_LIBRARY_PATH=/usr/lib/oracle/11.2/client64/lib

#install cx_Oracle
ADD cx_Oracle-5.2.1-11g-py27-1.x86_64.rpm cx_Oracle.rpm
RUN rpm -ivh cx_Oracle.rpm

#test cx_Oracle and connection
ADD example.py example.py
CMD python example.py

