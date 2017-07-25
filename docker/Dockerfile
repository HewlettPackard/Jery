#!/bin/bash
#© Copyright 2017 Hewlett Packard Enterprise Development LP
FROM centos:7
MAINTAINER Marcel Jakob <jery@hpe.com>

#enable sources
ADD epel-release-latest-7.noarch.rpm epel.rpm
ADD ius-release-1.0-14.ius.centos7.noarch.rpm ius-release.rpm
RUN rpm -ivh epel.rpm && \
	rm epel.rpm && \
	rpm -ivh ius-release.rpm && \
	rm ius-release.rpm


#install Oracle client (libaio is needed by Oracle Client) and cx_Oracle
ADD oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm oracle-client.rpm
ADD cx_Oracle-5.2.1-11g-py27-1.x86_64.rpm cx_Oracle.rpm
RUN yum install -y libaio && \
	yum clean all && \
	rpm -ivh oracle-client.rpm && \
	rm oracle-client.rpm && \
	echo export LD_LIBRARY_PATH=/usr/lib/oracle/11.2/client64/lib && \
	rpm -ivh cx_Oracle.rpm && \
	rm cx_Oracle.rpm
	

#install GUI (GNOME Desktop) + tkinter
RUN yum install -y abattis-cantarell-fonts.noarch && \
	ln -sf /lib/systemd/system/runlevel5.target /etc/systemd/system/default.target && \
	dbus-uuidgen > /var/lib/dbus/machine-id && \
	yum install -y tkinter && \
	yum clean all

#install psycopg2
RUN yum -y update && yum -y install python-pip &&\
	pip install psycopg2 &&\
	yum clean all

#new User "Developer"
RUN export uid=0 gid=0 && \
	mkdir -p /home/developer && \
	echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
	echo "developer:x:${uid}:" >> /etc/group && \
	echo "developer ALL=(ALL) NOPASSWD: ALL" >>  /etc/sudoers && \
	chmod 0440  /etc/sudoers && \
	chown ${uid}:${gid} -R /home/developer


#set current user to developer
USER developer
ENV HOME /home/developer

#start Jery
ADD /jery/ /jery/
CMD cd /jery/ && python jery.py