#!/usr/local/bin/python3
#-*- coding: iso-8859-1 -*-

########################################
## Author: Yann Allandit
## Contact: dwh2@hp.com
## Creation Date: 10th of March 2014
########################################

import Tkinter
from Tkinter import *
import cx_Oracle
import threading
import time
import tkMessageBox
import ConfigParser

###########################  GUI  ##############################
class CreateTestSchemaWindow(Tkinter.Toplevel):
    def __init__(CrSchemaWindow, SID, passwd, ip, port):
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
        CrSchemaWindow.wm_title(" Test schema creation ")
        CrSchemaWindow.protocol("WM_DELETE_WINDOW", CrSchemaWindow.handler)
        CrSchemaWindow.SID = SID
        CrSchemaWindow.passwd = passwd
        CrSchemaWindow.ip = ip
        CrSchemaWindow.port = port

        CrSchemaWindow.LabelTableRatio = Tkinter.Label(CrSchemaWindow, text="Select the scaling ratio ")
        CrSchemaWindow.LabelTableRatio.grid(column=0, row=0)

        CrSchemaWindow.RatioVar = IntVar()
        Ratio1 = Tkinter.Radiobutton(CrSchemaWindow, text='1: Disk space needed 11MB', variable=CrSchemaWindow.RatioVar, value=1)
        Ratio2 = Tkinter.Radiobutton(CrSchemaWindow, text='2: Disk space needed 22MB', variable=CrSchemaWindow.RatioVar, value=2)
        Ratio3 = Tkinter.Radiobutton(CrSchemaWindow, text='3: Disk space needed 43MB', variable=CrSchemaWindow.RatioVar, value=3)
        Ratio4 = Tkinter.Radiobutton(CrSchemaWindow, text='4: Disk space needed 88MB', variable=CrSchemaWindow.RatioVar, value=4)
        Ratio5 = Tkinter.Radiobutton(CrSchemaWindow, text='5: Disk space needed 176MB', variable=CrSchemaWindow.RatioVar, value=5)
        Ratio6 = Tkinter.Radiobutton(CrSchemaWindow, text='6: Disk space needed 344MB', variable=CrSchemaWindow.RatioVar, value=6)
        Ratio7 = Tkinter.Radiobutton(CrSchemaWindow, text='7: Disk space needed 680MB', variable=CrSchemaWindow.RatioVar, value=7)
        Ratio8 = Tkinter.Radiobutton(CrSchemaWindow, text='8: Disk space needed 1.4GB', variable=CrSchemaWindow.RatioVar, value=8)
        Ratio9 = Tkinter.Radiobutton(CrSchemaWindow, text='9: Disk space needed 2.7GB', variable=CrSchemaWindow.RatioVar, value=9)
        Ratio10 = Tkinter.Radiobutton(CrSchemaWindow, text='10: Disk space needed 5.5GB', variable=CrSchemaWindow.RatioVar, value=10)
        Ratio1.grid(row=1, column=0, sticky='W')
        Ratio2.grid(row=2, column=0, sticky='W')
        Ratio3.grid(row=3, column=0, sticky='W')
        Ratio4.grid(row=4, column=0, sticky='W')
        Ratio5.grid(row=5, column=0, sticky='W')
        Ratio6.grid(row=6, column=0, sticky='W')
        Ratio7.grid(row=7, column=0, sticky='W')
        Ratio8.grid(row=8, column=0, sticky='W')
        Ratio9.grid(row=9, column=0, sticky='W')
        Ratio10.grid(row=10, column=0, sticky='W')
        Ratio1.select()

        
        buttonQuit = Tkinter.Button(CrSchemaWindow,text=u"Close window", command=CrSchemaWindow.CloseCrSchemaWindow, width=29)
        buttonQuit.grid (column=0, row=14, sticky=S)

        buttonCreate = Tkinter.Button(CrSchemaWindow,text=u"Create the data now", command=lambda:
                                      CrSchemaWindow.CreateSchema(CrSchemaWindow.SID,CrSchemaWindow.passwd,int(CrSchemaWindow.RatioVar.get())) \
                                      , width=29)
        buttonCreate.grid (column=0, row=12, sticky=S)

        buttonDrop = Tkinter.Button(CrSchemaWindow,text=u"Drop the test data now", command=lambda:
                                      CrSchemaWindow.DropSchema(CrSchemaWindow.SID,CrSchemaWindow.passwd), width=29)
        buttonDrop.grid (column=0, row=13, sticky=S)

        CrSchemaWindow.VocableVariable = Tkinter.StringVar()
        Vocable = Tkinter.Label(CrSchemaWindow,textvariable=CrSchemaWindow.VocableVariable, anchor="w", fg="white", bg="blue")
        Vocable.grid(column=0, row=11, columnspan=2, sticky='EW')
        CrSchemaWindow.VocableVariable.set(u"Hello !")
        
        CrSchemaWindow.grid_columnconfigure(0,weight=1)
        CrSchemaWindow.resizable(True,False)
        CrSchemaWindow.update()
        CrSchemaWindow.geometry(CrSchemaWindow.geometry())


    def CreateSchema(CrSchemaWindow, SID, passwd, ip, port, RatioVar):
        """ Test if the connection parameters are valid.
            - If the connection is valid print the db_name into the vocable label.
                Otherwise print an error message.
        """        
        #dsn_tns = cx_Oracle.makedsn('15.136.28.39', 1526, SID)
        #dsn_tns = ('scott/tiger@' + str(self.Entry3.get()))
        #version_DB['text'] = str(self.Entry3.get())
        
        error_con = 0
        CrSchemaWindow.LoopRatioVar = RatioVar + 14
        CrSchemaWindow.i = 1

        try:
            dsn = cx_Oracle.makedsn(host=str(ip), port=str(port), service_name=str(SID))
            con = cx_Oracle.connect("system", str(passwd), dsn)
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
            try:
                cur.execute('create table scott.emp2 as select * from scott.emp')
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 3113:
                    cur.execute('drop table scott.emp2')
                    cur.execute('create table scott.emp2 as select * from scott.emp')
                elif error.code == 955:
                    cur.execute('drop table scott.emp2')
                    cur.execute('create table scott.emp2 as select * from scott.emp')
                else:
                    CrSchemaWindow.VocableVariable.set(str(SID) + ": Failed to create schema")
                    cur.close()
                    return
            try:
                cur.execute('create table scott.dwhstat (seq int not null primary key, elapsed int, insdate date)')
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 955:
                    cur.execute('truncate table scott.dwhstat')

            cur.execute('CREATE SEQUENCE scott.seq START WITH 1 INCREMENT BY 1 NOCACHE')
            
            cur.close()
            CrSchemaWindow.CreateSchemaProgress(SID, passwd, ip, port)
            con.close()
            

    def DropSchema(CrSchemaWindow, SID, passwd, ip, port):
        """ Test if the connection parameters are valid.
            - If the connection is valid print the db_name into the vocable label.
                Otherwise print an error message.
        """        
        #dsn_tns = cx_Oracle.makedsn('15.136.28.39', 1526, SID)
        #dsn_tns = ('scott/tiger@' + str(self.Entry3.get()))
        #version_DB['text'] = str(self.Entry3.get())
        
        error_con = 0

        try:
            dsn = cx_Oracle.makedsn(host=str(ip), port=str(port), service_name=str(SID))
            con = cx_Oracle.connect("system", str(passwd), dsn)
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
            try:
                cur.execute('drop table scott.emp2')
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 942:
                    CrSchemaWindow.VocableVariable.set('Test schema does not exist')
                    error_con = 2
                else:
                    CrSchemaWindow.VocableVariable.set(str(SID) + ": Failed to drop the test schema")
                    error_con = 2
                    
            try:
                cur.execute('drop table scott.dwhstat')
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 942:
                    CrSchemaWindow.VocableVariable.set('Test schema does not exist')
                    error_con = 2
                else:
                    CrSchemaWindow.VocableVariable.set(str(SID) + ": Failed to drop the test schema")
                    error_con = 2
            
            try:
                cur.execute('drop SEQUENCE scott.seq')
            except cx_Oracle.DatabaseError:
                error_con = 3
                
            cur.close()
            con.close()
            if error_con == 0:
                CrSchemaWindow.VocableVariable.set(str(SID) + ": Test schema dropped!")
            

    def CreateSchemaProgress(CrSchemaWindow, SID, passwd, ip, port):
        """ Used as progress bar.
            for each and every recursive insert done, a message is printed into the vocable blue bar
        """
        dsn = cx_Oracle.makedsn(host=str(ip), port=str(port), service_name=str(SID))
        con = cx_Oracle.connect("system", str(passwd), dsn)
        cur2 = con.cursor()
        cur2.execute('insert into scott.emp2 select * from scott.emp2')
        con.commit()
        CrSchemaWindow.i += 1
        CrSchemaWindow.VocableVariable.set("Test schema processing step {0} out of {1}".format(str(CrSchemaWindow.i),\
                                                            str(CrSchemaWindow.LoopRatioVar - 1)))
                
        if CrSchemaWindow.i < CrSchemaWindow.LoopRatioVar:
             CrSchemaWindow.after (500, lambda:
                                   CrSchemaWindow.CreateSchemaProgress(SID,passwd, ip, port))
        else:
            con.close()
            CrSchemaWindow.VocableVariable.set("Updating statistics, please wait...")
            CrSchemaWindow.Statistics(SID, passwd, ip, port)
            

    def Statistics(CrSchemaWindow, SID, passwd, ip, port):
        """ Used generating staistics in SCOTT schema.
        """
        dsn = cx_Oracle.makedsn(host=str(ip), port=str(port), service_name=str(SID))
        con = cx_Oracle.connect("system", str(passwd), dsn)
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
        AProposWindow.LabelVersion.grid(column=0, row=0)
        AProposWindow.LabelDate.grid(column=0, row=1)
        AProposWindow.LabelContact.grid(column=0, row=2)

        buttonQuit = Tkinter.Button(AProposWindow,text=u"Close window", command=AProposWindow.destroy, width=20)
        buttonQuit.grid(column=0, row=14, sticky=S)

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
                dsn = cx_Oracle.makedsn(host=GraphWindow.ip, port=GraphWindow.port, service_name=GraphWindow.SID)
                con = cx_Oracle.connect(GraphWindow.user, GraphWindow.passwd, dsn)
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

        statWindow.wm_title(" Extended Statistics")
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
        
        statWindow.LabelNodeName = Tkinter.Label(statWindow, text="Node name")
        statWindow.LabelNodeName.grid(column=0, row=0)

        statWindow.LabelInstanceName = Tkinter.Label(statWindow, text="Instance")
        statWindow.LabelInstanceName.grid(column=1, row=0)

        statWindow.LabelNbUsers = Tkinter.Label(statWindow, text="Nb. Users")
        statWindow.LabelNbUsers.grid(column=2, row=0)
        
        statWindow.LabelBusyTime = Tkinter.Label(statWindow, text="% Busy Time")
        statWindow.LabelBusyTime.grid(column=3, row=0)

        statWindow.LabelSQLSec = Tkinter.Label(statWindow, text="SQL orders/Sec.")
        statWindow.LabelSQLSec.grid(column=4, row=0)

        statWindow.LabelIOMSec = Tkinter.Label(statWindow, text="IO MB/Sec.")
        statWindow.LabelIOMSec.grid(column=5, row=0)

        statWindow.LabelBlockRead = Tkinter.Label(statWindow, text="Blocks read/Sec.")
        statWindow.LabelBlockRead.grid(column=6, row=0)

        statWindow.EntryNodeName1var = Tkinter.StringVar()
        statWindow.EntryNodeName1 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryNodeName1var,\
                                                width=12)
        statWindow.EntryNodeName1.grid(column=0, row=1, sticky='EW')

        statWindow.EntryInstanceName1var = Tkinter.StringVar()
        statWindow.EntryInstanceName1 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryInstanceName1var,\
                                                width=12)
        statWindow.EntryInstanceName1.grid(column=1, row=1, sticky='EW')

        statWindow.EntryNbUsers1var = Tkinter.StringVar()
        statWindow.EntryNbUsers1 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryNbUsers1var,\
                                                width=12)
        statWindow.EntryNbUsers1.grid(column=2, row=1, sticky='EW')
        
        statWindow.EntryBusyTime1var = Tkinter.StringVar()
        statWindow.EntryBusyTime1 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryBusyTime1var,\
                                                width=12)
        statWindow.EntryBusyTime1.grid(column=3, row=1, sticky='EW')

        statWindow.EntrySQLSec1var = Tkinter.StringVar()
        statWindow.EntrySQLSec1 = Tkinter.Entry(statWindow, textvariable=statWindow.EntrySQLSec1var,\
                                                width=12)
        statWindow.EntrySQLSec1.grid(column=4, row=1, sticky='EW')

        statWindow.EntryIOMSec1var = Tkinter.StringVar()
        statWindow.EntryIOMSec1 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryIOMSec1var,\
                                                width=12)
        statWindow.EntryIOMSec1.grid(column=5, row=1, sticky='EW')

        statWindow.EntryBlockRead1var = Tkinter.StringVar()
        statWindow.EntryBlockRead1 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryBlockRead1var,\
                                                width=12)
        statWindow.EntryBlockRead1.grid(column=6, row=1, sticky='EW')
        

        statWindow.EntryNodeName2var = Tkinter.StringVar()
        statWindow.EntryNodeName2 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryNodeName2var,\
                                                width=12)
        statWindow.EntryNodeName2.grid(column=0, row=2, sticky='EW')

        statWindow.EntryInstanceName2var = Tkinter.StringVar()
        statWindow.EntryInstanceName2 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryInstanceName2var,\
                                                width=12)
        statWindow.EntryInstanceName2.grid(column=1, row=2, sticky='EW')

        statWindow.EntryNbUsers2var = Tkinter.StringVar()
        statWindow.EntryNbUsers2 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryNbUsers2var,\
                                                width=12)
        statWindow.EntryNbUsers2.grid(column=2, row=2, sticky='EW')
        
        statWindow.EntryBusyTime2var = Tkinter.StringVar()
        statWindow.EntryBusyTime2 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryBusyTime2var,\
                                                width=12)
        statWindow.EntryBusyTime2.grid(column=3, row=2, sticky='EW')

        statWindow.EntrySQLSec2var = Tkinter.StringVar()
        statWindow.EntrySQLSec2 = Tkinter.Entry(statWindow, textvariable=statWindow.EntrySQLSec2var,\
                                                width=12)
        statWindow.EntrySQLSec2.grid(column=4, row=2, sticky='EW')

        statWindow.EntryIOMSec2var = Tkinter.StringVar()
        statWindow.EntryIOMSec2 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryIOMSec2var,\
                                                width=12)
        statWindow.EntryIOMSec2.grid(column=5, row=2, sticky='EW')

        statWindow.EntryBlockRead2var = Tkinter.StringVar()
        statWindow.EntryBlockRead2 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryBlockRead2var,\
                                                width=12)
        statWindow.EntryBlockRead2.grid(column=6, row=2, sticky='EW')


        statWindow.EntryNodeName3var = Tkinter.StringVar()
        statWindow.EntryNodeName3 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryNodeName3var,\
                                                width=12)
        statWindow.EntryNodeName3.grid(column=0, row=3, sticky='EW')

        statWindow.EntryInstanceName3var = Tkinter.StringVar()
        statWindow.EntryInstanceName3 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryInstanceName3var,\
                                                width=12)
        statWindow.EntryInstanceName3.grid(column=1, row=3, sticky='EW')

        statWindow.EntryNbUsers3var = Tkinter.StringVar()
        statWindow.EntryNbUsers3 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryNbUsers3var,\
                                                width=12)
        statWindow.EntryNbUsers3.grid(column=2, row=3, sticky='EW')
        
        statWindow.EntryBusyTime3var = Tkinter.StringVar()
        statWindow.EntryBusyTime3 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryBusyTime3var,\
                                                width=12)
        statWindow.EntryBusyTime3.grid(column=3, row=3, sticky='EW')

        statWindow.EntrySQLSec3var = Tkinter.StringVar()
        statWindow.EntrySQLSec3 = Tkinter.Entry(statWindow, textvariable=statWindow.EntrySQLSec3var,\
                                                width=12)
        statWindow.EntrySQLSec3.grid(column=4, row=3, sticky='EW')

        statWindow.EntryIOMSec3var = Tkinter.StringVar()
        statWindow.EntryIOMSec3 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryIOMSec3var,\
                                                width=12)
        statWindow.EntryIOMSec3.grid(column=5, row=3, sticky='EW')

        statWindow.EntryBlockRead3var = Tkinter.StringVar()
        statWindow.EntryBlockRead3 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryBlockRead3var,\
                                                width=12)
        statWindow.EntryBlockRead3.grid (column=6, row=3, sticky='EW')


        statWindow.EntryNodeName4var = Tkinter.StringVar()
        statWindow.EntryNodeName4 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryNodeName4var,\
                                                width=12)
        statWindow.EntryNodeName4.grid(column=0, row=4, sticky='EW')

        statWindow.EntryInstanceName4var = Tkinter.StringVar()
        statWindow.EntryInstanceName4 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryInstanceName4var,\
                                                width=12)
        statWindow.EntryInstanceName4.grid(column=1, row=4, sticky='EW')

        statWindow.EntryNbUsers4var = Tkinter.StringVar()
        statWindow.EntryNbUsers4 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryNbUsers4var,\
                                                width=12)
        statWindow.EntryNbUsers4.grid(column=2, row=4, sticky='EW')
        
        statWindow.EntryBusyTime4var = Tkinter.StringVar()
        statWindow.EntryBusyTime4 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryBusyTime4var,\
                                                width=12)
        statWindow.EntryBusyTime4.grid(column=3, row=4, sticky='EW')

        statWindow.EntrySQLSec4var = Tkinter.StringVar()
        statWindow.EntrySQLSec4 = Tkinter.Entry(statWindow, textvariable=statWindow.EntrySQLSec4var,\
                                                width=12)
        statWindow.EntrySQLSec4.grid(column=4, row=4, sticky='EW')

        statWindow.EntryIOMSec4var = Tkinter.StringVar()
        statWindow.EntryIOMSec4 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryIOMSec4var,\
                                                width=12)
        statWindow.EntryIOMSec4.grid(column=5, row=4, sticky='EW')

        statWindow.EntryBlockRead4var = Tkinter.StringVar()
        statWindow.EntryBlockRead4 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryBlockRead4var,\
                                                width=12)
        statWindow.EntryBlockRead4.grid(column=6, row=4, sticky='EW')


        """ Button definition  """
        buttonQuit = Tkinter.Button(statWindow,text=u"Quit Statistics", command=statWindow.StopStatWindow, width=12)
        buttonQuit.grid (column=5, row=13, sticky=S)

        """ Vocable blue bar Entry definition  """
        statWindow.VocableVariable = Tkinter.StringVar()
        Vocable = Tkinter.Label(statWindow,textvariable=statWindow.VocableVariable, anchor="w", fg="white", bg="blue")
        Vocable.grid(column=0, row=13, columnspan=4, sticky='EW')
        statWindow.VocableVariable.set(u"Hello !")

        """ Start data collecting thread  """
        StatThread = threading.Thread(target=statWindow.CollectStat, args=(statWindow.SID, statWindow.passwd))
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
        #dsn_tns = cx_Oracle.makedsn('15.136.28.39', 1526, SID)
        #dsn_tns = ('scott/tiger@' + str(self.Entry3.get()))
        #version_DB['text'] = str(self.Entry3.get())
        while statWindow.LoopWindowVar == 0:
            error_con = 0

            try:
                dsn = cx_Oracle.makedsn(host=str(ip), port=str(port), service_name=str(SID))
                con = cx_Oracle.connect("system", str(passwd), dsn)
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
                compteur = 0
                cur.execute('select t.inst_id, t.value, q.value, c.value, io.value, count(u.username), substr (i.host_name,1,8), substr (i.instance_name,1,8) from gv$sysmetric t, gv$sysmetric q,  gv$sysmetric c, gv$sysmetric io, gv$session u, gv$instance i where t.metric_id=2121 and q.metric_id=2004 and c.metric_id=2057 and io.metric_id=2145 and t.group_id=3  and q.group_id=3 and c.group_id=3 and t.inst_id=q.inst_id and t.inst_id=c.inst_id and t.inst_id=i.inst_id and io.inst_id=i.inst_id and t.inst_id=u.inst_id and u.username like \'SCOTT\'  group by t.inst_id, t.value, q.value, c.value, io.value,  i.host_name, i.instance_name  order by t.inst_id')
                for result in cur:
                    compteur += 1
                    if compteur == 1:
                        statWindow.EntryNodeName1var.set(str(result[6]))
                        statWindow.EntryInstanceName1var.set(str(result[7]))
                        statWindow.EntryNbUsers1var.set(str(int(result[5])))
                        statWindow.EntryBusyTime1var.set(str("{0:.2f}".format(float(result[3]))))
                        statWindow.EntrySQLSec1var.set(str("{0:.1f}".format(float(result[1]))))
                        statWindow.EntryIOMSec1var.set(str("{0:.1f}".format(float(result[4]))))
                        statWindow.EntryBlockRead1var.set(str(int(result[2])))
                    elif compteur == 2:
                        statWindow.EntryNodeName2var.set(str(result[6]))
                        statWindow.EntryInstanceName2var.set(str(result[7]))
                        statWindow.EntryNbUsers2var.set(str(int(result[5])))
                        statWindow.EntryBusyTime2var.set(str("{0:.2f}".format(float(result[3]))))
                        statWindow.EntrySQLSec2var.set(str("{0:.1f}".format(float(result[1]))))
                        statWindow.EntryIOMSec2var.set(str("{0:.1f}".format(float(result[4]))))
                        statWindow.EntryBlockRead2var.set(str(int(result[2])))
                    elif compteur == 3:
                        statWindow.EntryNodeName3var.set(str(result[6]))
                        statWindow.EntryInstanceName3var.set(str(result[7]))
                        statWindow.EntryNbUsers3var.set(str(int(result[5])))
                        statWindow.EntryBusyTime3var.set(str("{0:.2f}".format(float(result[3]))))
                        statWindow.EntrySQLSec3var.set(str("{0:.1f}".format(float(result[1]))))
                        statWindow.EntryIOMSec3var.set(str("{0:.1f}".format(float(result[4]))))
                        statWindow.EntryBlockRead3var.set(str(int(result[2])))
                    elif compteur == 4:
                        statWindow.EntryNodeName4var.set(str(result[6]))
                        statWindow.EntryInstanceName4var.set(str(result[7]))
                        statWindow.EntryNbUsers4var.set(str(int(result[5])))
                        statWindow.EntryBusyTime4var.set(str("{0:.2f}".format(float(result[3]))))
                        statWindow.EntrySQLSec4var.set(str("{0:.1f}".format(float(result[1]))))
                        statWindow.EntryIOMSec4var.set(str("{0:.1f}".format(float(result[4]))))
                        statWindow.EntryBlockRead4var.set(str(int(result[2])))
                

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
class OraLoadThread(threading.Thread):
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

        
    def run(self):
        """
           The thread executes the same query in loop as long as:
           - it cans be connected to the database
           - the test period is not over (time.time() < (StartTimeTest + self.LengthTest)
           - the flag self.runLoad == 0. This one is switched to 1 when:
               - the test period is over
               - the user click on the stop test button
        """
        global GlobalStop
        
        error_con = 0
        StartTimeTest = time.time()
        """Test the connection. If valid, enter in a loop until the "stop load" button is hit
           or the test period is over
           app.ExecTime() call the statistics method
        """
        try:
            dsn = cx_Oracle.makedsn(host=self.OraIp, port=self.OraPort, service_name=self.OraConnect)
            con = cx_Oracle.connect(self.OraUser, self.OraPwd, dsn, threaded=True)
        except cx_Oracle.DatabaseError:
            error_con = 1
            return error_con
        
        if error_con != 1:
            while self.runLoad == 0:
                cur = con.cursor()
                cur2 = con.cursor()
                startTimeQuery = time.time()
                cur.execute('select e1.ename, min(e2.deptno), max(e2.deptno), avg(to_number(to_char(e2.sal))), \
                        avg(e2.comm), max(to_number(to_char(e2.comm))) from emp2 e2, emp e1 where e1.ename=e2.ename group by e1.ename')
                    
                elapsedTimeQuery = int(time.time() - startTimeQuery)
                cur2.execute('insert into dwhstat values (seq.NEXTVAL, :id, sysdate)',{"id":elapsedTimeQuery})
                con.commit()
                cur.close()
                cur2.close()
                app.ExecTime()

                if time.time() > (StartTimeTest + self.LengthTest):
                    app.OnButtonStopLoadClick()
                    #self.GlobalStop = 1
                    GlobalStop = 1

            con.close()

    def stopThread(self):
        """Set the stop load flag to 1. Will be passed to the threads"""
        self.runLoad = 1


class InfoBulle(Tkinter.Toplevel):
    """
        Allow context help balloon on Entry field
    """
    def __init__(self, parent=None, texte='', temps=1000):
        Tkinter.Toplevel.__init__(self, parent, bd=1, bg='black')
        self.tps = temps
        self.parent = parent
        self.withdraw()
        self.overrideredirect(1)  ## No board for the window
        self.transient()     
        l = Tkinter.Label(self, text=texte, bg="white", justify='left')
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
        posX = self.parent.winfo_rootx()+self.parent.winfo_width()
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
        can1.grid(column=1, row=24, rowspan = 5, padx=15, pady=15)

        can2 = Canvas(self, width = 500, height=20)
        can2.grid(column=0, row=15, columnspan=3, padx=10, pady=10)
        can2.create_line (10,10,490,10,width=3,fill='white')

        can3 = Canvas(self, width = 500, height=20)
        can3.grid(column=0, row=20, columnspan=3, padx=10, pady=10)
        can3.create_line (10,10,490,10,width=3,fill='white')

        """ Label:
             Text printed in the main window
        """     
        self.Label1 = Tkinter.Label(self, text='IP of Oracle DB')
        self.Label1.grid(column=0, row=0, sticky=W)
        self.Label2 = Tkinter.Label(self, text='Port of Oracle DB')
        self.Label2.grid(column=1, row=0, sticky=W)

        self.Label3 = Tkinter.Label(self, text='Test schema owner')
        self.Label3.grid(column=0, row=2, sticky=W)
        self.Label4 = Tkinter.Label(self, text='Test schema password')
        self.Label4.grid(column=1, row=2, sticky=W)
		
        self.Label5 = Tkinter.Label(self, text='Connect string')
        self.Label5.grid(column=2, row=2, sticky=W)
        self.Label6 = Tkinter.Label(self, text='Select the number of virtual users')
        self.Label6.grid(column=0, row=16, columnspan=3)
        
        self.LabelExecTimeVariable = Tkinter.StringVar()
        self.LabelExecTimeVariable.set("Avg. completion time: 0") 
        self.LabelExecTime = Tkinter.Label(self, textvariable=self.LabelExecTimeVariable, fg="red")
        self.LabelExecTime.grid (column=1, row=21)

        self.LabelNbQueriesVariable = Tkinter.StringVar()
        self.LabelNbQueriesVariable.set("Nb Queries in last MM: 0") 
        self.LabelNbQueries = Tkinter.Label(self, textvariable=self.LabelNbQueriesVariable, fg="red")
        self.LabelNbQueries.grid (column=1, row=22)

        self.LabelTestLengthVariable = Tkinter.StringVar()
        self.LabelTestLengthVariable.set("How long will be the test:")
        self.LabelTestLength = Tkinter.Label(self, textvariable=self.LabelTestLengthVariable)
        self.LabelTestLength.grid (column=1, row=19, sticky="W")

        self.labelVariable = Tkinter.StringVar()
        label = Tkinter.Label(self,textvariable=self.labelVariable,
                              anchor="w", fg="white", bg="blue")
        label.grid(column=0, row=4, columnspan=2, sticky='EW')
        self.labelVariable.set(u"Hello !")

        self.LabelSystemPwd = Tkinter.Label(self, text="SYSTEM user password: ")
        self.LabelSystemPwd.grid (column=0, row=7)

        

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
        self.Entry1.grid(column=0, row=1, sticky='EW')
        self.Entry1.bind('<Return>', self.OnPressEnter)
        ipVariable = ConfigSectionMap("Prefilled")['ip']
        self.entryIpVariable.set(ipVariable)

        self.entryPortVariable = Tkinter.StringVar()
        self.Entry2 = Tkinter.Entry(self, textvariable=self.entryPortVariable, width=15)
        self.Entry2.grid(column=1, row=1, sticky='EW')
        self.Entry2.bind('<Return>', self.OnPressEnter)
        portVariable = ConfigSectionMap("Prefilled")['port']
        self.entryPortVariable.set(portVariable)


        self.entryUserVariable = Tkinter.StringVar()
        self.Entry3 = Tkinter.Entry(self, textvariable=self.entryUserVariable)
        self.Entry3.grid(column=0, row=3, sticky='EW')
        self.Entry3.bind('<Return>', self.OnPressEnter)
        userVariable = ConfigSectionMap("Prefilled")['user']

        self.entryUserVariable.set(userVariable)

        self.entryPwdVariable = Tkinter.StringVar()
        self.Entry4 = Tkinter.Entry(self, textvariable=self.entryPwdVariable, show="*", width=15)
        self.Entry4.grid(column=1, row=3, sticky='EW')
        self.Entry4.bind('<Return>', self.OnPressEnter)
        pwdVariable = ConfigSectionMap("Prefilled")['pwd']

        self.entryPwdVariable.set(pwdVariable)

        self.entryConnectStringVariable = Tkinter.StringVar()
        self.Entry5 = Tkinter.Entry(self, textvariable=self.entryConnectStringVariable)
        self.Entry5.grid(column=2, row=3, sticky='EW')
        self.Entry5.bind('<Return>', self.OnPressEnter)
        entryConnectStringVariable = ConfigSectionMap("Prefilled")['entryconnectstring']

        self.entryConnectStringVariable.set(entryConnectStringVariable)

        self.entryConUsersVariable = Tkinter.IntVar()
        self.EntryConUsers = Tkinter.Entry(self, textvariable=self.entryConUsersVariable)
        self.EntryConUsers.grid(column=1, row=18, sticky='EW')
        self.EntryConUsers.bind('<Return>', self.OnPressEnter)
        self.entryConUsersVariable.set(4)

        """Method ValidateTestLength check that only numbers are entered into that Entry field."""
        self.ValidateTestLength = (self.register(self.OnValidate), '%d', '%i', '%P', '%s', '%S', '%v', '%V', '%W')
        self.entryTestLengthVariable = Tkinter.IntVar()
        self.EntryTestLength = Tkinter.Entry(self, textvariable=self.entryTestLengthVariable, validate='key', \
                                             validatecommand=self.ValidateTestLength, state='disabled')
        self.EntryTestLength.grid(column=2, row=19, sticky='E')
        self.entryTestLengthVariable.set(0)

        self.EntryPwdSysVariable = Tkinter.StringVar()
        self.EntryPwdSys = Tkinter.Entry(self, textvariable=self.EntryPwdSysVariable, \
                                         show="*", width=15, state='disabled')
        self.EntryPwdSys.grid(column=1, row=7, sticky='EW')
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

        buttonLess = Tkinter.Button(self, text=u"-", command=self.OnButtonLessClick, width=14)
        buttonLess.grid(column=0, row=18, sticky=E)

        buttonMore = Tkinter.Button(self, text=u"+", command=self.OnButtonMoreClick, width=14)
        buttonMore.grid(column=2, row=18, sticky=W)




        buttonTest = Tkinter.Button(self, text=u"Check User Connection", command=self.OnButtonClick, width=17)
        buttonTest.grid(column=2, row=4, columnspan=2)

        self.buttonStartLoad = Tkinter.Button(self, text=u"Start the load", command=self.OnButtonStartLoadClick \
                                              , width=14)
        self.buttonStartLoad.grid(column=0, row=21, sticky=S)

        buttonStopLoad = Tkinter.Button(self, text=u"Stop the load", command=self.OnButtonStopLoadClick \
                                        , width=14)
        buttonStopLoad.grid(column=0, row=22, sticky=S)

        buttonQuit = Tkinter.Button(self, text=u"Quit Application", command=self.QuitApps, width=14)
        buttonQuit.grid(column=1, row=23, sticky=S)

        self.buttonExtendedStat = Tkinter.Button(self, text=u"Extended Statistics", command=self.ExtendedStatistics \
                                                 , width=14)

        self.buttonExtendedStat.grid(column=0, row=23, sticky=S)
        self.buttonExtendedStat.config(state=DISABLED)

        self.ButtonTestSystemConn = Tkinter.Button(self, text=u"Check System Connection", width=17, \
                                                   command=lambda:
                                                   self.test_SID("System"))


        self.ButtonTestSystemConn.grid(column=2, row=7, columnspan=2)
        self.ButtonTestSystemConn.config(state=DISABLED)

        self.ButtonCreateSchema = Tkinter.Button(self, text=u"Create Test Schema", width=17, \
                                                 command=self.CreateSchema)
        self.ButtonCreateSchema.grid(column=2, row=8, columnspan=2)
        self.ButtonCreateSchema.config(state=DISABLED)

        buttonGraph = Tkinter.Button(self, text=u"Graph", command=self.StartGraph, width=14)
        buttonGraph.grid(column=2, row=21, columnspan=2)

        buttonAPropos = Tkinter.Button(self, text=u"A propos...", command=self.APropos, width=14)
        buttonAPropos.grid(column=2, row=23, columnspan=2)

        buttonNbThread = Tkinter.Button(self, text=u"Nb. of threads", command=self.NbThread, width=14)
        buttonNbThread.grid(column=2, row=22, columnspan=1)


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
        self.CheckSysdbaEnabled.grid(column=0, row=6, sticky=W)
        self.CheckSysdbaEnabled.deselect()


        self.TestLength = IntVar()
        self.TestLengthStatus = Tkinter.Checkbutton(self, text="Define Length of the test?", variable=self.TestLength, \
                                                    command=self.TestLengthMeth)
        self.TestLengthStatus.grid(column=0, row=19, sticky=W)
        self.TestLengthStatus.deselect()

        self.CheckAWRSnapshot = IntVar()
        self.CheckAWRSnapshotStatus = Tkinter.Checkbutton(self, text="Enable AWReport Snapshot", \
                                                          variable=self.CheckAWRSnapshot)
        self.CheckAWRSnapshotStatus.grid(column=0, row=8, sticky=W)
        self.CheckAWRSnapshotStatus.deselect()
        self.CheckAWRSnapshotStatus.configure(state='disabled')


        self.grid_columnconfigure(0, weight=1)
        self.resizable(True, False)
        self.update()
        self.geometry(self.geometry())
        self.Entry1.focus_set()
        self.Entry1.selection_range(0, Tkinter.END)


    def NbThread(self):
        nbthread = int(threading.activeCount())
        self.labelVariable.set(" {0} active connections.".format(nbthread))
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
            self.labelVariable.set("Loader shutdown ongoing. Still {0} active connections.".format(nbthread))
            self.after(1000, self.ProperStopApps)
        else:
            self.labelVariable.set("Shutdown now!")
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
                dsn = cx_Oracle.makedsn(host=str(self.Entry1.get()), port=str(self.Entry1.get()), service_name=str(self.Entry5.get()))
                con = cx_Oracle.connect("system", str(self.EntryPwdSys.get()), dsn)
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 1017:
                    self.labelVariable.set(self.entryConnectStringVariable.get() + ": System invalid password")
                    #statWindow.VocableVariable.set(self.entryConnectStringVariable.get()+": Invalid username or password")
                    #messageretour = str(self.entryConnectStringVariable.get()+": Invalid username or password")
                    error_con = 1
                elif error.code == 12154:
                    self.labelVariable.set(self.entryConnectStringVariable.get() + ": TNS couldn't resolve the SID")
                    error_con = 1
                elif error.code == 12543:
                    self.labelVariable.set(self.entryConnectStringVariable.get() + ": Destination host not available")
                    error_con = 1
                else:
                    self.labelVariable.set(self.entryConnectStringVariable.get() + ": System unable to connect")
                    error_con = 1
            
            if error_con != 1:
                cur = con.cursor()
                res = cur.callfunc('dbms_workload_repository.create_snapshot', cx_Oracle.NUMBER, ())
                cur.close()
                cur2 = con.cursor()
                cur2.execute('select max(snap_id) from dba_hist_snapshot')
                for result in cur2:
                    resultVar = str(result[0])
                    self.labelVariable.set(" Snapshot took with ID #{0}.".format(resultVar))
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
        ConcUsers = int(self.EntryConUsers.get())
        ConcUsers -= 1
        self.entryConUsersVariable.set(ConcUsers)

    def OnButtonMoreClick(self):
        """
            Increase by one the number of concurrent users.
        """
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
        
        for t in self.existingThread:
            if t.isAlive():
                t.stopThread()
                
        
        #if self.GlobalStop == 0:
        if GlobalStop == 0:
            dsn = cx_Oracle.makedsn(host=str(self.Entry1.get()), port=str(self.Entry2.get()), service_name=str(self.Entry5.get()))
            con = cx_Oracle.connect(str(self.Entry3.get()), str(self.Entry4.get()), dsn)
            cur = con.cursor()
            cur.execute('select count(*) from dwhstat')
            for result in cur:
                resultVar = str(result[0])
                self.labelVariable.set(u"Workload will end shortly! {0} trans. completed in this run.".format(resultVar))
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
        i = 1

        ### Snapshot the db if the option is selected.
        self.SnapshotDB()
        
        #### Check whether the the test schema is available or not. Leave the method if not
        CheckSchemaVar = self.CheckSchema()
        if CheckSchemaVar <> 0:
            self.buttonStartLoad.config(state=NORMAL)
            return
        
        self.InitTableStat()
        self.my_thread = OraLoadThread(str(self.Entry3.get()), str(self.Entry4.get()), str(self.Entry5.get()),
                                       str(self.Entry1.get()), str(self.Entry2.get()),
                                       int(self.EntryTestLength.get()))
        #self.labelVariable.set('self.my_thread value = {0}'.format(str(runStatus)))
        self.my_thread.name = i
        self.my_thread.start()
        self.existingThread.append(self.my_thread)
        
        #while (int(threading.activeCount()) < ((int(self.EntryConUsers.get ()))+2)) and runStatus == 0:
        while int(threading.activeCount()) < ((int(self.EntryConUsers.get ())) + 2):
            i += 1
            self.my_thread = OraLoadThread(str(self.Entry3.get()), str(self.Entry4.get()), str(self.Entry5.get()),
                                           str(self.Entry1.get()), str(self.Entry2.get()),
                                           int(self.EntryTestLength.get()))
            self.my_thread.name = i
            self.my_thread.start()
            self.existingThread.append(self.my_thread)
            #time.sleep(1)
            #self.after(500, self.labelVariable.set("Number of Thread: "+str(threading.activeCount())))
            ActiveUsers = int(threading.activeCount()) - 2
            self.labelVariable.set("Number of active users: " + str(ActiveUsers))
            
            
    def CheckSchema(self):
        """
            This method checks if the test schema is existing and the database available before starting the load threads.
            Return 1 if the db is not reachable.
            Return 2 if the test schema is not existing.
        """
        error_con = 0
        try:
            dsn = cx_Oracle.makedsn(host=str(self.Entry1.get()), port=str(self.Entry2.get()), service_name=str(self.Entry5.get()))
            con = cx_Oracle.connect(str(self.Entry3.get()), str(self.Entry4.get()), dsn)
        except cx_Oracle.DatabaseError:
            self.labelVariable.set(self.entryConnectStringVariable.get() + ": Unable to connect with user {0}!"\
                                    .format(str(self.Entry3.get())))
            return 1
            
        if error_con != 1:
            cur = con.cursor()
            try:
                cur.execute('select count(*) from emp2')
            except cx_Oracle.DatabaseError:
                self.labelVariable.set("Cannot access the test schema. Please create it again")
                return 2

            cur2 = con.cursor()
            try:
                cur.execute('select count(*) from dwhstat')
            except cx_Oracle.DatabaseError:
                self.labelVariable.set("Cannot access the test schema. Please create it again")
                return 3

            cur.close()
            cur2.close()
            con.close()
            return 0

        
    def OnPressEnter(self, event):
        """
            Event associated with the Press Enter keybord action. No impact
        """    
        self.labelVariable.set(self.entryUserVariable.get() + " You pressed Enter!")
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
            dsn = cx_Oracle.makedsn(host=str(self.Entry1.get()), port=str(self.Entry2.get()), service_name=str(self.Entry5.get()))
            con = cx_Oracle.connect(str(self.Entry3.get()), str(self.Entry4.get()), dsn)
        except cx_Oracle.DatabaseError:
            self.labelVariable.set(self.entryConnectStringVariable.get() + ": Unable to connect!")
            error_con = 1
        
        if error_con != 1:
            cur = con.cursor()
            try:
                cur.execute('truncate table dwhstat')
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 942:
                    self.labelVariable.set(self.entryConnectStringVariable.get() + ": Test schema does not exist. Create it first!")
            cur.close()
            con.close()

            
    def test_SID(self, origin):
        """ Test if the connection parameters are valid.
            - If the connection is valid print the db_name into the vocable label.
                Otherwise print an error message.
        """        
        #dsn_tns = cx_Oracle.makedsn('15.136.28.39', 1526, SID)
        #dsn_tns = ('scott/tiger@' + str(self.Entry3.get()))
        #version_DB['text'] = str(self.Entry3.get())
        error_con = 0

        if origin == "User":
            try:
                dsn = cx_Oracle.makedsn(host=str(self.Entry1.get()), port=str(self.Entry2.get()), service_name=str(self.Entry5.get()))
                con = cx_Oracle.connect(str(self.Entry3.get()), str(self.Entry4.get()), dsn)
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 1017:
                    self.labelVariable.set(self.entryConnectStringVariable.get() +  \
                                            ": {0} Invalid username or password".format(str(self.Entry1.get())))
                    error_con = 1
                elif error.code == 12154:
                    self.labelVariable.set(self.entryConnectStringVariable.get() + ": TNS couldn't resolve the SID")
                    error_con = 1
                elif error.code == 12543:
                    self.labelVariable.set(self.entryConnectStringVariable.get() + ": Destination host not available")
                    error_con = 1
                else:
                    self.labelVariable.set(self.entryConnectStringVariable.get() + ": Unable to connect")
                    error_con = 1
            
            if error_con != 1:
                cur = con.cursor()
                cur.execute('select * from global_name')
                for result in cur:
                    resultVar = str(result[0])
                    self.labelVariable.set("{0}: {1}, Connection succesfull".format(resultVar, str(self.Entry3.get())))
                cur.close()
                con.close()
        elif origin == "System":
            try:
                dsn = cx_Oracle.makedsn(host=str(self.Entry1.get()), port=str(self.Entry2.get()), service_name=str(self.Entry5.get()))
                con = cx_Oracle.connect("system", str(self.EntryPwdSys.get()), dsn)
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 1017:
                    self.labelVariable.set(self.entryConnectStringVariable.get() + ": System invalid password")
                    #statWindow.VocableVariable.set(self.entryConnectStringVariable.get()+": Invalid username or password")
                    #messageretour = str(self.entryConnectStringVariable.get()+": Invalid username or password")
                    error_con = 1
                elif error.code == 12154:
                    self.labelVariable.set(self.entryConnectStringVariable.get() + ": TNS couldn't resolve the SID")
                    error_con = 1
                elif error.code == 12543:
                    self.labelVariable.set(self.entryConnectStringVariable.get() + ": Destination host not available")
                    error_con = 1
                else:
                    self.labelVariable.set(self.entryConnectStringVariable.get() + ": System unable to connect")
                    error_con = 1
            
            if error_con != 1:
                cur = con.cursor()
                cur.execute('select * from global_name')
                for result in cur:
                    resultVar = str(result[0])
                    self.labelVariable.set("{0}: System, connection succesfull".format(resultVar))
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
            dsn = cx_Oracle.makedsn(host=str(self.Entry1.get()), port=str(self.Entry2.get()), service_name=str(self.Entry5.get()))
            con = cx_Oracle.connect(str(self.Entry3.get()), str(self.Entry4.get()), dsn)
        except cx_Oracle.DatabaseError:
            self.labelVariable.set(self.entryConnectStringVariable.get() + ": Unable to connect!")
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
        statWindow = ExtendedStatisticsWindow(str(self.Entry3.get()), str(self.EntryPwdSys.get()), str(self.Entry1.get()), str(self.Entry2.get()))

    def CreateSchema(self):
        """ test schema creation method """
        CreateSchematWindow = CreateTestSchemaWindow(str(self.Entry5.get()), str(self.EntryPwdSys.get()), str(self.Entry1.get()), str(self.Entry2.get()))

    def APropos(self):
        """ Information about the application """
        AProposWindow = CreateAProposWindow()

    def StartGraph(self):
        GraphikWindow = GraphWindow(str(self.Entry3.get()), str(self.Entry4.get()), str(self.Entry5.get()), str(self.Entry1.get()), str(self.Entry2.get()))
        
        
        
if __name__ == "__main__":
    Config = ConfigParser.ConfigParser()
    Config.read("./config.ini")
    app = simpleapp_tk(None)
    app.title('JERY Workload Generator')
    app.mainloop()
################################################################