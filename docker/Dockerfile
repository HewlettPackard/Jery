FROM centos
MAINTAINER Marcel Jakob <jery@hpe.com>

#install pip for python
RUN yum update -y
RUN yum install -y wget
ADD epel-release-latest-7.noarch.rpm epel.rpm
RUN rpm -ivh epel.rpm 
RUN yum install -y python-pip
RUN pip install --upgrade pip

ADD ius-release-1.0-14.ius.centos7.noarch.rpm ius-release.rpm
RUN rpm -ivh ius-release.rpm
RUN yum install -y tkinter

#install libaio (is needed for Oracle Client)
RUN yum install -y libaio

#install Oracle client
ADD oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm oracle-client.rpm
RUN rpm -ivh oracle-client.rpm
RUN echo export LD_LIBRARY_PATH=/usr/lib/oracle/11.2/client64/lib

#install cx_Oracle
ADD cx_Oracle-5.2.1-11g-py27-1.x86_64.rpm cx_Oracle.rpm
RUN rpm -ivh cx_Oracle.rpm

#install sudo
RUN yum install -y sudo

#install GUI (GNOME Desktop) 
RUN yum groups install -y "Desktop" "Desktop Platform" "X Window System" "Fonts"
RUN yum groups install -y "GNOME Desktop" "Graphical Administration Tools"
RUN ln -sf /lib/systemd/system/runlevel5.target /etc/systemd/system/default.target
RUN dbus-uuidgen > /var/lib/dbus/machine-id


#new User "Developer"
RUN export uid=0 gid=0 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" >  /etc/sudoers && \
    chmod 0440  /etc/sudoers && \
    chown ${uid}:${gid} -R /home/developer


#set current user to developer
USER developer
ENV HOME /home/developer

#start Jery
ADD /jery/ /jery/
CMD cd /jery/ && python jery.py

