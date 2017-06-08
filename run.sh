#!/bin/bash

docker -v
if [ $? -ne 0 ]; then
	echo "The program 'docker' is currently not installed."
else
	# try to find image named jerydocker
	imageName="$(docker images | grep -o -m 1 ^jerydocker)"
	if [ $imageName == "" ]; then
		echo "JERY is not installed"
		echo "Please see the install instructions on https://github.hpe.com/marcel-jakob/jery"
	else
		echo "Starting $imageName"
		docker run -ti --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix $imageName
	fi
fi
