#Dockerfile for packaging Jery
based on [CentOs 7](https://hub.docker.com/_/centos/)

##Build
For an recent docker image please refer to [releases](https://github.hpe.com/marcel-jakob/jery/releases)

##Docker run command
Needs to be executed with superuser privileges: <br>
```docker run -ti --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix jerydocker```

- ```-ti```: run in interactive mode (attach to command line of container)
- ```-rm```: Docker will automatically clean up the container and remove the file system when the container exits
- ```-e DISPLAY=$DISPLAY```: Set the containers $DISPLAY environment variable to the hosts one. This results in access to the hosts display
- ```-v /tmp/.X11-unix:/tmp/.X11-unix```: Connect a new volume with the hosts X11 binaries to the container
- ```jerydocker```: Run the container jerydocker

##Dockerfile explained
####Enable Sources
Add and install epel and ius sources. For installing libaio and tkinter with yum.
####Install Oracle Client and cx_Oracle
Is needed by Jery for establishing the connection to the Oracle DB. Both is added and installed. But at first libaio is installed as dependency of Oracle Client. In the end the environment variable for the Oracle Client is exported.
####Install GUI + tkinter
 The base image of CentOs7 has some bugs in order to display graphical user interfaces. For this reason a font needs to be installed. In the end tkinter is installed via yum as UI python library.
####Add new user "developer"
 Add a new user developer with root rights to the system. This one is needed to x11 forward the window out of the docker container.
####Execute Jery
 Switch to this user and execute the Jery script.
 
##Issues
Excecuting Jery as root if not logged in as root
```Error _tkinter.TclError: couldn't connect to display ":0"```</br></br>
X-Server connection of other users (root) are rejected</br>
--> Solved with the command ```xhost local:root```

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