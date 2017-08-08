#!/usr/local/bin/python3
#-*- coding: iso-8859-1 -*-

#############################################################
## © Copyright 2017 Hewlett Packard Enterprise Development LP
## Author: Yann Allandit
## Contact: dwh2@hp.com
## Creation Date: 10th of March 2014
#############################################################

from __future__ import division
import Tkinter
from Tkinter import *
import cx_Oracle
import threading
import time
import tkMessageBox
import ConfigParser
import paramiko
import numpy as np


########################  CONNECTION  ##########################
def connectToOracle(ip, port, SID, user, passwd, threaded=False):
    dsn = cx_Oracle.makedsn(host = ip, port = port, service_name = SID)
    con = cx_Oracle.connect(user, passwd, dsn, threaded=threaded)
    return con

###########################  GUI  ##############################
class CreateTestSchemaWindow(Tkinter.Toplevel):
    def __init__(CrSchemaWindow, SID, user, passwd, ip, port):
        Tkinter.Toplevel.__init__(CrSchemaWindow)

        """ Test schema Creation class
            Is a loop insert of the scott.emp table into a new schema table.
            Include 5 procedures inot the top level window apps:
            - Create schema: test is the new table exists, create it, create the statistics table (used for
              estimating how long are the jobs. Used also for the graph). Create also the sequence for the stat table
            - Drop test schema (can create a new one smaller or bigger)
            - Creation info: the schema creation can be time consuming, thus a loop will tell which step is currently executed.
            - Stop procedure and close window
            - Handling for the "x" press of the Toplevel window. Allow a clean close of the window.
        """

        """Global variable checking wether a toplevel window is open or not"""
        
        global OpenToplevel
        OpenToplevel += 1

        """ Toplevel window implementation"""
        CrSchemaWindow.wm_title("Benchmark schema creation")
        CrSchemaWindow.protocol("WM_DELETE_WINDOW", CrSchemaWindow.handler)
        CrSchemaWindow.SID = SID
        CrSchemaWindow.user = user
        CrSchemaWindow.passwd = passwd
        CrSchemaWindow.ip = ip
        CrSchemaWindow.port = port

        CrSchemaWindow.LabelTableRatio = Tkinter.Label(CrSchemaWindow, text="Select the parameters for the table generation", fg="white", bg="gray60", font=(15))
        CrSchemaWindow.LabelTableRatio.grid(column=0, row=0)

        CrSchemaWindow.LabelPath = Tkinter.Label(CrSchemaWindow, text="Block file for tablespace")
        CrSchemaWindow.LabelPath.grid(column=0, row=3, sticky='W', pady=(10, 0))

        CrSchemaWindow.entryPathVariable = Tkinter.StringVar()
        CrSchemaWindow.Entry2 = Tkinter.Entry(CrSchemaWindow, textvariable=CrSchemaWindow.entryPathVariable)
        CrSchemaWindow.Entry2.grid(column=0, row=4, sticky='EW', pady=(0, 20))
        CrSchemaWindow.entryPathVariable.set(ConfigSectionMap("Prefilled")['pathtoblock'])

        CrSchemaWindow.LabelSSH = Tkinter.Label(CrSchemaWindow, text="Credentials for SSH")
        CrSchemaWindow.LabelSSH.grid(column=0, row=5, sticky='NEWS')

        CrSchemaWindow.LabelUserSSH = Tkinter.Label(CrSchemaWindow, text="Username")
        CrSchemaWindow.LabelUserSSH.grid(column=0, row=6, sticky='W')

        CrSchemaWindow.entryUserSSHVariable = Tkinter.StringVar()
        CrSchemaWindow.Entry3 = Tkinter.Entry(CrSchemaWindow, textvariable=CrSchemaWindow.entryUserSSHVariable)
        CrSchemaWindow.Entry3.grid(column=0, row=7, sticky='EW')
        CrSchemaWindow.entryUserSSHVariable.set(ConfigSectionMap("Prefilled")['userssh'])


        CrSchemaWindow.LabelPwSSH = Tkinter.Label(CrSchemaWindow, text="Password")
        CrSchemaWindow.LabelPwSSH.grid(column=0, row=8, sticky='W')

        CrSchemaWindow.entryPwSSHVariable = Tkinter.StringVar()
        CrSchemaWindow.Entry4 = Tkinter.Entry(CrSchemaWindow, textvariable=CrSchemaWindow.entryUserSSHVariable, show="*")
        CrSchemaWindow.Entry4.grid(column=0, row=9, sticky='EW', pady=(0, 20))
        CrSchemaWindow.entryPwSSHVariable.set(ConfigSectionMap("Prefilled")['pwdssh'])

        
        buttonQuit = Tkinter.Button(CrSchemaWindow,text=u"Close window", command=CrSchemaWindow.CloseCrSchemaWindow)
        buttonQuit.grid (column=0, row=19, sticky="NEWS")

        buttonCreate = Tkinter.Button(CrSchemaWindow,text=u"Create the data now", command=lambda:
                                      CrSchemaWindow.CreateSchema(CrSchemaWindow.SID,CrSchemaWindow.user,CrSchemaWindow.passwd,CrSchemaWindow.ip,CrSchemaWindow.port,0))
        buttonCreate.grid (column=0, row=17, sticky="NEWS")

        buttonDrop = Tkinter.Button(CrSchemaWindow,text=u"Drop the test data now", command=lambda:
                                      CrSchemaWindow.DropSchema(CrSchemaWindow.SID,CrSchemaWindow.user,CrSchemaWindow.passwd,CrSchemaWindow.ip,CrSchemaWindow.port))
        buttonDrop.grid (column=0, row=18, sticky="NEWS")

        CrSchemaWindow.VocableVariable = Tkinter.StringVar()
        Vocable = Tkinter.Label(CrSchemaWindow,textvariable=CrSchemaWindow.VocableVariable, anchor="w", fg="white", bg="blue")
        Vocable.grid(column=0, row=16, columnspan=2, sticky='EW')
        CrSchemaWindow.VocableVariable.set(u"Hello !")
        
        CrSchemaWindow.grid_columnconfigure(0,weight=1)
        CrSchemaWindow.resizable(True,False)
        CrSchemaWindow.update()
        CrSchemaWindow.geometry(CrSchemaWindow.geometry())


    def CreateSchema(CrSchemaWindow, SID, user, passwd, ip, port, RatioVar):
        """
            1) create tablespace (works)
            2) create user (works)
            3) create tables
            4) generate data (EGen)
            5) import data into tables (+check for errors)
            6) create indexes
        """

        error_con = 0
        pathToBlock = CrSchemaWindow.entryPathVariable.get()
        username = CrSchemaWindow.entryUserSSHVariable.get()
        password = CrSchemaWindow.entryPwSSHVariable.get()
        SSHport = 22

        try:
            con = connectToOracle(str(ip), str(port), str(SID), "system", str(passwd))
        except cx_Oracle.DatabaseError as e:
            error, = e.args
            if error.code == 1017:
                CrSchemaWindow.VocableVariable.set(str(SID) + ": Invalid username or password")
                error_con = 1
            elif error.code == 12154:
                CrSchemaWindow.VocableVariable.set(str(SID) + ": TNS couldn't resolve the SID")
                error_con = 1
            elif error.code == 12543:
                CrSchemaWindow.VocableVariable.set(str(SID) + ": Destination host not available")
                error_con = 1
            else:
                CrSchemaWindow.VocableVariable.set(str(SID) + ": Unable to connect")
                error_con = 1

        if error_con != 1:
            cur = con.cursor()

            # create tablespace
            try:
                cur.execute("create bigfile tablespace \"TPCE\" datafile '" + pathToBlock + "' size 85G LOGGING EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO")

            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code != 900:
                    print error
                    error_con = 2

            if error_con == 0:
                print "STEP 1: Created tablespace"
                CrSchemaWindow.VocableVariable.set(str(SID) + ": STEP 1/10: Created tablespace")
                CrSchemaWindow.update()

            # create user
            f = open('./tpce/03tpce-create-user.sql')
            full_sql = f.read()
            sql_commands = full_sql.split(';')

            for sql_command in sql_commands:
                try:
                    cur.execute(sql_command)
                except cx_Oracle.DatabaseError as e:
                    error, = e.args
                    if error.code != 900:
                        print error
                        error_con = 2

            if error_con == 0:
                print "STEP 2: Created user"
                CrSchemaWindow.VocableVariable.set(str(SID) + ": STEP 2/10: Created user")
                CrSchemaWindow.update()

            # create tables
            f = open('./tpce/05tpce-create-tables.sql')
            full_sql = f.read()
            sql_commands = full_sql.split(';')

            for sql_command in sql_commands:
                try:
                    cur.execute(sql_command)
                except cx_Oracle.DatabaseError as e:
                    error, = e.args
                    if error.code != 900:
                        print error
                        error_con = 2

            if error_con == 0:
                print "STEP 3: Created tables"
                CrSchemaWindow.VocableVariable.set(str(SID) + ": STEP 3/10: Created tables")
                CrSchemaWindow.update()


            #     f = open('./queries/scott_ora.sql')
            #     full_sql = f.read()
            #     sql_commands = full_sql.split(';')
            #
            #     for sql_command in sql_commands:
            #         try:
            #             cur.execute(sql_command)
            #         except cx_Oracle.DatabaseError as e:
            #             error, = e.args
            #
            #
            #     try:
            #         cur.execute('create table scott.emp2 as select * from scott.emp')
            #     except cx_Oracle.DatabaseError as e:
            #         error, = e.args
            #         if error.code == 3113:
            #             cur.execute('drop table scott.emp2')
            #             cur.execute('create table scott.emp2 as select * from scott.emp')
            #         elif error.code == 955:
            #             cur.execute('drop table scott.emp2')
            #             cur.execute('create table scott.emp2 as select * from scott.emp')
            #         else:
            #             CrSchemaWindow.VocableVariable.set(str(SID) + ": Failed to create schema")
            #             cur.close()
            #             return
            #     try:
            #         cur.execute('create table scott.dwhstat (seq int not null primary key, elapsed int, insdate date)')
            #     except cx_Oracle.DatabaseError as e:
            #         error, = e.args
            #         if error.code == 955:
            #             cur.execute('truncate table scott.dwhstat')
            #
            #     try:
            #         cur.execute('CREATE SEQUENCE scott.seq START WITH 1 INCREMENT BY 1 NOCACHE')
            #     except cx_Oracle.DatabaseError as e:
            #         CreateSchemaProgressSchema already exists!")
            #
            cur.close()
            con.close()

        if error_con != 1:
            #path definition
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
            ssh.connect(hostname=ip, username=username, password=password)

            transport = paramiko.Transport((ip, SSHport))
            transport.connect(username=username, password=password)

            sftp = paramiko.SFTPClient.from_transport(transport)

            print "STEP 4: Connected to %s" % ip
            CrSchemaWindow.VocableVariable.set(str(SID) + ": STEP 4/10: Connected to " + ip)
            CrSchemaWindow.update()

            #Send commands for folder (re)creation (non-blocking)
            stdin, stdout, stderr = ssh.exec_command("rm -r -d -f /tmp/jery/")
            waitForTerminate(stdout)
            stdin, stdout, stderr = ssh.exec_command("mkdir /tmp/jery/")
            waitForTerminate(stdout)

            # Copy files to remote
            sftp.put(loaderSource, loaderDestination)
            sftp.put(inputSource, inputDestination)
            sftp.put(scriptSource, scriptDestination)
            print "STEP 5: Copied files to server"
            CrSchemaWindow.VocableVariable.set(str(SID) + ": STEP 5/10: Copied files to server")
            CrSchemaWindow.update()


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
            print "STEP 6: Unzipped files on server"
            CrSchemaWindow.VocableVariable.set(str(SID) + ": STEP 6/10: Unzipped files on server")
            CrSchemaWindow.update()
            stdin, stdout, stderr = ssh.exec_command(
                loaderDestination + " -i " + inputUnzipped + " -o " + outputPath) # + " -f 1000")
            waitForTerminate(stdout)
            stdin, stdout, stderr = ssh.exec_command("rm -f " + loaderDestination)
            waitForTerminate(stdout)
            print "STEP 7: Generated tables on server"
            CrSchemaWindow.VocableVariable.set(str(SID) + ": STEP 7/10: Generated tables on server")
            CrSchemaWindow.update()

            # Send commands for table import (non-blocking)
            stdin, stdout, stderr = ssh.exec_command("chmod +x " + scriptsUnzipped + "06ImportTPCETables.sh")
            waitForTerminate(stdout)
            stdin, stdout, stderr = ssh.exec_command("sed -i -e 's/\\r$//' " + scriptsUnzipped + "06ImportTPCETables.sh")
            waitForTerminate(stdout)
            stdin, stdout, stderr = ssh.exec_command("cd " + scriptsUnzipped + " && ./06ImportTPCETables.sh")
            waitForTerminate(stdout)

            # print stderr.readlines()
            # print stdout.readlines()

            try:
                con = connectToOracle(str(ip), str(port), str(SID), "system", str(passwd))
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 1017:
                    CrSchemaWindow.VocableVariable.set(str(SID) + ": Invalid username or password")
                    error_con = 1
                elif error.code == 12154:
                    CrSchemaWindow.VocableVariable.set(str(SID) + ": TNS couldn't resolve the SID")
                    error_con = 1
                elif error.code == 12543:
                    CrSchemaWindow.VocableVariable.set(str(SID) + ": Destination host not available")
                    error_con = 1
                else:
                    CrSchemaWindow.VocableVariable.set(str(SID) + ": Unable to connect")
                    error_con = 1

            cur = con.cursor()

            noProcesses = 100

            # wait until import is finished
            sys.stdout.write("Import is not finished yet. Waiting")
            sys.stdout.flush()
            while (noProcesses != 0):
                sys.stdout.write(".")
                sys.stdout.flush()
                time.sleep(30)
                cur.execute("select count(*) from v$session where program like '%sqlldr%'")

                for result in cur:
                    noProcesses = result[0]

            print "\nSTEP 8: Imported tables in database"
            CrSchemaWindow.VocableVariable.set(str(SID) + ": STEP 8/10: Imported tables in database")
            CrSchemaWindow.update()

            cur.close()
            con.close()
            sftp.close()
            transport.close()
            ssh.close()


        if error_con != 1:
            try:
                con = connectToOracle(str(ip), str(port), str(SID), "TPCE", "TPCE")
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 1017:
                    CrSchemaWindow.VocableVariable.set(str(SID) + ": Invalid username or password")
                    error_con = 1
                elif error.code == 12154:
                    CrSchemaWindow.VocableVariable.set(str(SID) + ": TNS couldn't resolve the SID")
                    error_con = 1
                elif error.code == 12543:
                    CrSchemaWindow.VocableVariable.set(str(SID) + ": Destination host not available")
                    error_con = 1
                else:
                    CrSchemaWindow.VocableVariable.set(str(SID) + ": Unable to connect")
                    error_con = 1

            if error_con != 1:
                cur = con.cursor()
                # create indexes 1
                f = open('./tpce/07tpce-create-pk.sql')
                full_sql = f.read()
                sql_commands = full_sql.split(';')

                for sql_command in sql_commands:
                    try:
                        cur.execute(sql_command)
                    except cx_Oracle.DatabaseError as e:
                        error, = e.args
                        if error.code != 900:
                            print error
                            error_con = 2
                print "created pks"

                # create indexes 2
                f = open('./tpce/08_1tpce-create-fk.sql')
                full_sql = f.read()
                sql_commands = full_sql.split(';')

                for sql_command in sql_commands:
                    try:
                        cur.execute(sql_command)
                    except cx_Oracle.DatabaseError as e:
                        error, = e.args
                        if error.code != 900:
                            print error
                            error_con = 2
                print "created fks 1"

                # create indexes 3
                f = open('./tpce/08_2tpce-create-fk.sql')
                full_sql = f.read()
                sql_commands = full_sql.split(';')

                for sql_command in sql_commands:
                    try:
                        cur.execute(sql_command)
                    except cx_Oracle.DatabaseError as e:
                        error, = e.args
                        if error.code != 900:
                            print error
                            error_con = 2
                print "created fks 2"

                # create indexes 4
                f = open('./tpce/08_3tpce-create-fk.sql')
                full_sql = f.read()
                sql_commands = full_sql.split(';')

                for sql_command in sql_commands:
                    try:
                        cur.execute(sql_command)
                    except cx_Oracle.DatabaseError as e:
                        error, = e.args
                        if error.code != 900:
                            print error
                            error_con = 2
                print "created fks 3"

                # create indexes 5
                f = open('./tpce/08_4tpce-create-fk.sql')
                full_sql = f.read()
                sql_commands = full_sql.split(';')

                for sql_command in sql_commands:
                    try:
                        cur.execute(sql_command)
                    except cx_Oracle.DatabaseError as e:
                        error, = e.args
                        if error.code != 900:
                            print error
                            error_con = 2
                print "created fks 4"

                if error_con == 0:
                    print "STEP 9: Created indexes"
                    CrSchemaWindow.VocableVariable.set(str(SID) + ": STEP 9/10: Created indexes")
                    CrSchemaWindow.update()

                cur.close()
                con.close()

            if error_con != 1:
                try:
                    con = connectToOracle(str(ip), str(port), str(SID), "system", str(passwd))
                except cx_Oracle.DatabaseError as e:
                    error, = e.args
                    if error.code == 1017:
                        CrSchemaWindow.VocableVariable.set(str(SID) + ": Invalid username or password")
                        error_con = 1
                    elif error.code == 12154:
                        CrSchemaWindow.VocableVariable.set(str(SID) + ": TNS couldn't resolve the SID")
                        error_con = 1
                    elif error.code == 12543:
                        CrSchemaWindow.VocableVariable.set(str(SID) + ": Destination host not available")
                        error_con = 1
                    else:
                        CrSchemaWindow.VocableVariable.set(str(SID) + ": Unable to connect")
                        error_con = 1

                cur = con.cursor()
                # calculate statistics
                f = open('./tpce/10tpce_calculate_statistics.sql')
                full_sql = f.read()
                sql_commands = full_sql.split(';')

                for sql_command in sql_commands:
                    try:
                        cur.execute(sql_command)
                    except cx_Oracle.DatabaseError as e:
                        error, = e.args
                        if error.code != 900:
                            print error
                            error_con = 2

                try:
                    cur.execute("""INSERT INTO TPCE.tpcestat(statid, brokervolumecount, customerpositioncount, marketfeedcount,
                        marketwatchcount, securitydetailcount, tradelookupcount, tradeordercount, traderesultcount,
                        tradestatuscount, tradeupdatecount, datamaintenancecount) 
                        VALUES('0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0')""")
                except cx_Oracle.DatabaseError as e:
                    error, = e.args
                    if error.code != 900:
                        print error
                        error_con = 2

                try:
                    cur.execute('CREATE SEQUENCE tpce.seq START WITH 1 INCREMENT BY 1 NOCACHE')
                except cx_Oracle.DatabaseError as e:
                    error, = e.args
                    if error.code != 900:
                        print error
                        error_con = 2

                if error_con == 0:
                    print "STEP 10: Calculated statistics"
                    CrSchemaWindow.VocableVariable.set(str(SID) + ": STEP 10/10: Calculated statistics")
                    CrSchemaWindow.update()


    def DropSchema(CrSchemaWindow, SID, user, passwd, ip, port):
        """ Test if the connection parameters are valid.
            - If the connection is valid print the db_name into the vocable label.
                Otherwise print an error message.
        """
        error_con = 0

        try:
            con = connectToOracle(str(ip), str(port), str(SID), "system", str(passwd))
        except cx_Oracle.DatabaseError as e:
            error, = e.args
            if error.code == 1017:
                CrSchemaWindow.VocableVariable.set(str(SID) + ": Invalid username or password")
                error_con = 1
            elif error.code == 12154:
                CrSchemaWindow.VocableVariable.set(str(SID) + ": TNS couldn't resolve the SID")
                error_con = 1
            elif error.code == 12543:
                CrSchemaWindow.VocableVariable.set(str(SID) + ": Destination host not available")
                error_con = 1
            else:
                CrSchemaWindow.VocableVariable.set(str(SID) + ": Unable to connect")
                error_con = 1

        if error_con != 1:
            cur = con.cursor()

            # drop user
            f = open('./tpce/21tpce-drop-user.sql')
            full_sql = f.read()
            sql_commands = full_sql.split(';')

            for sql_command in sql_commands:
                try:
                    cur.execute(sql_command)

                except cx_Oracle.DatabaseError as e:
                    error, = e.args
                    if error.code == 1918:
                        CrSchemaWindow.VocableVariable.set('Test schema does not exist')
                        error_con = 2
                    elif error.code != 900:
                        CrSchemaWindow.VocableVariable.set(str(SID) + ": Failed to drop the test schema")
                        error_con = 2

            # drop tablespace
            f = open('./tpce/22tpce-drop-tbs.sql')
            full_sql = f.read()
            sql_commands = full_sql.split(';')

            for sql_command in sql_commands:
                try:
                    cur.execute(sql_command)

                except cx_Oracle.DatabaseError as e:
                    error, = e.args
                    if error.code == 959:
                        CrSchemaWindow.VocableVariable.set('Test schema does not exist')
                        error_con = 2
                    elif error.code != 900:
                        CrSchemaWindow.VocableVariable.set(str(SID) + ": Failed to drop the test schema")
                        error_con = 2


            cur.close()
            con.close()
            if error_con == 0:
                CrSchemaWindow.VocableVariable.set(str(SID) + ": Test schema dropped!")


    def Statistics(CrSchemaWindow, SID, user, passwd, ip, port):
        """ Used generating staistics in SCOTT schema.
        """

        con = connectToOracle(str(ip), str(port), str(SID), "system", str(passwd))
        cur3 = con.cursor()
        cur3.execute("""
        begin
        
        dbms_stats.gather_schema_stats(:name, estimate_percent => 100, method_opt => :method, options => :options, cascade => true,degree => 4);
        end;""",
                     name = 'SCOTT',
                     method = 'for all columns size auto',
                     options = 'gather stale')
        con.close()
        CrSchemaWindow.VocableVariable.set("Test schema created with ratio: {0}".format(str(CrSchemaWindow.RatioVar.get())))


        
    def CloseCrSchemaWindow(CrSchemaWindow):
        """Close the window and decrement the number of toplevel window counter
        """
        global OpenToplevel
        OpenToplevel -= 1
        CrSchemaWindow.destroy()


    def handler(CrSchemaWindow):
        """ Close properly the Toplevel window if the user click the "x" button
        """
        CrSchemaWindow.CloseCrSchemaWindow()


class CreateAProposWindow(Tkinter.Toplevel):
    def __init__(AProposWindow):
        Tkinter.Toplevel.__init__(AProposWindow)

        """
            Classe A Propos
            Deliver information about this program.
        """

        AProposWindow.wm_title(" A Propos... ")
        version = ConfigSectionMap("Info")['version']
        build = ConfigSectionMap("Info")['build']
        contact = ConfigSectionMap("Info")['contact']
        AProposWindow.LabelVersion = Tkinter.Label(AProposWindow, text="Version: " + version)
        AProposWindow.LabelDate = Tkinter.Label(AProposWindow, text="Build: " + build)
        AProposWindow.LabelContact = Tkinter.Label(AProposWindow, text="Contact: " + contact)
        AProposWindow.LabelVersion.grid(column=0, row=1)
        AProposWindow.LabelDate.grid(column=0, row=2)
        AProposWindow.LabelContact.grid(column=0, row=3)

        buttonQuit = Tkinter.Button(AProposWindow,text=u"Close window", command=AProposWindow.destroy, width=20)
        buttonQuit.grid(column=0, row=15, sticky=S)

        AProposWindow.grid_columnconfigure(0,weight=1)
        AProposWindow.resizable(True,False)
        AProposWindow.update()
        AProposWindow.geometry(AProposWindow.geometry())


class GraphWindow(Tkinter.Toplevel):
    def __init__(GraphWindow, user, passwd, SID, ip, port):
        Tkinter.Toplevel.__init__(GraphWindow, height=600, width=450)

        """ This window shows graphically the evolution of the job execution time.
            3 procedures in this class:
            - run
            - stop
            - handling for the "x" button press. Need to properly close the Toplevel window
        """

        GraphWindow.wm_title(" -- Queries execution time -- ")
        GraphWindow.geometry ("450x600")
        GraphWindow.user = user
        GraphWindow.passwd = passwd
        GraphWindow.SID = SID
        GraphWindow.ip = ip
        GraphWindow.port = port
        GraphWindow.LoopGraphVar = 0
        GraphWindow.resizable(False,False)
        GraphWindow.protocol("WM_DELETE_WINDOW", GraphWindow.handler)
        GraphWindow.update()
        
        buttonQuit = Tkinter.Button(GraphWindow,text=u"Close window", command=GraphWindow.StopGraph, width=20)
        buttonQuit.pack (side=BOTTOM)

        """
            Global variable checking the status of the toplevel windows opening a thread
        """
        global OpenToplevel
        OpenToplevel += 1

        GraphThread = threading.Thread(target=GraphWindow.RunGraph, args=())
        GraphThread.start()
     

    def RunGraph(GraphWindow):
        """
            Graph runs in a loop until quit is hited
            Print a bar in a chart for the last 200 completed jobs
            Refresh done every 2 seconds by a complete redesign of the graph.
        """    
        while GraphWindow.LoopGraphVar == 0:
            error_con = 0
            c_width = 450
            c_height = 600
            c = Tkinter.Canvas(GraphWindow, width=c_width, height=c_height, bg='white')

            y_stretch = 15
            y_gap = 20
            x_stretch = 10
            x_width = 20
            x_gap = 20
            pos = 1


            """Test the connection before printing the graph"""
            try:
                con = connectToOracle(GraphWindow.ip, GraphWindow.port, GraphWindow.SID, GraphWindow.user, GraphWindow.passwd)
            except cx_Oracle.DatabaseError:
                error_con = 1
                return error_con

            """if the connection is established, read the latest events of the stat table -dwhstat- and print the graph"""
            if error_con != 1:
                curRampUp = con.cursor()
                curRampUp.execute('select count(*) from dwhstat')
                for result in curRampUp:
                    curValue = con.cursor()
                    if int(result[0]) > 0:
                        curValue.execute('select elapsed from (select seq, elapsed from dwhstat) where seq>(select max(seq) - 20 from dwhstat) order by seq')
                        for y in curValue:
                            x0 = pos * 20 +10
                            y0 = c_height - (int(y[0]) * y_stretch + y_gap)
                            x1 = pos * 20 +25
                            y1 = c_height - y_gap
                            c.create_rectangle(x0, y0, x1, y1, fill="red")
                            c.create_text(x0 + 2, y0, anchor=Tkinter.SW, text=str(int(y[0])))
                            pos += 1

                    curValue.close()
                c.pack()
                refresh = int(ConfigSectionMap("Settings")['refresh'])
                time.sleep(refresh)
                c.destroy()
                

    def StopGraph(GraphWindow):
        """Close the window and decrement the number of toplevel window counter
        """
        global OpenToplevel

        OpenToplevel -= 1
        GraphWindow.LoopGraphVar = 1
        GraphWindow.after(2000, GraphWindow.destroy)


    def handler(GraphWindow):
        """ Close properly the Toplevel window if the user click the "x" button
        """
        GraphWindow.StopGraph()
                    

class ExtendedStatisticsWindow(Tkinter.Toplevel):
    def __init__(statWindow, SID, passwd, ip, port):
        Tkinter.Toplevel.__init__(statWindow)

        """
            This procedure collects statistics from the system tables of the Oracle database
            It prints for up to 4 nodes:
            - the node name
            - ORACLE_SID
            - the number of users connected to the instance
            - the average CPU usage for the last 15 seconds
            - the average number of SQL orders/sec for the last 15 seconds
            - the average IOMB/sec for the last 15 seconds
            - the average number of block reads/ sec for the last 15 seconds.
            Variable naming is static
        """    

        statWindow.wm_title(" TPC-E Statistics")
        statWindow.SID = SID
        statWindow.passwd = passwd
        statWindow.ip = ip
        statWindow.port = port
        statWindow.LoopWindowVar = 0
        statWindow.protocol("WM_DELETE_WINDOW", statWindow.handler)

        """ Global variable checking the status of the toplevel windows opening a thread  """
        global OpenToplevel
        OpenToplevel += 1

        """ Label and Entry definition  """
        
        statWindow.LabelTxnMix = Tkinter.Label(statWindow, text="Transaction Mix")
        statWindow.LabelTxnMix.grid(column=0, row=0)

        statWindow.LabelTxnCount = Tkinter.Label(statWindow, text="Transaction Count")
        statWindow.LabelTxnCount.grid(column=1, row=0)

        statWindow.LabelMixPerc = Tkinter.Label(statWindow, text="Mix %")
        statWindow.LabelMixPerc.grid(column=2, row=0)

        statWindow.EntryTxnMix1var = Tkinter.StringVar()
        statWindow.EntryTxnMix1 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnMix1var,\
                                                width=12)
        statWindow.EntryTxnMix1.grid(column=0, row=1, sticky='EW')

        statWindow.EntryTxnCount1var = Tkinter.StringVar()
        statWindow.EntryTxnCount1 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnCount1var,\
                                                width=12)
        statWindow.EntryTxnCount1.grid(column=1, row=1, sticky='EW')

        statWindow.EntryMixPerc1var = Tkinter.StringVar()
        statWindow.EntryMixPerc1 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryMixPerc1var,\
                                                width=12)
        statWindow.EntryMixPerc1.grid(column=2, row=1, sticky='EW')


        statWindow.EntryTxnMix2var = Tkinter.StringVar()
        statWindow.EntryTxnMix2 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnMix2var,\
                                                width=12)
        statWindow.EntryTxnMix2.grid(column=0, row=2, sticky='EW')

        statWindow.EntryTxnCount2var = Tkinter.StringVar()
        statWindow.EntryTxnCount2 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnCount2var,\
                                                width=12)
        statWindow.EntryTxnCount2.grid(column=1, row=2, sticky='EW')

        statWindow.EntryMixPerc2var = Tkinter.StringVar()
        statWindow.EntryMixPerc2 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryMixPerc2var,\
                                                width=12)
        statWindow.EntryMixPerc2.grid(column=2, row=2, sticky='EW')


        statWindow.EntryTxnMix3var = Tkinter.StringVar()
        statWindow.EntryTxnMix3 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnMix3var,\
                                                width=12)
        statWindow.EntryTxnMix3.grid(column=0, row=3, sticky='EW')

        statWindow.EntryTxnCount3var = Tkinter.StringVar()
        statWindow.EntryTxnCount3 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnCount3var,\
                                                width=12)
        statWindow.EntryTxnCount3.grid(column=1, row=3, sticky='EW')

        statWindow.EntryMixPerc3var = Tkinter.StringVar()
        statWindow.EntryMixPerc3 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryMixPerc3var,\
                                                width=12)
        statWindow.EntryMixPerc3.grid(column=2, row=3, sticky='EW')
        

        statWindow.EntryTxnMix4var = Tkinter.StringVar()
        statWindow.EntryTxnMix4 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnMix4var,\
                                                width=12)
        statWindow.EntryTxnMix4.grid(column=0, row=4, sticky='EW')

        statWindow.EntryTxnCount4var = Tkinter.StringVar()
        statWindow.EntryTxnCount4 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnCount4var,\
                                                width=12)
        statWindow.EntryTxnCount4.grid(column=1, row=4, sticky='EW')

        statWindow.EntryMixPerc4var = Tkinter.StringVar()
        statWindow.EntryMixPerc4 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryMixPerc4var,\
                                                width=12)
        statWindow.EntryMixPerc4.grid(column=2, row=4, sticky='EW')
        

        statWindow.EntryTxnMix5var = Tkinter.StringVar()
        statWindow.EntryTxnMix5 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnMix5var, \
                                                width=12)
        statWindow.EntryTxnMix5.grid(column=0, row=5, sticky='EW')

        statWindow.EntryTxnCount5var = Tkinter.StringVar()
        statWindow.EntryTxnCount5 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnCount5var, \
                                                  width=12)
        statWindow.EntryTxnCount5.grid(column=1, row=5, sticky='EW')

        statWindow.EntryMixPerc5var = Tkinter.StringVar()
        statWindow.EntryMixPerc5 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryMixPerc5var, \
                                                 width=12)
        statWindow.EntryMixPerc5.grid(column=2, row=5, sticky='EW')
        

        statWindow.EntryTxnMix6var = Tkinter.StringVar()
        statWindow.EntryTxnMix6 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnMix6var, \
                                                width=12)
        statWindow.EntryTxnMix6.grid(column=0, row=6, sticky='EW')

        statWindow.EntryTxnCount6var = Tkinter.StringVar()
        statWindow.EntryTxnCount6 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnCount6var, \
                                                  width=12)
        statWindow.EntryTxnCount6.grid(column=1, row=6, sticky='EW')

        statWindow.EntryMixPerc6var = Tkinter.StringVar()
        statWindow.EntryMixPerc6 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryMixPerc6var, \
                                                 width=12)
        statWindow.EntryMixPerc6.grid(column=2, row=6, sticky='EW')
        

        statWindow.EntryTxnMix7var = Tkinter.StringVar()
        statWindow.EntryTxnMix7 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnMix7var, \
                                                width=12)
        statWindow.EntryTxnMix7.grid(column=0, row=7, sticky='EW')

        statWindow.EntryTxnCount7var = Tkinter.StringVar()
        statWindow.EntryTxnCount7 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnCount7var, \
                                                  width=12)
        statWindow.EntryTxnCount7.grid(column=1, row=7, sticky='EW')

        statWindow.EntryMixPerc7var = Tkinter.StringVar()
        statWindow.EntryMixPerc7 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryMixPerc7var, \
                                                 width=12)
        statWindow.EntryMixPerc7.grid(column=2, row=7, sticky='EW')
        

        statWindow.EntryTxnMix8var = Tkinter.StringVar()
        statWindow.EntryTxnMix8 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnMix8var, \
                                                width=12)
        statWindow.EntryTxnMix8.grid(column=0, row=8, sticky='EW')

        statWindow.EntryTxnCount8var = Tkinter.StringVar()
        statWindow.EntryTxnCount8 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnCount8var, \
                                                  width=12)
        statWindow.EntryTxnCount8.grid(column=1, row=8, sticky='EW')

        statWindow.EntryMixPerc8var = Tkinter.StringVar()
        statWindow.EntryMixPerc8 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryMixPerc8var, \
                                                 width=12)
        statWindow.EntryMixPerc8.grid(column=2, row=8, sticky='EW')
        

        statWindow.EntryTxnMix9var = Tkinter.StringVar()
        statWindow.EntryTxnMix9 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnMix9var, \
                                                width=12)
        statWindow.EntryTxnMix9.grid(column=0, row=9, sticky='EW')

        statWindow.EntryTxnCount9var = Tkinter.StringVar()
        statWindow.EntryTxnCount9 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnCount9var, \
                                                  width=12)
        statWindow.EntryTxnCount9.grid(column=1, row=9, sticky='EW')

        statWindow.EntryMixPerc9var = Tkinter.StringVar()
        statWindow.EntryMixPerc9 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryMixPerc9var, \
                                                 width=12)
        statWindow.EntryMixPerc9.grid(column=2, row=9, sticky='EW')
        

        statWindow.EntryTxnMix10var = Tkinter.StringVar()
        statWindow.EntryTxnMix10 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnMix10var, \
                                                width=12)
        statWindow.EntryTxnMix10.grid(column=0, row=10, sticky='EW')

        statWindow.EntryTxnCount10var = Tkinter.StringVar()
        statWindow.EntryTxnCount10 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnCount10var, \
                                                  width=12)
        statWindow.EntryTxnCount10.grid(column=1, row=10, sticky='EW')

        statWindow.EntryMixPerc10var = Tkinter.StringVar()
        statWindow.EntryMixPerc10 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryMixPerc10var, \
                                                 width=12)
        statWindow.EntryMixPerc10.grid(column=2, row=10, sticky='EW')
        

        statWindow.EntryTxnMix11var = Tkinter.StringVar()
        statWindow.EntryTxnMix11 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnMix11var, \
                                                width=12)
        statWindow.EntryTxnMix11.grid(column=0, row=11, sticky='EW')

        statWindow.EntryTxnCount11var = Tkinter.StringVar()
        statWindow.EntryTxnCount11 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTxnCount11var, \
                                                  width=12)
        statWindow.EntryTxnCount11.grid(column=1, row=11, sticky='EW')

        statWindow.EntryMixPerc11var = Tkinter.StringVar()
        statWindow.EntryMixPerc11 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryMixPerc11var, \
                                                 width=12)
        statWindow.EntryMixPerc11.grid(column=2, row=11, sticky='EW')

        can1 = Canvas(statWindow, width=300, height=20)
        can1.grid(column=0, row=12, columnspan=3, padx=10, pady=10)
        can1.create_line(10, 10, 540, 10, width=3, fill='white')


        statWindow.LabelTPCEscore = Tkinter.Label(statWindow, text="TPC-E Throughput:")
        statWindow.LabelTPCEscore.grid(column=0, row=13, columnspan=2, sticky="W")

        statWindow.EntryTPCEscorevar = Tkinter.StringVar()
        statWindow.EntryTPCEscore = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTPCEscorevar, \
                                                width=12)
        statWindow.EntryTPCEscore.grid(column=2, row=13, sticky='EW')
        

        statWindow.LabelTotalNo = Tkinter.Label(statWindow, text="Total No. of Transactions Completed:")
        statWindow.LabelTotalNo.grid(column=0, row=14, columnspan=2, sticky="W")

        statWindow.EntryTotalNovar = Tkinter.StringVar()
        statWindow.EntryTotalNo = Tkinter.Entry(statWindow, textvariable=statWindow.EntryTotalNovar, \
                                                   width=12)
        statWindow.EntryTotalNo.grid(column=2, row=14, sticky='EW')

        """ Button definition  """
        buttonQuit = Tkinter.Button(statWindow,text=u"Quit Statistics", command=statWindow.StopStatWindow, width=12)
        buttonQuit.grid (column=2, row=23, sticky="NEWS")

        """ Vocable blue bar Entry definition  """
        statWindow.VocableVariable = Tkinter.StringVar()
        Vocable = Tkinter.Label(statWindow,textvariable=statWindow.VocableVariable, anchor="w", fg="white", bg="blue")
        Vocable.grid(column=0, row=23, columnspan=2, sticky='EW')
        statWindow.VocableVariable.set(u"Hello !")

        """ Start data collecting thread  """
        StatThread = threading.Thread(target=statWindow.CollectStat, args=(statWindow.SID, statWindow.passwd, statWindow.ip, statWindow.port))
        StatThread.start()
        
        statWindow.grid_columnconfigure(0,weight=1)
        statWindow.resizable(True,False)
        statWindow.update()
        statWindow.geometry(statWindow.geometry())


    def CollectStat(statWindow, SID, passwd, ip, port):
        """ Test if the connection parameters are valid.
            - If the connection is valid print the db_name into the vocable label.
                Otherwise print an error message.
        """
        txnNames = ["Broker-Volume",
                    "Customer-Position",
                    "Market-Feed",
                    "Market-Watch",
                    "Security-Detail",
                    "Trade-Lookup",
                    "Trade-Order",
                    "Trade-Result",
                    "Trade-Status",
                    "Trade-Update",
                    "Data-Maintenance"]

        while statWindow.LoopWindowVar == 0:
            error_con = 0

            try:
                con = connectToOracle(str(ip), str(port), str(SID), "TPCE", "TPCE")
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 1017:
                    statWindow.VocableVariable.set(str(SID) + ": Invalid username or password")
                    error_con = 1
                elif error.code == 12154:
                    statWindow.VocableVariable.set(str(SID) + ": TNS couldn't resolve the SID")
                    error_con = 1
                elif error.code == 12543:
                    statWindow.VocableVariable.set(str(SID) + ": Destination host not available")
                    error_con = 1
                else:
                    statWindow.VocableVariable.set(str(SID) + ": Unable to connect")
                    error_con = 1
                
            if error_con != 1:
                cur = con.cursor()
                counter = 0
                cur.execute('select BROKERVOLUMECOUNT, CUSTOMERPOSITIONCOUNT, MARKETFEEDCOUNT, MARKETWATCHCOUNT, SECURITYDETAILCOUNT,'
                            'TRADELOOKUPCOUNT, TRADEORDERCOUNT, TRADERESULTCOUNT, TRADESTATUSCOUNT, TRADEUPDATECOUNT, DATAMAINTENANCECOUNT from tpcestat')
                res = cur.fetchall()

                cur1 = con.cursor()
                cur1.execute('select count(*) from dwhstat where (sysdate - insdate)*60*60*24 <61')
                for result in cur1:
                    NbExecTime = str(int(result[0]))
                    tpceScore = int(NbExecTime) / 60
                cur1.close()

                if len(res) == 1:
                    absCounts = map(int, res[0])
                    totalCounts = np.sum(absCounts)
                    relCounts = np.zeros(11)

                    for i in range(0, len(absCounts)):
                        relCounts[i] = absCounts[i] / totalCounts

                    # print "\n{:<21} {:<21} {:<10}".format('Transaction Mix', 'Transaction Count', 'Mix %')
                    # print "------------------------------------------------------------"
                    # for i in range(0, len(txnNames)):
                    #     print "{:<21} {:<21} {:<10}".format(txnNames[i], str(absCounts[i]), str(relCounts[i]))

                    entrysFirstColumn = [statWindow.EntryTxnMix1var,
                                         statWindow.EntryTxnMix2var,
                                         statWindow.EntryTxnMix3var,
                                         statWindow.EntryTxnMix4var,
                                         statWindow.EntryTxnMix5var,
                                         statWindow.EntryTxnMix6var,
                                         statWindow.EntryTxnMix7var,
                                         statWindow.EntryTxnMix8var,
                                         statWindow.EntryTxnMix9var,
                                         statWindow.EntryTxnMix10var,
                                         statWindow.EntryTxnMix11var]

                    entrysSecondColumn = [statWindow.EntryTxnCount1var,
                                         statWindow.EntryTxnCount2var,
                                         statWindow.EntryTxnCount3var,
                                         statWindow.EntryTxnCount4var,
                                         statWindow.EntryTxnCount5var,
                                         statWindow.EntryTxnCount6var,
                                         statWindow.EntryTxnCount7var,
                                         statWindow.EntryTxnCount8var,
                                         statWindow.EntryTxnCount9var,
                                         statWindow.EntryTxnCount10var,
                                         statWindow.EntryTxnCount11var]

                    entrysThirdColumn = [statWindow.EntryMixPerc1var,
                                          statWindow.EntryMixPerc2var,
                                          statWindow.EntryMixPerc3var,
                                          statWindow.EntryMixPerc4var,
                                          statWindow.EntryMixPerc5var,
                                          statWindow.EntryMixPerc6var,
                                          statWindow.EntryMixPerc7var,
                                          statWindow.EntryMixPerc8var,
                                          statWindow.EntryMixPerc9var,
                                          statWindow.EntryMixPerc10var,
                                          statWindow.EntryMixPerc11var]
                    
                    for i in range(0, 11):
                        entrysFirstColumn[i].set(str(txnNames[i]))
                        entrysSecondColumn[i].set(str(absCounts[i]))
                        entrysThirdColumn[i].set(str(relCounts[i]))
                    
                    statWindow.EntryTPCEscorevar.set(str(tpceScore))
                    statWindow.EntryTotalNovar.set(str(totalCounts))

                statWindow.VocableVariable.set("You are connected to {0}".format(str(SID)))
                cur.close()
                con.close()
                time.sleep(2)
        

    def StopStatWindow(statWindow):
        """ Close the window and decrement the number of toplevel window counter
        """
        global OpenToplevel
        OpenToplevel -= 1
        statWindow.LoopWindowVar = 1
        statWindow.after(2000, statWindow.destroy)


    def handler(statWindow):
        """ Close properly the Toplevel window if the user click the "x" button
        """
        statWindow.StopStatWindow()
################################################################




##########################  HELPER  ############################ 
class LoadThread(threading.Thread):
    def __init__(self, OraUser, OraPwd, OraConnect, OraIp, OraPort, LengthTest):
        """
           Initialisation of the execution thread.
           Parameters received:
           - Schema to be used
           - Password of the schema
           - Connect string of the instance
           - Test length. If 0 is received, the test will run one week (604800 seconds).
                Otherwise, the parameter is converted in seconds.
        """        
        threading.Thread.__init__(self)
        self.OraUser = OraUser
        self.OraPwd = OraPwd
        self.OraConnect = OraConnect
        self.OraIp = OraIp
        self.OraPort = OraPort
        self.LengthTest = LengthTest
        if self.LengthTest == 0:
            self.LengthTest = 604800
        else:
            self.LengthTest = self.LengthTest * 60
        self.runLoad = 0

    def printDBMSoutput(self, cur):
        statusVar = cur.var(cx_Oracle.NUMBER)
        lineVar = cur.var(cx_Oracle.STRING)
        while True:
            cur.callproc("dbms_output.get_line", (lineVar, statusVar))
            if statusVar.getvalue() != 0:
                break
            print lineVar.getvalue()

    def brokervolumeTransaction(self, con):
       if con:
            cur = con.cursor()

            try:
                cur.callproc("dbms_output.enable")
                cur.execute("""
                    DECLARE
                    in_sector_name VARCHAR2(50);
                    list_len INTEGER;
                    status INTEGER;
                    i INTEGER;
    
                    in_broker_list  Brokervolume_pkg.B_NAME_ARRAY := Brokervolume_pkg.B_NAME_ARRAY ();
                    broker_name  Brokervolume_pkg.B_NAME_ARRAY := Brokervolume_pkg.B_NAME_ARRAY ();
                    volume Brokervolume_pkg.VOL_ARRAY := Brokervolume_pkg.VOL_ARRAY();
                    brokervolframe1_tbl  Brokervolume_pkg.brokervolframe1_tab;
    
                    BEGIN
                    
                    SELECT SC_NAME INTO in_sector_name FROM ( SELECT SC_NAME, row_number() OVER (ORDER BY sc_name) 
                    rno from sector order by rno) where  rno = ( select round (dbms_random.value (0,11)) from dual);
                    
                    SELECT b_name BULK COLLECT INTO in_broker_list FROM ( SELECT b_name , row_number() over (order by b_name) rno FROM broker )
                            WHERE  rno < ( SELECT round (dbms_random.value (25,50)) FROM dual) 
                            AND rno > ( SELECT round (dbms_random.value (0,25)) FROM dual);
    
                    dbms_output.put_line('ins_sec: ' || in_sector_name);
                    brokervolframe1_tbl := Brokervolume_pkg.BrokerVolumeFrame1(in_broker_list ,in_sector_name,broker_name,list_len,status,volume);
    
                    dbms_output.put_line('list_len: ' || list_len);
                    dbms_output.put_line('status_out: ' || status);
                    --FOR i IN 1..30
                    --LOOP
                    --dbms_output.put_line('volume'|| volume(i));
                    --END LOOP;
                    END;
                """)
            except cx_Oracle.DatabaseError:
                pass

            #LoadThread.printDBMSoutput(self, cur)
            print "bv"

            cur.close()

    def customerpositionTransaction(self, con):
        if con:
            cur = con.cursor()

            cur.callproc("dbms_output.enable")
            cur.execute("""
                DECLARE 
                cust_id   NUMBER(11);
                tax_id  VARCHAR(20);
                acct_len  INTEGER;
                c_ad_id  NUMBER(11); 
                c_area_1  VARCHAR(3);
                c_area_2  VARCHAR(3);
                c_area_3  VARCHAR(3);
                c_ctry_1  VARCHAR(3); 
                c_ctry_2  VARCHAR(3);
                c_ctry_3  VARCHAR(3);
                --	c_dob  DATE;
                c_email_1  VARCHAR(50);
                c_email_2  VARCHAR(50);
                c_ext_1  VARCHAR(5);
                c_ext_2  VARCHAR(5);
                c_ext_3  VARCHAR(5);
                c_f_name  VARCHAR(30);
                c_gndr  VARCHAR(1);
                c_l_name  VARCHAR(30);
                c_local_1  VARCHAR(10);
                c_local_2  VARCHAR(10);
                c_local_3  VARCHAR(10);
                c_m_name  VARCHAR(1);
                c_st_id  VARCHAR(4);
                c_tier  NUMBER(38);
                status  INTEGER;
                acct_id CustomerPosition_pkg.ID_ARRAY :=	CustomerPosition_pkg.ID_ARRAY();
                asset_total CustomerPosition_pkg.TOT_ARRAY :=	CustomerPosition_pkg.TOT_ARRAY();
                cash_bal CustomerPosition_pkg.TOT_ARRAY :=	CustomerPosition_pkg.TOT_ARRAY();	
                c_dob DATE := SYSDATE ;
                
                customerPositionFrame1_tbl  CustomerPosition_pkg.CustomerPositionFrame1_tab := CustomerPosition_pkg.CustomerPositionFrame1_tab();
                
                customerFramerec CustomerPosition_pkg.CustomerPositionFrame1_record ;
                
                
                
                BEGIN 
                
                select c_id into cust_id from ( select c_id, row_number() over (order by c_id) rno from customer order by rno) where  rno = ( select round (dbms_random.value (0,5000)) from dual);
                select tx_id into tax_id from ( select tx_id, row_number() over (order by tx_id) rno from taxrate order by rno) where  rno = ( select round (dbms_random.value (0,320)) from dual);
                
                customerPositionFrame1_tbl := CustomerPosition_pkg.CustomerPositionFrame1(cust_id ,tax_id ,acct_id ,acct_len ,asset_total ,c_ad_id,c_area_1  ,c_area_2  ,c_area_3  ,	c_ctry_1  ,c_ctry_2  ,c_ctry_3  ,	c_dob ,c_email_1  ,	c_email_2  ,	c_ext_1  ,c_ext_2  ,c_ext_3  ,c_f_name  ,	c_gndr  ,c_l_name  ,c_local_1  ,c_local_2  ,	c_local_3  ,c_m_name  ,c_st_id ,c_tier ,cash_bal ,	status  );
                
                dbms_output.put_line('list_len: ' || acct_len); 
                dbms_output.put_line('status_' || status);
                FOR i IN 1 .. acct_len
                LOOP 
                dbms_output.put_line('acct_id '|| acct_id(i));
                dbms_output.put_line('cash_bal '|| cash_bal(i));
                dbms_output.put_line('asset_total '|| asset_total(i));
                END LOOP; 
                END;
             """)

            #LoadThread.printDBMSoutput(self, cur)
            print "cp"

            cur.close()

    def marketwatchTransaction(self, con):
        if con:
            cur = con.cursor()

            cur.callproc("dbms_output.enable")
            cur.execute("""
                DECLARE 
                acct_id NUMBER;
                cust_id NUMBER;
                ending_co_id NUMBER;
                industry_name VARCHAR2(50);
                starting_co_id 	NUMBER;
                
                marketWatchFrame1_tbl  MarketWatchFrame1_Pkg.MarketWatchFrame1_tab := MarketWatchFrame1_Pkg.MarketWatchFrame1_tab();
                 
                marketWatchFrame1rec MarketWatchFrame1_Pkg.MarketWatchFrame1_record ;
                        
                BEGIN
                
                select hs_ca_id into acct_id from ( select hs_ca_id, row_number() over (order by hs_ca_id) rno from holding_summary order by rno) where  rno = ( select round (dbms_random.value (1,25000)) from dual);
                select wl_c_id  into cust_id from ( select wl_c_id, row_number() over (order by wl_c_id) rno from watch_list order by rno) where  rno = ( select round (dbms_random.value (1,5000)) from dual);
                
                --DEBUGGING
                dbms_output.put_line('acct_id: ' || acct_id);
                dbms_output.put_line('cust_id: ' || cust_id);
                
                marketWatchFrame1_tbl := MarketWatchFrame1_Pkg.MarketWatchFrame1(acct_id, cust_id, ending_co_id, industry_name, starting_co_id);
                
                END;
             """)

            #LoadThread.printDBMSoutput(self, cur)
            print "mw"

            cur.close()

    def datamaintenanceTransaction(self, con):
        if con:
            cur = con.cursor()

            cur.callproc("dbms_output.enable")
            cur.execute("""
                DECLARE 
                in_acct_id NUMBER;
                in_c_id NUMBER;
                in_co_id NUMBER;
                day_of_month INTEGER;
                symbol VARCHAR2(50);
                table_name VARCHAR2(50);
                in_tx_id VARCHAR2(50);
                vol_incr INTEGER;
                status INTEGER;
                
                dataMaintenanceFrame1_out INTEGER;
                
                BEGIN 
                select ap_ca_id into in_acct_id from ( select ap_ca_id, row_number() over (order by ap_ca_id) rno from account_permission order by rno) where  rno = ( select round (dbms_random.value (1,25000)) from dual);
                select c_id into in_c_id from ( select c_id, row_number() over (order by c_id) rno from customer order by rno) where  rno = ( select round (dbms_random.value (1,5000)) from dual);
                select co_id into in_co_id from ( select co_id, row_number() over (order by co_id) rno from company order by rno) where  rno = ( select round (dbms_random.value (1,2500)) from dual);
                select round (dbms_random.value (1, 31)) into day_of_month from dual;
                select dm_s_symb into symbol from ( select dm_s_symb, row_number() over (order by dm_s_symb) rno from daily_market order by rno) where  rno = ( select round (dbms_random.value (1,3425)) from dual);
                with tablenames as (
                      select 'ACCOUNT_PERMISSION' as s from dual union all
                      select 'ADDRESS' as s from dual union all
                      select 'COMPANY' as s from dual union all
                      select 'CUSTOMER' as s from dual union all
                      select 'CUSTOMER_TAXRATE' as s from dual union all
                      select 'DAILY_MARKET' as s from dual union all
                      select 'FINANCIAL' as s from dual union all
                      select 'NEWS_ITEM' as s from dual union all
                      select 'SECURITY' as s from dual union all
                      select 'TAXRATE' as s from dual union all
                      select 'WATCH_ITEM' as s from dual
                     )
                select (select s
                        from (select s from tablenames order by dbms_random.value) s
                        where rownum = 1
                       )
                into table_name       
                from dual;
                select tx_id into in_tx_id from ( select tx_id, row_number() over (order by tx_id) rno from taxrate order by rno) where  rno = ( select round (dbms_random.value (0,320)) from dual);
                select dm_vol into vol_incr from ( select dm_vol, row_number() over (order by dm_vol) rno from daily_market order by rno) where  rno = ( select round (dbms_random.value (1,4469625)) from dual);
                
                -- DEBUGGING
                dbms_output.put_line('in_acct_id:   ' || in_acct_id);
                dbms_output.put_line('in_c_id:      ' || in_c_id);
                dbms_output.put_line('in_co_id:     ' || in_co_id);
                dbms_output.put_line('day_of_month: ' || day_of_month);
                dbms_output.put_line('symbol:       ' || symbol);
                dbms_output.put_line('table_name:   ' || table_name);
                dbms_output.put_line('in_tx_id:     ' || in_tx_id);
                dbms_output.put_line('vol_incr:     ' || vol_incr);
                
                dataMaintenanceFrame1_out := DataMaintenanceFrame1_Pkg.DataMaintenanceFrame1(in_acct_id, in_c_id, in_co_id, day_of_month, symbol, table_name, in_tx_id, vol_incr, status);
                
                dbms_output.put_line('status ' || dataMaintenanceFrame1_out);
                
                END;
             """)

            # LoadThread.printDBMSoutput(self, cur)
            print "dm"

            cur.close()

    def marketfeedTransaction(self, con):
        if con:
            cur = con.cursor()

            cur.callproc("dbms_output.enable")
            cur.execute("""
            DECLARE
            MaxSize INTEGER;
            status_submitted VARCHAR2(50);
            type_limit_buy	VARCHAR2(50);
            type_limit_sell	VARCHAR2(50);
            type_stop_loss	VARCHAR2(50);
            
            price_quote	TPCE.MARKETFEEDFRAME1_PKG.PR_ARRAY := TPCE.MARKETFEEDFRAME1_PKG.PR_ARRAY();
            symbol TPCE.MARKETFEEDFRAME1_PKG.SYM_ARRAY := TPCE.MARKETFEEDFRAME1_PKG.SYM_ARRAY();
            trade_qty TPCE.MARKETFEEDFRAME1_PKG.TR_ARRAY := TPCE.MARKETFEEDFRAME1_PKG.TR_ARRAY();
            
            lowerBound INTEGER;
            upperBound INTEGER;
            
            marketFeedFrame1_tbl  MarketFeedFrame1_Pkg.MarketFeedFrame1_tab := MarketFeedFrame1_Pkg.MarketFeedFrame1_tab();
            marketFeedFrame1rec MarketFeedFrame1_Pkg.MarketFeedFrame1_record ;
            
            BEGIN
            MaxSize := 2;
            status_submitted := 'CMPT';
            select tr_tt_id into type_limit_buy from ( select tr_tt_id, row_number() over (order by tr_tt_id) rno from trade_request order by rno) where  rno = ( select round (dbms_random.value (1,2)) from dual);
            select tr_tt_id into type_limit_sell from ( select tr_tt_id, row_number() over (order by tr_tt_id) rno from trade_request order by rno) where  rno = ( select round (dbms_random.value (1,2)) from dual);
            select tr_tt_id into type_stop_loss from ( select tr_tt_id, row_number() over (order by tr_tt_id) rno from trade_request order by rno) where  rno = ( select round (dbms_random.value (1,2)) from dual);
            
            lowerbound := 0;
            upperbound := 3;
            
            SELECT tr_bid_price BULK COLLECT INTO price_quote FROM ( SELECT tr_bid_price , row_number() over (order by tr_bid_price) rno FROM trade_request )
                                    WHERE  rno < upperBound 
                                    AND rno > lowerBound;
            SELECT tr_s_symb BULK COLLECT INTO symbol FROM ( SELECT tr_s_symb , row_number() over (order by tr_s_symb) rno FROM trade_request )
                                    WHERE  rno < upperBound 
                                    AND rno > lowerBound;
            SELECT lt_vol BULK COLLECT INTO trade_qty FROM ( SELECT lt_vol , row_number() over (order by lt_vol) rno FROM last_trade )
                                    WHERE  rno < upperBound 
                                    AND rno > lowerBound;
            
            -- DEBUGGING
            dbms_output.put_line('MaxSize:           ' || MaxSize);
            dbms_output.put_line('status_submitted:  ' || status_submitted);
            dbms_output.put_line('type_limit_buy:    ' || type_limit_buy);
            dbms_output.put_line('type_limit_sell:   ' || type_limit_sell);
            dbms_output.put_line('type_stop_loss:    ' || type_stop_loss);
            dbms_output.put_line('lowerBound:        ' || lowerBound);
            dbms_output.put_line('upperBound:        ' || upperBound);
            
            marketFeedFrame1_tbl := MarketFeedFrame1_Pkg.MarketFeedFrame1(MaxSize, price_quote, status_submitted, symbol, trade_qty, type_limit_buy, type_limit_sell, type_stop_loss);
            
            END;
             """)

            # LoadThread.printDBMSoutput(self, cur)
            print "mf"

            cur.close()

    def placeholder(self, con):
        pass

    # aka JeryTxnHarness
    def run(self):
        """
           The thread executes the same query in loop as long as:
           - it can be connected to the database
           - the test period is not over (time.time() < (StartTimeTest + self.LengthTest)
           - the flag self.runLoad == 0. This one is switched to 1 when:
               - the test period is over
               - the user click on the stop test button
        """
        global GlobalStop
        
        error_con = 0

        # ToDo: insert functions
        txns = [LoadThread.brokervolumeTransaction,
                LoadThread.customerpositionTransaction,
                LoadThread.marketfeedTransaction,
                LoadThread.marketwatchTransaction,
                LoadThread.placeholder,
                LoadThread.placeholder,
                LoadThread.placeholder,
                LoadThread.placeholder,
                LoadThread.placeholder,
                LoadThread.placeholder,
                LoadThread.datamaintenanceTransaction]
        columnNames = ["BROKERVOLUMECOUNT",
                       "CUSTOMERPOSITIONCOUNT",
                       "MARKETFEEDCOUNT",
                       "MARKETWATCHCOUNT",
                       "SECURITYDETAILCOUNT",
                       "TRADELOOKUPCOUNT",
                       "TRADEORDERCOUNT",
                       "TRADERESULTCOUNT",
                       "TRADESTATUSCOUNT",
                       "TRADEUPDATECOUNT",
                       "DATAMAINTENANCECOUNT"]
        weight = [1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1]

        totalWeight = np.sum(weight)
        probs = np.zeros(11)
        absCounts = np.zeros(11)
        
        StartTimeTest = time.time()
        """Test the connection. If valid, enter in a loop until the "stop load" button is hit
           or the test period is over
           app.ExecTime() call the statistics method
        """
        try:
            con = connectToOracle(self.OraIp, self.OraPort, self.OraConnect, "TPCE", "TPCE", threaded=True)
        except cx_Oracle.DatabaseError:
            error_con = 1
            return error_con

        if error_con != 1:
            # calculate probabilities based on weighting
            for i in range(0, len(weight)):
                probs[i] = weight[i] / totalWeight

            while self.runLoad == 0:
                cur = con.cursor()
                cur2 = con.cursor()
                cur3 = con.cursor()
                # choosing values from 0-11 based on probabilities
                choice = np.random.choice(11, 1, p=probs)[0]

                startTimeQuery = time.time()
                # execute selected transaction
                txns[choice](self, con)
                elapsedTimeQuery = int(time.time() - startTimeQuery)

                # increment selected transaction count
                absCounts[choice] += 1

                cur2.execute("""UPDATE tpcestat SET """ + columnNames[choice] + """ = ( SELECT """ \
                             + columnNames[choice] + """ FROM tpcestat WHERE STATID = 0 ) + 1 WHERE STATID = 0 """)
                con.commit()

                cur3.execute('insert into dwhstat values (seq.NEXTVAL, :id, sysdate)', {"id": elapsedTimeQuery})
                con.commit()
                cur.close()
                cur2.close()
                cur3.close()
                app.ExecTime()

                if time.time() > (StartTimeTest + self.LengthTest):
                    app.OnButtonStopLoadClick()
                    #self.GlobalStop = 1
                    GlobalStop = 1

            con.close()

    def stopThread(self):
        """Set the stop load flag to 1. Will be passed to the threads"""
        self.runLoad = 1

class WatcherThread(threading.Thread):
    def __init__(self, Entry1, Entry2, Entry3, Entry4, Entry5, EntryConUsers, EntryTestLength, existingThread, labelVariable):
        threading.Thread.__init__(self)
        self.EntryConUsers = EntryConUsers
        self.Entry3 = Entry3
        self.Entry4 = Entry4
        self.Entry5 = Entry5
        self.Entry1 = Entry1
        self.Entry2 = Entry2
        self.EntryTestLength = EntryTestLength
        self.existingThread = existingThread
        self.labelVariable = labelVariable
        self.runWatch = 0


    def run(self):
        error_con = 0

        try:
            con = connectToOracle(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry5.get()), "TPCE",
                                  "TPCE")
        except cx_Oracle.DatabaseError:
            error_con = 1
            print "err"

        if error_con != 1:
            cur = con.cursor()

            cur.execute("""UPDATE tpcestat 
                                                        SET BROKERVOLUMECOUNT = 0, CUSTOMERPOSITIONCOUNT = 0, MARKETFEEDCOUNT = 0, 
                                                        MARKETWATCHCOUNT = 0, SECURITYDETAILCOUNT = 0, TRADELOOKUPCOUNT = 0, TRADEORDERCOUNT = 0, 
                                                        TRADERESULTCOUNT = 0, TRADESTATUSCOUNT = 0, TRADEUPDATECOUNT = 0, DATAMAINTENANCECOUNT = 0
                                                        WHERE STATID = 0 """)
            con.commit()
            cur.close()

        i = 1
        while self.runWatch != 1:
            try:
                if self.EntryConUsers.get() and self.EntryConUsers.get().isdigit() and int(self.EntryConUsers.get()) >= 1:
                    try:
                        ConcUsers = int(self.EntryConUsers.get())
                        noActiveOraThreads = int(threading.activeCount()) -2
                        # print "------------------------------------------"
                        # print "ConcUsers: " + str(ConcUsers)
                        # print "noActiveOraThreads: " + str(noActiveOraThreads)

                        while len(self.existingThread)-1 < ConcUsers:
                            i += 1
                            self.my_thread = LoadThread(str(self.Entry3.get()), str(self.Entry4.get()), str(self.Entry5.get()),
                                                        str(self.Entry1.get()), str(self.Entry2.get()),
                                                        int(self.EntryTestLength.get()))
                            self.my_thread.name = i
                            self.my_thread.start()
                            self.existingThread.append(self.my_thread)
                            # time.sleep(1)
                            # self.after(500, self.labelVariable.set("Number of Thread: "+str(threading.activeCount())))


                        while len(self.existingThread)-1 > ConcUsers and self.existingThread:
                                i -= 1
                                lastThread = self.existingThread.pop()
                                if lastThread.isAlive():
                                    lastThread.stopThread()


                        #check if thrad is alive. If thread died -> restart a new one
                        for thread in self.existingThread:
                            #sys.stdout.write("X ")
                            #sys.stdout.flush()
                            if not thread.isAlive():
                                print str(thread) + "  died. Restarting..."
                                self.existingThread.remove(thread)
                        #sys.stdout.write("\n")

                        ActiveUsers = len(self.existingThread)-1
                        self.labelVariable.set("Number of active users: " + str(ActiveUsers))

                        # print self.existingThread
                        # print "\n"
                    except ValueError:
                        print "Value Error"
                else:
                    self.labelVariable.set("Please enter a valid number of users")
            except TclError:
                print "TclError"



            time.sleep(1)

    def stopThread(self):
        """Set the stop watcher flag to 1. Will be passed to the threads"""
        self.runWatch = 1

class InfoBulle(Tkinter.Toplevel):
    """
        Allow context help balloon on Entry field
    """
    def __init__(self, parent=None, texte='', temps=500):
        Tkinter.Toplevel.__init__(self, parent, bd=1)
        self.tps = temps
        self.parent = parent
        self.withdraw()
        self.overrideredirect(1)  ## No board for the window
        self.transient()     
        l = Tkinter.Label(self, text=texte, bg="light yellow", justify='left')
        l.update_idletasks()
        l.pack()
        l.update_idletasks()
        self.tipwidth = l.winfo_width()
        self.tipheight = l.winfo_height()
        self.parent.bind('<Enter>', self.delai)
        self.parent.bind('<Button-1>', self.efface)
        self.parent.bind('<Leave>', self.efface)
        
    ## Delay before the help balloon appears
    def delai(self, event):
        self.action = self.parent.after(self.tps, self.affiche)

    ## Print the balloon       
    def affiche(self):
        self.update_idletasks()
        posX = self.parent.winfo_rootx()
        posY = self.parent.winfo_rooty()+self.parent.winfo_height()
        if posX + self.tipwidth > self.winfo_screenwidth():
            posX = posX-self.winfo_width()-self.tipwidth
        if posY + self.tipheight > self.winfo_screenheight():
            posY = posY-self.winfo_height()-self.tipheight
        self.geometry('+%d+%d'%(posX,posY))
        self.deiconify()

    ## Delete the balloon
    def efface(self,event):
        self.withdraw()
        self.parent.after_cancel(self.action)

def ConfigSectionMap(section):
    """
				helper function for reading config files
	"""
    dict1 = {}
    options = Config.options(section)
    for option in options:
        try:
            dict1[option] = Config.get(section, option)
            if dict1[option] == -1:
                print "skip: %s" % option
        except:
            print("exception on %s!" % option)
            dict1[option] = None
    return dict1
################################################################		


###########################  MAIN  #############################
class simpleapp_tk(Tkinter.Tk):
    """
        Main window class
    """    
    def __init__(self,parent):
        Tkinter.Tk.__init__(self,parent)
        self.parent = parent
        self.initialize()

    def initialize(self):
        self.grid()

        """ Global variable. Check if some toplevel are open
        """

        global OpenToplevel
        OpenToplevel = 0

        #self.GlobalStop = 0
        global GlobalStop
        GlobalStop = 0

        """ Canvas:
            - HP logo (can1)
            - Horizontal line 1 (can2). Split login information and load setting
            - Horizontal line 2 (can3). Split load setting and action buttons
        """
        logohp = ConfigSectionMap("Settings")['logohp']
		
        can1 = Canvas(self, width = 130, height = 60, bg='white')
        self.logohp = PhotoImage(file=logohp)
        item = can1.create_image(66,32, image=self.logohp)
        can1.grid(column=1, row=27, rowspan = 5, padx=15, pady=15)

        can2 = Canvas(self, width = 552, height=20)
        can2.grid(column=0, row=18, columnspan=3, padx=10, pady=10)
        can2.create_line (10,10,540,10,width=3,fill='white')

        can3 = Canvas(self, width = 552, height=20)
        can3.grid(column=0, row=23, columnspan=3, padx=10, pady=10)
        can3.create_line (10,10,540,10,width=3,fill='white')

        """ Label:
             Text printed in the main window
        """
        self.labelVariable1 = Tkinter.StringVar()
        label1 = Tkinter.Label(self, textvariable=self.labelVariable1, fg="white", bg="gray60", font=(20))
        label1.grid(column=0, row=0, columnspan=3, sticky='EW')

        self.labelVariable1.set(u"JERYe - TPC-E Benchmark")


        self.Label1 = Tkinter.Label(self, text='IP of Oracle DB')
        self.Label1.grid(column=0, row=3, sticky=W)
        self.Label2 = Tkinter.Label(self, text='Port of Oracle DB')
        self.Label2.grid(column=1, row=3, sticky=W)

        self.Label3 = Tkinter.Label(self, text='Test schema owner')
        self.Label3.grid(column=0, row=5, sticky=W)
        self.Label4 = Tkinter.Label(self, text='Test schema password')
        self.Label4.grid(column=1, row=5, sticky=W)

        self.Label5 = Tkinter.Label(self, text='Connect string')
        self.Label5.grid(column=2, row=5, sticky=W)
        self.Label6 = Tkinter.Label(self, text='Select the number of virtual users')
        self.Label6.grid(column=0, row=19, columnspan=3)

        if hasattr(self, 'LabelExecTime'):
            self.LabelExecTime.destroy()
        self.LabelExecTimeVariable = Tkinter.StringVar()
        self.LabelExecTimeVariable.set("Avg. completion time: 0")
        self.LabelExecTime = Tkinter.Label(self, textvariable=self.LabelExecTimeVariable, fg="red")
        self.LabelExecTime.grid (column=1, row=24)

        if hasattr(self, 'LabelNbQueries'):
            self.LabelNbQueries.destroy()
        self.LabelNbQueriesVariable = Tkinter.StringVar()
        self.LabelNbQueriesVariable.set("Nb Queries in last MM: 0")
        self.LabelNbQueries = Tkinter.Label(self, textvariable=self.LabelNbQueriesVariable, fg="red")
        self.LabelNbQueries.grid (column=1, row=25)

        self.LabelTestLengthVariable = Tkinter.StringVar()
        self.LabelTestLengthVariable.set("How long will be the test:")
        self.LabelTestLength = Tkinter.Label(self, textvariable=self.LabelTestLengthVariable)
        self.LabelTestLength.grid (column=1, row=22, sticky="W")

        self.labelVariable2 = Tkinter.StringVar()
        label2 = Tkinter.Label(self, textvariable=self.labelVariable2,
                              anchor="w", fg="white", bg="blue")
        label2.grid(column=0, row=7, columnspan=2, sticky='EW')
        self.labelVariable2.set(u"Hello !")

        self.LabelSystemPwd = Tkinter.Label(self, text="SYSTEM user password: ")
        self.LabelSystemPwd.grid (column=0, row=10)

        

        """ Entry:
			- IP of Oracle DB (Entry1)
            - Port of Oracle DB (Entry2)
            - test schema user name (Entry1)
            - test schema user password (Entry2)
            - db connect string (Entry3)
            - number of concurrent users or parallel job threads (EntryConUsers)
            - Length of the test (only if unlimited loop is not selected) (EntryTestLength).
                Only allow numeric input.    
        """
        self.entryIpVariable = Tkinter.StringVar()
        self.Entry1 = Tkinter.Entry(self, textvariable=self.entryIpVariable)
        self.Entry1.grid(column=0, row=4, sticky='EW')
        self.Entry1.bind('<Return>', self.OnPressEnter)
        ipVariable = ConfigSectionMap("Prefilled")['ip']
        self.entryIpVariable.set(ipVariable)

        self.entryPortVariable = Tkinter.StringVar()
        self.Entry2 = Tkinter.Entry(self, textvariable=self.entryPortVariable)
        self.Entry2.grid(column=1, row=4, sticky='EW')
        self.Entry2.bind('<Return>', self.OnPressEnter)
        portVariable = ConfigSectionMap("Prefilled")['port']
        self.entryPortVariable.set(portVariable)


        self.entryUserVariable = Tkinter.StringVar()
        self.Entry3 = Tkinter.Entry(self, textvariable=self.entryUserVariable)
        self.Entry3.grid(column=0, row=6, sticky='EW')
        self.Entry3.bind('<Return>', self.OnPressEnter)
        userVariable = ConfigSectionMap("Prefilled")['user']

        self.entryUserVariable.set(userVariable)

        self.entryPwdVariable = Tkinter.StringVar()
        self.Entry4 = Tkinter.Entry(self, textvariable=self.entryPwdVariable, show="*")
        self.Entry4.grid(column=1, row=6, sticky='EW')
        self.Entry4.bind('<Return>', self.OnPressEnter)
        pwdVariable = ConfigSectionMap("Prefilled")['pwd']

        self.entryPwdVariable.set(pwdVariable)

        self.entryConnectStringVariable = Tkinter.StringVar()
        self.Entry5 = Tkinter.Entry(self, textvariable=self.entryConnectStringVariable)
        self.Entry5.grid(column=2, row=6, sticky='EW')
        self.Entry5.bind('<Return>', self.OnPressEnter)
        entryConnectStringVariable = ConfigSectionMap("Prefilled")['entryconnectstring']

        self.entryConnectStringVariable.set(entryConnectStringVariable)

        self.entryConUsersVariable = Tkinter.IntVar()
        self.EntryConUsers = Tkinter.Entry(self, textvariable=self.entryConUsersVariable)
        self.EntryConUsers.grid(column=1, row=21, sticky='EW')
        self.EntryConUsers.bind('<Return>', self.OnPressEnter)
        self.entryConUsersVariable.set(4)

        """Method ValidateTestLength check that only numbers are entered into that Entry field."""
        self.ValidateTestLength = (self.register(self.OnValidate), '%d', '%i', '%P', '%s', '%S', '%v', '%V', '%W')
        self.entryTestLengthVariable = Tkinter.IntVar()
        self.EntryTestLength = Tkinter.Entry(self, textvariable=self.entryTestLengthVariable, validate='key', \
                                             validatecommand=self.ValidateTestLength, state='disabled')
        self.EntryTestLength.grid(column=2, row=22, sticky='E')
        self.entryTestLengthVariable.set(0)

        self.EntryPwdSysVariable = Tkinter.StringVar()
        self.EntryPwdSys = Tkinter.Entry(self, textvariable=self.EntryPwdSysVariable, \
                                         show="*", state='disabled')
        self.EntryPwdSys.grid(column=1, row=10, sticky='EW')
        entryPwdSysVariable = ConfigSectionMap("Prefilled")['pwdsys']
        self.EntryPwdSysVariable.set(entryPwdSysVariable)


        """ Button section:
           - buttonLess: decrease the number of // workers
           - buttonMore: increase the number of // workers
           - buttonTest: Check the connection to the database
           - buttonStartLoad: Start the threads
           - buttonStopLoad: kill the threads
           - buttonQuit: close the apps
           - buttonExtendedStat: Open a second window with advanced statistics.
        """

        buttonLess = Tkinter.Button(self, text=u"-", command=self.OnButtonLessClick, width=5)
        buttonLess.grid(column=0, row=21, sticky=E)

        buttonMore = Tkinter.Button(self, text=u"+", command=self.OnButtonMoreClick, width=5)
        buttonMore.grid(column=2, row=21, sticky=W)




        buttonTest = Tkinter.Button(self, text=u"Check User Connection", command=self.OnButtonClick)
        buttonTest.grid(column=2, row=7, columnspan=2, sticky=W+E+N+S)

        self.buttonStartLoad = Tkinter.Button(self, text=u"Start the load", command=self.OnButtonStartLoadClick \
                                              , width=14)
        self.buttonStartLoad.grid(column=0, row=24, sticky=S)

        buttonStopLoad = Tkinter.Button(self, text=u"Stop the load", command=self.OnButtonStopLoadClick \
                                        , width=14)
        buttonStopLoad.grid(column=0, row=25, sticky=S)

        buttonQuit = Tkinter.Button(self, text=u"Quit Application", command=self.QuitApps, width=14)
        buttonQuit.grid(column=1, row=26, sticky=S)

        self.buttonExtendedStat = Tkinter.Button(self, text=u"TPC-E Statistics", command=self.ExtendedStatistics \
                                                 , width=14)

        self.buttonExtendedStat.grid(column=0, row=26, sticky=S)

        self.ButtonTestSystemConn = Tkinter.Button(self, text=u"Check System Connection", \
                                                   command=lambda:
                                                   self.test_SID("System"))


        self.ButtonTestSystemConn.grid(column=2, row=10, columnspan=3, sticky=W+E+N+S)
        self.ButtonTestSystemConn.config(state=DISABLED)

        self.ButtonCreateSchema = Tkinter.Button(self, text=u"Create Test Schema", \
                                                 command=self.CreateSchema)
        self.ButtonCreateSchema.grid(column=2, row=11, columnspan=2, sticky=W+E+N+S)
        self.ButtonCreateSchema.config(state=DISABLED)

        buttonGraph = Tkinter.Button(self, text=u"Graph", command=self.StartGraph, width=14)
        buttonGraph.grid(column=2, row=24, columnspan=2)

        buttonAPropos = Tkinter.Button(self, text=u"A propos...", command=self.APropos, width=14)
        buttonAPropos.grid(column=2, row=26, columnspan=2)

        buttonNbThread = Tkinter.Button(self, text=u"Nb. of threads", command=self.NbThread, width=14)
        buttonNbThread.grid(column=2, row=25, columnspan=2)


        """ Balloon section
            enable help on Entry field
        """

        balloonHelpSID = InfoBulle(parent=self.Entry5, texte="Enter the SID")
        balloonUserScott = InfoBulle(parent=self.Entry3, texte="Enter the username owning the test schema")
        balloonUserPwd = InfoBulle(parent=self.Entry4, texte="Enter the password of the user owning the test schema")
        balloonSystemPwd = InfoBulle(parent=self.EntryPwdSys, texte="Enter the password of the SYSTEM (sysdba) user")
        balloonTestLength = InfoBulle(parent=self.EntryTestLength, texte="How long will run the test in minutes")
        balloonIP = InfoBulle(parent=self.Entry1, texte="Enter the IP address of the database")
        balloonPort = InfoBulle(parent=self.Entry2, texte="Enter the port of the database")


        """ Checkbutton define whether the test run on a limited period of time or if it will run
            until the stop button is hitted
        """
        self.SysdbaEnabled = IntVar()
        self.CheckSysdbaEnabled = Tkinter.Checkbutton(self, text="Enable SYSDBA mode?", variable=self.SysdbaEnabled, \
                                                      command=self.SysdbaEnabledMeth)
        self.CheckSysdbaEnabled.grid(column=0, row=9, sticky=W)
        self.CheckSysdbaEnabled.deselect()


        self.TestLength = IntVar()
        self.TestLengthStatus = Tkinter.Checkbutton(self, text="Define Length of the test?", variable=self.TestLength, \
                                                    command=self.TestLengthMeth)
        self.TestLengthStatus.grid(column=0, row=22, sticky=W)
        self.TestLengthStatus.deselect()

        self.CheckAWRSnapshot = IntVar()
        self.CheckAWRSnapshotStatus = Tkinter.Checkbutton(self, text="Enable AWReport Snapshot", \
                                                          variable=self.CheckAWRSnapshot)
        self.CheckAWRSnapshotStatus.grid(column=0, row=11, sticky=W)
        self.CheckAWRSnapshotStatus.deselect()
        self.CheckAWRSnapshotStatus.configure(state='disabled')


        #self.grid_columnconfigure(0, weight=1)
        self.resizable(False, False)
        self.update()
        self.geometry(self.geometry())
        self.Entry1.focus_set()
        self.Entry1.selection_range(0, Tkinter.END)


    def NbThread(self):
        nbthread = int(threading.activeCount())
        self.labelVariable2.set(" {0} active connections.".format(nbthread))
        #self.labelVariable.set(" {0} Valeur de OpenToplevel".format(OpenToplevel))
        

    def QuitApps (self):
        """ Quit the main window procedure
            Before quitting, check if some toplevel windows still active.
                - If yes, ask to close them and do not leave the apps
                - if no, check if some threads still active:
                    - if yes: close them
                    - if no destroy the main window
        """

        if OpenToplevel == 0:
            nbthread = int(threading.activeCount())
            if nbthread > 2:
                self.OnButtonStopLoadClick()
            self.ProperStopApps()
        else:
            tkMessageBox.showinfo("Error", "Close the other windows first !")
    
        
    def ProperStopApps(self):
        """ Wait for all threads to be shutdown before closing the apps.
        """
        nbthread = int(threading.activeCount())
        if nbthread > 2:
            self.labelVariable2.set("Loader shutdown ongoing. Still {0} active connections.".format(nbthread))
            self.after(1000, self.ProperStopApps)
        else:
            self.labelVariable2.set("Shutdown now!")
            self.after(500, self.destroy)
    
    
    def OnValidate(self, action, index, value_if_allowed, prior_value, text, validation_type, trigger_type, widget_name):
        """
            Check the value typed into an Entry field are numeric only
        """    
        if text in '0123456789':
            return True
        else:
            return False


    def SnapshotDB(self):
        """
            Create a snapshot of the db statistics in order to generate an AWR report specific to the current run
            1. Test the connection
            2. Trig the db snapshot
            3. show the snap_id into the verbose Label
        """
        error_con = 0
        if self.CheckAWRSnapshot.get() == 1:
            try:
                con = connectToOracle(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry5.get()), "system", str(self.EntryPwdSys.get()))
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 1017:
                    self.labelVariable2.set(self.entryConnectStringVariable.get() + ": System invalid password")
                    #statWindow.VocableVariable.set(self.entryConnectStringVariable.get()+": Invalid username or password")
                    #messageretour = str(self.entryConnectStringVariable.get()+": Invalid username or password")
                    error_con = 1
                elif error.code == 12154:
                    self.labelVariable2.set(self.entryConnectStringVariable.get() + ": TNS couldn't resolve the SID")
                    error_con = 1
                elif error.code == 12543:
                    self.labelVariable2.set(self.entryConnectStringVariable.get() + ": Destination host not available")
                    error_con = 1
                else:
                    self.labelVariable2.set(self.entryConnectStringVariable.get() + ": System unable to connect")
                    error_con = 1
            
            if error_con != 1:
                cur = con.cursor()
                res = cur.callfunc('dbms_workload_repository.create_snapshot', cx_Oracle.NUMBER, ())
                cur.close()
                cur2 = con.cursor()
                cur2.execute('select max(snap_id) from dba_hist_snapshot')
                for result in cur2:
                    resultVar = str(result[0])
                    self.labelVariable2.set(" Snapshot took with ID #{0}.".format(resultVar))
                cur2.close()
                con.close()
                
            
    def SysdbaEnabledMeth(self):
        """
            If the limited execution time checkbox (self.TestLengthStatus) is checked, the entry field for the Length test
            is disabled.
        """    
        if self.SysdbaEnabled.get() == 0:
            self.buttonExtendedStat.config(state=DISABLED)
            self.ButtonTestSystemConn.config(state=DISABLED)
            self.EntryPwdSys.configure(state='disabled')
            self.CheckAWRSnapshotStatus.configure(state='disabled')
            self.ButtonCreateSchema.config(state=DISABLED)
        else:
            self.buttonExtendedStat.config(state=NORMAL)
            self.ButtonTestSystemConn.config(state=NORMAL)
            self.EntryPwdSys.configure(state='normal')
            self.CheckAWRSnapshotStatus.configure(state='normal')
            self.ButtonCreateSchema.config(state=NORMAL)

    
    def TestLengthMeth(self):
        """
            If the limited execution time checkbox (self.TestLengthStatus) is checked, the entry field for the Length test
            is disabled.
        """    
        if self.TestLength.get() == 0:
            self.entryTestLengthVariable.set(0)
            self.EntryTestLength.configure(state='disabled')
        else:
            self.EntryTestLength.configure(state='normal')
            
        
    def OnButtonLessClick(self):
        """
            Reduce by one the number of concurrent users.
        """
        if self.EntryConUsers.get():
            ConcUsers = int(self.EntryConUsers.get())
            ConcUsers -= 1
            if(ConcUsers >= 1):
                self.entryConUsersVariable.set(ConcUsers)


    def OnButtonMoreClick(self):
        """
            Increase by one the number of concurrent users.
        """
        if self.EntryConUsers.get():
            ConcUsers = int(self.EntryConUsers.get())
            ConcUsers += 1
            self.entryConUsersVariable.set(ConcUsers)


    def OnButtonClick(self):
        """
            Call the Test connection method.
        """    
        self.test_SID("User")
        self.Entry1.focus_set()
        self.Entry1.selection_range(0, Tkinter.END)

    def OnButtonStopLoadClick(self):
        """
            Stop the current workload by stopping the existing threads.
            Print also a message in the vocable label
            Enable the start load button
        """
        #global GlobalStop

        if hasattr(self, 'existingThread'):
            for t in self.existingThread:
                if t.isAlive():
                    t.stopThread()


        #if self.GlobalStop == 0:
        if GlobalStop == 0:
            con = connectToOracle(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry5.get()), str(self.Entry3.get()),
                                  str(self.Entry4.get()))
            cur = con.cursor()
            cur.execute('select count(*) from dwhstat')
            for result in cur:
                resultVar = str(result[0])
                self.labelVariable2.set(u"Workload will end shortly! {0} trans. completed in this run.".format(resultVar))
            cur.close()
            con.close()
            self.buttonStartLoad.config(state=NORMAL)
            self.after(4000, self.SnapshotDB)
        
        
    def OnButtonStartLoadClick(self):
        """ Start the Load threads
            - Start button is disabled
            - check if the db is available
            - Print a temporary message before we get execution statistics
            - Call the statistics table creation
            - create a first thread with the login information and the length of the test as parameter
            - start the thread
            - Enter in a loop in order to start as much thread as needed (+2 as we do have existing threads
                which are the main process.
        """
        global GlobalStop
        GlobalStop = 0
        #self.GlobalStop = 0
        
        self.buttonStartLoad.config(state=DISABLED)
        self.LabelExecTimeVariable.set('Ramping up')
        self.existingThread = []
        #runStatus=  0
        error_con = 0
        CheckSchemaVar = 0

        ### Snapshot the db if the option is selected.
        self.SnapshotDB()
        
        #### Check whether the the test schema is available or not. Leave the method if not
        CheckSchemaVar = self.CheckSchema()
        if CheckSchemaVar <> 0:
            self.buttonStartLoad.config(state=NORMAL)
            return
        
        self.InitTableStat()

        self.watcherThread = WatcherThread(self.Entry1, self.Entry2, self.Entry3, self.Entry4, self.Entry5, self.EntryConUsers, self.EntryTestLength, self.existingThread, self.labelVariable2)
        self.watcherThread.name = 1
        self.watcherThread.start()
        self.existingThread.append(self.watcherThread)

        self.my_thread = LoadThread(str(self.Entry3.get()), str(self.Entry4.get()), str(self.Entry5.get()),
                                    str(self.Entry1.get()), str(self.Entry2.get()),
                                    int(self.EntryTestLength.get()))
        #self.labelVariable.set('self.my_thread value = {0}'.format(str(runStatus)))
        self.my_thread.name = 1
        self.my_thread.start()
        self.existingThread.append(self.my_thread)

    def CheckSchema(self):
        """
            This method checks if the test schema is existing and the database available before starting the load threads.
            Return 1 if the db is not reachable.
            Return 2 if the test schema is not existing.
        """
        error_con = 0

        try:
            con = connectToOracle(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry5.get()), str(self.Entry3.get()), str(self.Entry4.get()))
        except cx_Oracle.DatabaseError:
            self.labelVariable2.set(self.entryConnectStringVariable.get() + ": Unable to connect with user {0}!" \
                                    .format(str(self.Entry3.get())))
            return 1

        if error_con != 1:
            cur = con.cursor()
            try:
                cur.execute('select count(*) from ADDRESS')
            except cx_Oracle.DatabaseError:
                self.labelVariable2.set("Cannot access the test schema. Please create it again")
                return 2

            cur2 = con.cursor()
            try:
                cur.execute('select count(*) from dwhstat')
            except cx_Oracle.DatabaseError:
                self.labelVariable2.set("Cannot access the test schema. Please create it again")
                return 3

            cur.close()
            cur2.close()
            con.close()
            return 0


    def OnPressEnter(self, event):
        """
            Event associated with the Press Enter keybord action. No impact
        """    
        self.labelVariable2.set(self.entryUserVariable.get() + " You pressed Enter!")
        self.Entry1.focus_set()
        self.Entry1.selection_range(0, Tkinter.END)

    def InitTableStat(self):
        """ Method initializing the statistics table into the test  schema.
            - test first the connection.
            - when the connection is valid, create the table.
            - if the table exist, just truncate the table
        """    
        error_con = 0
        try:
            con = connectToOracle(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry5.get()),
                                  str(self.Entry3.get()),
                                  str(self.Entry4.get()))
        except cx_Oracle.DatabaseError:
            self.labelVariable2.set(self.entryConnectStringVariable.get() + ": Unable to connect!")
            error_con = 1

        if error_con != 1:
            cur = con.cursor()
            try:
                cur.execute('truncate table dwhstat')
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 942:
                    self.labelVariable2.set(self.entryConnectStringVariable.get() + ": Test schema does not exist. Create it first!")
            cur.close()
            con.close()

            
    def test_SID(self, origin):
        """ Test if the connection parameters are valid.
            - If the connection is valid print the db_name into the vocable label.
                Otherwise print an error message.
        """
        error_con = 0

        if origin == "User":
            try:
                con = connectToOracle(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry5.get()),
                                          str(self.Entry3.get()),
                                          str(self.Entry4.get()))
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 1017:
                    self.labelVariable2.set(self.entryConnectStringVariable.get() +  \
                                            ": {0} Invalid username or password".format(str(self.Entry1.get())))
                    error_con = 1
                elif error.code == 12154:
                    self.labelVariable2.set(self.entryConnectStringVariable.get() + ": TNS couldn't resolve the SID")
                    error_con = 1
                elif error.code == 12543:
                    self.labelVariable2.set(self.entryConnectStringVariable.get() + ": Destination host not available")
                    error_con = 1
                else:
                    self.labelVariable2.set(self.entryConnectStringVariable.get() + ": Unable to connect")
                    error_con = 1

            if error_con != 1:
                cur = con.cursor()
                cur.execute('select * from global_name')
                for result in cur:
                    resultVar = str(result[0])
                    self.labelVariable2.set("{0}: {1}, Connection succesfull".format(resultVar, str(self.Entry3.get())))
                cur.close()
                con.close()
        elif origin == "System":
            try:
                con = connectToOracle(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry5.get()),
                                      "system",
                                      str(self.EntryPwdSys.get()))
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 1017:
                    self.labelVariable2.set(self.entryConnectStringVariable.get() + ": System invalid password")
                    #statWindow.VocableVariable.set(self.entryConnectStringVariable.get()+": Invalid username or password")
                    #messageretour = str(self.entryConnectStringVariable.get()+": Invalid username or password")
                    error_con = 1
                elif error.code == 12154:
                    self.labelVariable2.set(self.entryConnectStringVariable.get() + ": TNS couldn't resolve the SID")
                    error_con = 1
                elif error.code == 12543:
                    self.labelVariable2.set(self.entryConnectStringVariable.get() + ": Destination host not available")
                    error_con = 1
                else:
                    self.labelVariable2.set(self.entryConnectStringVariable.get() + ": System unable to connect")
                    error_con = 1

            if error_con != 1:
                cur = con.cursor()
                cur.execute('select * from global_name')
                for result in cur:
                    resultVar = str(result[0])
                    self.labelVariable2.set("{0}: System, connection succesfull".format(resultVar))
                cur.close()
                con.close()



    def ExecTime(self):
        """ Method calculating the average execution time of the test query
            - test the connection first.
            - count the number of record into the statistics table.
            - When more than 10 are in, start to print an average execution time.
                Otherwise just print "Ramping up"
        """
        error_con = 0

        try:
            if self.Entry1 and self.Entry2 and self.Entry5 and self.Entry3 and self.Entry4:
                con = connectToOracle(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry5.get()),
                                  str(self.Entry3.get()),
                                  str(self.Entry4.get()))
        except cx_Oracle.DatabaseError:
            self.labelVariable2.set(self.entryConnectStringVariable.get() + ": Unable to connect!")
            error_con = 1

        if error_con != 1:
            curRampUp = con.cursor()
            curRampUp.execute('select count(*) from dwhstat')
            for result in curRampUp:
                curExecTime = con.cursor()
                if int(result[0]) > 10:
                    curExecTime.execute('select (sum(elapsed))/10 from (select seq, elapsed from dwhstat) where seq>(select max(seq) - 10 from dwhstat)')
                    for result in curExecTime:
                        avgExecTime = str(int(result[0]))
                        self.LabelExecTimeVariable.set('Avg completion time: {0} S'.format(avgExecTime))
                else:
                    self.LabelExecTimeVariable.set('Ramping up')
                curExecTime.close()
            curRampUp.close()

            curExec = con.cursor()
            curExec.execute('select count(*) from dwhstat where (sysdate - insdate)*60*60*24 <61')
            for result in curExec:
                NbExecTime = str(int(result[0]))
                self.LabelNbQueriesVariable.set('Nb queries in last MM: {0}'.format(NbExecTime))
            curExec.close()
            con.close()


    def ExtendedStatistics(self):
        """ Advanced Statistics call method """
        statWindow = ExtendedStatisticsWindow(str(self.Entry5.get()), str(self.EntryPwdSys.get()), str(self.Entry1.get()), str(self.Entry2.get()))

    def CreateSchema(self):
        """ test schema creation method """
        CreateSchematWindow = CreateTestSchemaWindow(str(self.Entry5.get()), str(self.Entry3.get()) , str(self.EntryPwdSys.get()), str(self.Entry1.get()), str(self.Entry2.get()))

    def APropos(self):
        """ Information about the application """
        AProposWindow = CreateAProposWindow()

    def StartGraph(self):
        GraphikWindow = GraphWindow(str(self.Entry3.get()), str(self.Entry4.get()), str(self.Entry5.get()), str(self.Entry1.get()), str(self.Entry2.get()))
        
        
        
if __name__ == "__main__":
    Config = ConfigParser.ConfigParser()
    Config.read("./config.ini")
    app = simpleapp_tk(None)
    app.title('JERYe Benchmark')
    app.mainloop()
################################################################