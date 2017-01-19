#Dockerfile for packaging Jery
based on CentOs 7
https://hub.docker.com/_/centos/

##Build
For the docker image refer to "releases"

##Docker run command
```docker run -ti --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix jerydocker```

##Dockerfile explained
######Enable Sources
Add and install epel and ius sources. For installing libaio and tkinter with yum.

######Install Oracle Client and cx_Oracle
Is needed by Jery for establishing the connection to the Oracle DB. Both is added and installed. But at first libaio is installed as dependency of Oracle Client. In the end the environment variable for the Oracle Client is exported.
 
######Install GUI + tkinter
 The docker base image of CentOs 7 has no GUI. For this reason a minimal GUI and fonts needs to be installed. In the end tkinter is installed via yum as UI python library.
 
######Add new user "developer"
 Add a new user developer with root rights to the system. This one is needed to x11 forward the window out of the docker container.
 
######Execute Jery
 Switch to this user and execute the Jery script.
