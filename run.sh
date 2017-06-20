#!/bin/bash

printf "################################################################################\n"
echo "                           ___ _____________   __   
                          |_  |  ___| ___ \ \ / /   
                            | | |__ | |_/ /\ V /___ 
                            | |  __||    /  \ // _ \\
                        /\__/ / |___| |\ \  | |  __/
                        \____/\____/\_| \_| \_/\___|"
docker -v
printf "################################################################################\n\n"                            


if [ $? -ne 0 ]; then
	echo "The program 'docker' is currently not installed."
else
	# try to find image named jerydocker
	imageName="$(docker images | grep -o -m 1 ^jerydocker)"
	if [[ $imageName == "" ]]; then
		echo "JERY is not installed"
		echo "Please see the install instructions on https://github.hpe.com/marcel-jakob/jery"
	else
		echo -n "Type the path where JERYe can save temporary files (up to 40GB): "
		read path
		if [ -d "$path" ]; then
			echo "Starting $imageName"
			docker run -ti --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $path:/tpce/ $imageName
		else
			echo "please enter a valid path"
		fi
	fi
fi
