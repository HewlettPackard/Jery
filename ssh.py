"""
            - copies EGenLoad to server
            - exececutes it
            - generates the data tables
            - imports the tables
            - creates indexes
"""

import paramiko

hostname = '192.168.40.131'
username = 'oracle'
password = 'password'
port = 22
loaderSource = './EGen/EGenLoader'
loaderDestination = '/tmp/jery/EGenLoader'
inputSource = './EGen/flat_in.zip'
inputDestination = '/tmp/jery/flat_in.zip'
scriptSource = './tpce/tpce.zip'
scriptDestination = '/tmp/jery/tpce.zip'
inputUnzipped = "/tmp/jery/flat_in/"
scriptsUnzipped = "/tmp/jery/scripts/"
outputPath = "/tmp/jery/tables/"

def waitForTerminate(stdout):
    # Wait for the command to terminate
    while not stdout.channel.exit_status_ready():
        # Only print data if there is data to read in the channel
        if stdout.channel.recv_ready():
            if 'select' in locals():
                rl, wl, xl = select.select([stdout.channel], [], [], 0.0)
                if len(rl) > 0:
                    # Print data from stdout
                    print stdout.channel.recv(1024),


ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(hostname= hostname, username= username, password= password)

transport = paramiko.Transport((hostname, 22))
transport.connect(username = username, password = password)

sftp = paramiko.SFTPClient.from_transport(transport)

print "Connected to %s" % hostname

stdin, stdout, stderr = ssh.exec_command("cd /tmp/ && echo bla23 > new11.txt")
waitForTerminate(stdout)

# Send commands for folder creation (non-blocking)
stdin, stdout, stderr = ssh.exec_command("rm -r -d -f /tmp/jery/")
waitForTerminate(stdout)
stdin, stdout, stderr = ssh.exec_command("mkdir /tmp/jery/")
waitForTerminate(stdout)

# Copy files to remote
sftp.put(loaderSource, loaderDestination)
sftp.put(inputSource, inputDestination)
sftp.put(scriptSource, scriptDestination)
print "STEP 1: Copied files to server"

# Send commands for table generation (non-blocking)
stdin, stdout, stderr = ssh.exec_command("rm -r -d -f" + outputPath)
waitForTerminate(stdout)
stdin, stdout, stderr = ssh.exec_command("chmod +x " + loaderDestination)
waitForTerminate(stdout)
stdin, stdout, stderr = ssh.exec_command("unzip " + inputDestination + " -d " + inputUnzipped)
waitForTerminate(stdout)
stdin, stdout, stderr = ssh.exec_command("unzip " + scriptDestination + " -d " + scriptsUnzipped)
waitForTerminate(stdout)
stdin, stdout, stderr = ssh.exec_command("rm -f " + inputDestination)
waitForTerminate(stdout)
stdin, stdout, stderr = ssh.exec_command("rm -f " + scriptDestination)
waitForTerminate(stdout)
stdin, stdout, stderr = ssh.exec_command("A")
waitForTerminate(stdout)
stdin, stdout, stderr = ssh.exec_command("mkdir -p " + outputPath)
waitForTerminate(stdout)
print "STEP 2: Unzipped files on server"
stdin, stdout, stderr = ssh.exec_command(loaderDestination + " -i " + inputUnzipped + " -o " + outputPath + " -f 1")
waitForTerminate(stdout)
stdin, stdout, stderr = ssh.exec_command("rm -f " + loaderDestination)
waitForTerminate(stdout)
print "STEP 3: Generated tables on server"


# Send commands for table import (non-blocking)
stdin, stdout, stderr = ssh.exec_command("chmod +x " + scriptsUnzipped + "06ImportTPCETables.sh")
waitForTerminate(stdout)
stdin, stdout, stderr = ssh.exec_command("sed -i -e 's/\\r$//' " + scriptsUnzipped + "06ImportTPCETables.sh")
waitForTerminate(stdout)
stdin, stdout, stderr = ssh.exec_command("cd " + scriptsUnzipped + " && ./06ImportTPCETables.sh")
print "STEP 4: Imported tables in database"


sftp.close()
transport.close()
ssh.close()
