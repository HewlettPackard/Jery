import subprocess
import sys
import os

try:
	print "hello from Python"

	subprocess.call(["/home/ubuntu/Desktop/EGen_Build_Linux/EGenLoader", "-i", "/home/ubuntu/Desktop/EGen_Build_Linux/flat_in/", "-o", "/home/ubuntu/Desktop/EGen_Build_Linux/flat_out/"])

except KeyboardInterrupt:
        print '\nInterrupted'
        try:
            sys.exit(0)
        except SystemExit:
            os._exit(0)

