#!/usr/local/bin/python3
#-*- coding: iso-8859-1 -*-

import Tkinter
from Tkinter import *
import cx_Oracle
import threading
import time


class ExtendedStatistics(Tkinter.Toplevel):
    def __init__(statWindow,SID,passwd):
        Tkinter.Toplevel.__init__(statWindow)

        statWindow.wm_title(" Extended Statistics")
        statWindow.SID = SID
        statWindow.passwd = passwd


        statWindow.LabelNodeName = Tkinter.Label(statWindow, text="Node name ")
        statWindow.LabelNodeName.grid (column=0, row=0)

        statWindow.LabelBusyTime = Tkinter.Label(statWindow, text="% Busy Time")
        statWindow.LabelBusyTime.grid (column=1, row=0)

        statWindow.LabelSQLSec = Tkinter.Label(statWindow, text="SQL orders/Second")
        statWindow.LabelSQLSec.grid (column=2, row=0)

        statWindow.LabelBlockRead = Tkinter.Label(statWindow, text="Blocks read/Second ")
        statWindow.LabelBlockRead.grid (column=3, row=0)

        statWindow.EntryNodeName1var = Tkinter.StringVar()
        statWindow.EntryNodeName1 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryNodeName1var,\
                                                width=15)
        statWindow.EntryNodeName1.grid (column=0, row=1, sticky='EW')
        
        statWindow.EntryBusyTime1var = Tkinter.StringVar()
        statWindow.EntryBusyTime1 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryBusyTime1var,\
                                                width=15)
        statWindow.EntryBusyTime1.grid (column=1, row=1, sticky='EW')

        statWindow.EntrySQLSec1var = Tkinter.StringVar()
        statWindow.EntrySQLSec1 = Tkinter.Entry(statWindow, textvariable=statWindow.EntrySQLSec1var,\
                                                width=15)
        statWindow.EntrySQLSec1.grid (column=2, row=1, sticky='EW')

        statWindow.EntryBlockRead1var = Tkinter.StringVar()
        statWindow.EntryBlockRead1 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryBlockRead1var,\
                                                width=15)
        statWindow.EntryBlockRead1.grid (column=3, row=1, sticky='EW')

        statWindow.EntryNodeName2var = Tkinter.StringVar()
        statWindow.EntryNodeName2 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryNodeName2var,\
                                                width=15)
        statWindow.EntryNodeName2.grid (column=0, row=2, sticky='EW')
        
        statWindow.EntryBusyTime2var = Tkinter.StringVar()
        statWindow.EntryBusyTime2 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryBusyTime2var,\
                                                width=15)
        statWindow.EntryBusyTime2.grid (column=1, row=2, sticky='EW')

        statWindow.EntrySQLSec2var = Tkinter.StringVar()
        statWindow.EntrySQLSec2 = Tkinter.Entry(statWindow, textvariable=statWindow.EntrySQLSec2var,\
                                                width=15)
        statWindow.EntrySQLSec2.grid (column=2, row=2, sticky='EW')

        statWindow.EntryBlockRead2var = Tkinter.StringVar()
        statWindow.EntryBlockRead2 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryBlockRead2var,\
                                                width=15)
        statWindow.EntryBlockRead2.grid (column=3, row=2, sticky='EW')

        statWindow.EntryNodeName3var = Tkinter.StringVar()
        statWindow.EntryNodeName3 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryNodeName3var,\
                                                width=15)
        statWindow.EntryNodeName3.grid (column=0, row=3, sticky='EW')
        
        statWindow.EntryBusyTime3var = Tkinter.StringVar()
        statWindow.EntryBusyTime3 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryBusyTime3var,\
                                                width=15)
        statWindow.EntryBusyTime3.grid (column=1, row=3, sticky='EW')

        statWindow.EntrySQLSec3var = Tkinter.StringVar()
        statWindow.EntrySQLSec3 = Tkinter.Entry(statWindow, textvariable=statWindow.EntrySQLSec3var,\
                                                width=15)
        statWindow.EntrySQLSec3.grid (column=2, row=3, sticky='EW')

        statWindow.EntryBlockRead3var = Tkinter.StringVar()
        statWindow.EntryBlockRead3 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryBlockRead3var,\
                                                width=15)
        statWindow.EntryBlockRead3.grid (column=3, row=3, sticky='EW')

        statWindow.EntryNodeName4var = Tkinter.StringVar()
        statWindow.EntryNodeName4 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryNodeName4var,\
                                                width=15)
        statWindow.EntryNodeName4.grid (column=0, row=4, sticky='EW')
        
        statWindow.EntryBusyTime4var = Tkinter.StringVar()
        statWindow.EntryBusyTime4 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryBusyTime4var,\
                                                width=15)
        statWindow.EntryBusyTime4.grid (column=1, row=4, sticky='EW')

        statWindow.EntrySQLSec4var = Tkinter.StringVar()
        statWindow.EntrySQLSec4 = Tkinter.Entry(statWindow, textvariable=statWindow.EntrySQLSec4var,\
                                                width=15)
        statWindow.EntrySQLSec4.grid (column=2, row=4, sticky='EW')

        statWindow.EntryBlockRead4var = Tkinter.StringVar()
        statWindow.EntryBlockRead4 = Tkinter.Entry(statWindow, textvariable=statWindow.EntryBlockRead4var,\
                                                width=15)
        statWindow.EntryBlockRead4.grid (column=3, row=4, sticky='EW')


        buttonQuit = Tkinter.Button(statWindow,text=u"Quit Statistics", command=statWindow.destroy, width=14)
        buttonQuit.grid (column=3, row=13, sticky=S)
        
        statWindow.VocableVariable = Tkinter.StringVar()
        Vocable = Tkinter.Label(statWindow,textvariable=statWindow.VocableVariable, anchor="w", fg="white", bg="blue")
        Vocable.grid(column=0, row=13, columnspan=2, sticky='EW')
        statWindow.VocableVariable.set(u"Hello !")

        StatThread = threading.Thread(target=statWindow.CollectStat, args=(statWindow.SID, statWindow.passwd))
        StatThread.start()
        
        statWindow.grid_columnconfigure(0,weight=1)
        statWindow.resizable(True,False)
        statWindow.update()
        statWindow.geometry(statWindow.geometry())


    def CollectStat(statWindow,SID,passwd):
        """ Test if the connection parameters are valid.
            - If the connection is valid print the db_name into the vocable label.
                Otherwise print an error message.
        """        
        #dsn_tns = cx_Oracle.makedsn('15.136.28.39', 1526, SID)
        #dsn_tns = ('scott/tiger@' + str(self.Entry3.get()))
        #version_DB['text'] = str(self.Entry3.get())
        while 1:
            error_con = 0

            try:
                con = cx_Oracle.connect("system", str(passwd), str(SID))
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 1017:
                    statWindow.VocableVariable.set(str(SID)+": Invalid username or password")
                    error_con = 1
                elif error.code == 12154:
                    statWindow.VocableVariable.set (str(SID)+": TNS couldn't resolve the SID")
                    error_con = 1
                elif error.code == 12543:
                    statWindow.VocableVariable.set (str(SID)+": Destination host not available")
                    error_con = 1
                else:
                    statWindow.VocableVariable.set (str(SID)+": Unable to connect")
                    error_con = 1
                
            if error_con != 1:
                cur = con.cursor()
                compteur = 0
                cur.execute('select t.inst_id, t.value, q.value, c.value, substr (i.host_name,1,8) from gv$sysmetric t, gv$sysmetric q,  gv$sysmetric c, gv$session u, gv$instance i where t.metric_id=2121 and q.metric_id=2004 and c.metric_id=2057 and t.group_id=3  and q.group_id=3 and c.group_id=3 and t.inst_id=q.inst_id and t.inst_id=c.inst_id and t.inst_id=i.inst_id group by t.inst_id, t.value, q.value, c.value, i.host_name  order by t.inst_id')
                for result in cur:
                    compteur += 1
                    if compteur == 1:
                        statWindow.EntryNodeName1var.set(str(result[4]))
                        statWindow.EntryBusyTime1var.set(str("{0:.2f}".format(float(result[3]))))
                        statWindow.EntrySQLSec1var.set(str("{0:.1f}".format(float(result[1]))))
                        statWindow.EntryBlockRead1var.set(str(int(result[2])))
                    elif compteur == 2:
                        statWindow.EntryNodeName2var.set(str(result[4]))
                        statWindow.EntryBusyTime2var.set(str("{0:.2f}".format(float(result[3]))))
                        statWindow.EntrySQLSec2var.set(str("{0:.1f}".format(float(result[1]))))
                        statWindow.EntryBlockRead2var.set(str(int(result[2])))
                    elif compteur == 3:
                        statWindow.EntryNodeName3var.set(str(result[4]))
                        statWindow.EntryBusyTime3var.set(str("{0:.2f}".format(float(result[3]))))
                        statWindow.EntrySQLSec3var.set(str("{0:.1f}".format(float(result[1]))))
                        statWindow.EntryBlockRead3var.set(str(int(result[2])))
                    elif compteur == 4:
                        statWindow.EntryNodeName4var.set(str(result[4]))
                        statWindow.EntryBusyTime4var.set(str("{0:.2f}".format(float(result[3]))))
                        statWindow.EntrySQLSec4var.set(str("{0:.1f}".format(float(result[1]))))
                        statWindow.EntryBlockRead4var.set(str(int(result[2])))
                

                    statWindow.VocableVariable.set ("You are connected to {0}".format(str(SID)))
                cur.close()
                con.close()
                time.sleep(5)


class OraLoadThread(threading.Thread):
    def __init__(self, OraUser, OraPwd, OraConnect, LengthTest):
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
        error_con = 0
        StartTimeTest = time.time()
        """Test the connection. If valid, enter in a loop until the "stop load" button is hit
           or the test period is over
           app.ExecTime() call the statistics method
        """
        try:
            con = cx_Oracle.connect(self.OraUser, self.OraPwd, self.OraConnect)
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
                cur2.execute('insert into dwhstat values (:id)',{"id":elapsedTimeQuery})
                con.commit()
                cur.close()
                cur2.close()
                app.ExecTime()
                if time.time() > (StartTimeTest + self.LengthTest):
                    app.OnButtonStopLoadClick()
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
        l = Tkinter.Label(self, text=texte, bg="yellow", justify='left')
        l.update_idletasks()
        l.pack()
        l.update_idletasks()
        self.tipwidth = l.winfo_width()
        self.tipheight = l.winfo_height()
        self.parent.bind('<Enter>', self.delai)
        self.parent.bind('<Button-1>', self.efface)
        self.parent.bind('<Leave>', self.efface)
        
    ## Delay before the help balloon appears
    def delai(self,event):
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

        """ Canvas:
            - HP logo (can1)
            - Horizontal line 1 (can2). Split login information and load setting
            - Horizontal line 2 (can3). Split load setting and action buttons
        """    
        can1 = Canvas(self, width = 80, height = 80, bg='white')
        self.logohp = PhotoImage(file='/usr/yann/dwh2/HP_round4.gif')
        item = can1.create_image(40,40, image=self.logohp)
        can1.grid(column=1, row=19, rowspan = 5, padx=5, pady=15)

        can2 = Canvas(self, width = 500, height=20)
        can2.grid(column=0, row=13, columnspan=3, padx=10, pady=10)
        can2.create_line (10,10,490,10,width=3,fill='white')

        can3 = Canvas(self, width = 500, height=20)
        can3.grid(column=0, row=18, columnspan=3, padx=10, pady=10)
        can3.create_line (10,10,490,10,width=3,fill='white')

        """ Label:
             Text printed in the main window
        """     
        self.Label1 = Tkinter.Label(self, text='Test schema owner')
        self.Label1.grid (column=0, row=0, sticky = W)
        self.Label2 = Tkinter.Label(self, text='Test schema password')
        self.Label2.grid (column=1, row=0, sticky = W)
        self.Label3 = Tkinter.Label(self, text='Connect string')
        self.Label3.grid (column=2, row=0, sticky = W)
        self.Label4 = Tkinter.Label(self, text='Select the number of virtual users')
        self.Label4.grid (column=0, row=14, columnspan=3)
        
        self.LabelExecTimeVariable = Tkinter.StringVar()
        self.LabelExecTimeVariable.set("Avg. completion time: 0") 
        self.LabelExecTime = Tkinter.Label(self, textvariable=self.LabelExecTimeVariable, fg="red")
        self.LabelExecTime.grid (column=2, row=19)

        self.LabelTestLengthVariable = Tkinter.StringVar()
        self.LabelTestLengthVariable.set("How long will be the test:")
        self.LabelTestLength = Tkinter.Label(self, textvariable=self.LabelTestLengthVariable)
        self.LabelTestLength.grid (column=1, row=17, sticky="W")

        self.labelVariable = Tkinter.StringVar()
        label = Tkinter.Label(self,textvariable=self.labelVariable,
                              anchor="w", fg="white", bg="blue")
        label.grid(column=0, row=2, columnspan=2, sticky='EW')
        self.labelVariable.set(u"Hello !")

        self.LabelSystemPwd = Tkinter.Label(self, text="SYSTEM user password: ")
        self.LabelSystemPwd.grid (column=0, row=5)

        

        """ Entry:
            - test schema user name (Entry1)
            - test schema user password (Entry2)
            - db connect string (Entry3)
            - number of concurrent users or parallel job threads (EntryConUsers)
            - Length of the test (only if unlimited loop is not selected) (EntryTestLength).
                Only allow numeric input.    
        """    
        self.entryUserVariable = Tkinter.StringVar()
        self.Entry1 = Tkinter.Entry(self, textvariable=self.entryUserVariable)
        self.Entry1.grid (column=0, row=1, sticky='EW')
        self.Entry1.bind('<Return>', self.OnPressEnter)
        self.entryUserVariable.set(u"SCOTT")

        self.entryPwdVariable = Tkinter.StringVar()
        self.Entry2 = Tkinter.Entry(self, textvariable=self.entryPwdVariable, show="*", width=15)
        self.Entry2.grid (column=1, row=1, sticky='EW')
        self.Entry2.bind('<Return>', self.OnPressEnter)
        self.entryPwdVariable.set(u"tiger")

        self.entryConnectStringVariable = Tkinter.StringVar()
        self.Entry3 = Tkinter.Entry(self, textvariable=self.entryConnectStringVariable)
        self.Entry3.grid (column=2, row=1, sticky='EW')
        self.Entry3.bind('<Return>', self.OnPressEnter)
        self.entryConnectStringVariable.set(u"DWH")

        self.entryConUsersVariable = Tkinter.IntVar()
        self.EntryConUsers = Tkinter.Entry(self, textvariable=self.entryConUsersVariable)
        self.EntryConUsers.grid (column=1, row=16, sticky='EW')
        self.EntryConUsers.bind('<Return>', self.OnPressEnter)
        self.entryConUsersVariable.set (4)

        """Method ValidateTestLength check that only numbers are entered into that Entry field."""
        self.ValidateTestLength = (self.register(self.OnValidate), '%d', '%i', '%P', '%s', '%S', '%v', '%V', '%W')
        self.entryTestLengthVariable = Tkinter.IntVar()
        self.EntryTestLength = Tkinter.Entry(self, textvariable=self.entryTestLengthVariable, validate = 'key', \
                                             validatecommand = self.ValidateTestLength, state='disabled')
        self.EntryTestLength.grid (column=2, row=17, sticky='E')
        self.entryTestLengthVariable.set (0)

        self.EntryPwdSysVariable = Tkinter.StringVar()
        self.EntryPwdSys = Tkinter.Entry(self, textvariable=self.EntryPwdSysVariable,\
                                               show="*", width=15, state='disabled')
        self.EntryPwdSys.grid (column=1, row=5, sticky='EW')
        self.EntryPwdSysVariable.set(u"manager")
        
        """ Button section:
           - buttonLess: decrease the number of // workers
           - buttonMore: increase the number of // workers
           - buttonTest: Check the connection to the database
           - buttonStartLoad: Start the threads
           - buttonStopLoad: kill the threads
           - buttonQuit: close the apps
           - buttonExtendedStat: Open a second window with advanced statistics.
        """   
        buttonLess = Tkinter.Button(self,text=u"-", command=self.OnButtonLessClick, width=14)
        buttonLess.grid(column=0, row=16, sticky=E)

        buttonMore = Tkinter.Button(self,text=u"+", command=self.OnButtonMoreClick, width=14)
        buttonMore.grid(column=2, row=16, sticky=W)
        
        buttonTest = Tkinter.Button(self,text=u"Check User Connection", command=self.OnButtonClick, width=17)
        buttonTest.grid(column=2, row=2, columnspan=2)

        self.buttonStartLoad = Tkinter.Button(self,text=u"Start the load", command=self.OnButtonStartLoadClick \
                                              , width=14)
        self.buttonStartLoad.grid(column=0, row=19, sticky=S)

        buttonStopLoad = Tkinter.Button(self,text=u"Stop the load", command=self.OnButtonStopLoadClick \
                                        , width=14)
        buttonStopLoad.grid(column=0, row=20, sticky=S)

        buttonQuit = Tkinter.Button(self,text=u"Quit Application", command=self.destroy, width=14)
        buttonQuit.grid (column=2, row=21, sticky=S)

        self.buttonExtendedStat = Tkinter.Button(self,text=u"Extended Statistics", command=self.ExtendedStatistics \
                                            , width=14)
        self.buttonExtendedStat.grid (column=0, row=21, sticky=S)
        self.buttonExtendedStat.config(state=DISABLED)

        self.ButtonTestSystemConn = Tkinter.Button(self,text=u"Check System Connection", width=17,  \
                                command= lambda:
                                               self.test_SID("System"))
        self.ButtonTestSystemConn.grid(column=2, row=5, columnspan=2)
        self.ButtonTestSystemConn.config(state=DISABLED)

        """ Balloon section
            enable help on Entry field
        """    
        balloonHelpSID = InfoBulle(parent=self.Entry3, texte="Enter the SID or the connect string (ip:port:SID)")
        balloonUserScott = InfoBulle(parent=self.Entry1, texte="Enter the username owning the test schema")
        balloonUserPwd = InfoBulle(parent=self.Entry2, texte="Enter the password of the user owning the test schema")
        balloonSystemPwd = InfoBulle(parent=self.EntryPwdSys, texte="Enter the password of the SYSTEM (sysdba) user")
        balloonTestLength = InfoBulle(parent=self.EntryTestLength, texte="How long will run the test in minutes")


        """ Checkbutton define whether the test run on a limited period of time or if it will run
            until the stop button is hitted
        """
        self.SysdbaEnabled = IntVar()
        self.CheckSysdbaEnabled = Tkinter.Checkbutton(self, text="Enable SYSDBA mode?", variable=self.SysdbaEnabled, \
                                                    command=self.SysdbaEnabledMeth)
        self.CheckSysdbaEnabled.grid (column=0, row=4, sticky=W)
        self.CheckSysdbaEnabled.deselect()
        
        self.TestLength = IntVar()
        self.TestLengthStatus = Tkinter.Checkbutton(self, text="Define Length of the test?", variable=self.TestLength, \
                                                    command=self.TestLengthMeth)
        self.TestLengthStatus.grid (column=0, row=17, sticky=W)
        self.TestLengthStatus.deselect()

        self.CheckAWRSnapshot = IntVar()
        self.CheckAWRSnapshotStatus = Tkinter.Checkbutton(self, text="Enable Snapshot for AWR Report", \
                                                          variable=self.CheckAWRSnapshot)
        self.CheckAWRSnapshotStatus.grid (column=0, row=6, sticky=W)
        self.CheckAWRSnapshotStatus.deselect()
        self.CheckAWRSnapshotStatus.configure(state='disabled')
        

        self.grid_columnconfigure(0,weight=1)
        self.resizable(True,False)
        self.update()
        self.geometry(self.geometry())
        self.Entry1.focus_set()
        self.Entry1.selection_range(0, Tkinter.END)


    def OnValidate(self, action, index, value_if_allowed, prior_value, text, validation_type, trigger_type, widget_name):
        """
            Check the value typed into an Entry field are numeric only
        """    
        if text in '0123456789':
            return True
        else:
            return False

    def SnapshotDB(self):
        error_con = 0
        if self.CheckAWRSnapshot.get() == 1:
            try:
                con = cx_Oracle.connect("system", str(self.EntryPwdSys.get()), str(self.Entry3.get()))
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 1017:
                    self.labelVariable.set (self.entryConnectStringVariable.get()+": System invalid password")
                    #statWindow.VocableVariable.set(self.entryConnectStringVariable.get()+": Invalid username or password")
                    #messageretour = str(self.entryConnectStringVariable.get()+": Invalid username or password")
                    error_con = 1
                elif error.code == 12154:
                    self.labelVariable.set (self.entryConnectStringVariable.get()+": TNS couldn't resolve the SID")
                    error_con = 1
                elif error.code == 12543:
                    self.labelVariable.set (self.entryConnectStringVariable.get()+": Destination host not available")
                    error_con = 1
                else:
                    self.labelVariable.set (self.entryConnectStringVariable.get()+": System unable to connect")
                    error_con = 1
            
            if error_con != 1:
                cur = con.cursor()
                res = cur.callfunc('dbms_workload_repository.create_snapshot', cx_Oracle.NUMBER, ())
                cur.close()
                cur2 = con.cursor()
                cur2.execute('select max(snap_id) from dba_hist_snapshot')
                for result in cur2:
                    resultVar = str(result[0])
                    self.labelVariable.set (" Snapshot took with ID #{0}.".format(resultVar))
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
        else:
            self.buttonExtendedStat.config(state=NORMAL)
            self.ButtonTestSystemConn.config(state=NORMAL)
            self.EntryPwdSys.configure(state='normal')
            self.CheckAWRSnapshotStatus.configure(state='normal')

    
    def TestLengthMeth(self):
        """
            If the limited execution time checkbox (self.TestLengthStatus) is checked, the entry field for the Length test
            is disabled.
        """    
        if self.TestLength.get() == 0:
            self.entryTestLengthVariable.set (0)
            self.EntryTestLength.configure(state='disabled')
        else:
            self.EntryTestLength.configure(state='normal')
            
        
    def OnButtonLessClick(self):
        """
            Reduce by one the number of concurrent users.
        """    
        ConcUsers = int(self.EntryConUsers.get ())
        ConcUsers -= 1
        self.entryConUsersVariable.set(ConcUsers)

    def OnButtonMoreClick(self):
        """
            Increase by one the number of concurrent users.
        """
        ConcUsers = int(self.EntryConUsers.get ())
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
        for t in self.existingThread:
            if t.isAlive():
                t.stopThread()
            
        self.labelVariable.set (u"The workload will end shortly!")
        self.buttonStartLoad.config(state=NORMAL)
        self.after(4000, self.SnapshotDB)
        
        
    def OnButtonStartLoadClick(self):
        """ Start the Load threads
            - Start button is disabled
            - Print a temporary message before we get execution statistics
            - Call the statistics table creation
            - create a first thread with the login information and the length of the test as parameter
            - start the thread
            - Enter in a loop in order to start as much thread as needed (+2 as we do have existing threads
                which are the main process.
        """    
        self.buttonStartLoad.config(state=DISABLED)
        self.LabelExecTimeVariable.set ('Ramping up')
        self.existingThread = []
        error_con = 0
        i = 1

        self.SnapshotDB()
            
        self.CreateTableStat()
        self.my_thread = OraLoadThread(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry3.get()), \
                                       int(self.EntryTestLength.get()))
        self.my_thread.name = i
        self.my_thread.start()
        self.existingThread.append(self.my_thread)
        
        while int(threading.activeCount()) < ((int(self.EntryConUsers.get ()))+2):
            i += 1
            self.my_thread = OraLoadThread(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry3.get()), \
                                           int(self.EntryTestLength.get()))
            self.my_thread.name = i
            self.my_thread.start()
            self.existingThread.append(self.my_thread)
            time.sleep(2)
            #self.after(500, self.labelVariable.set ("Number of Thread: "+str(threading.activeCount())))
            

    def OnPressEnter(self,event):
        """
            Event associated with the Press Enter keybord action. No impact
        """    
        self.labelVariable.set (self.entryUserVariable.get()+" You pressed Enter!")
        self.Entry1.focus_set()
        self.Entry1.selection_range(0, Tkinter.END)

    def CreateTableStat(self):
        """ Method creating the statistics table into the test  schema.
            - test first the connection.
            - when the connection is valid, create the table.
            - if the table exist, just truncate the table
        """    
        error_con = 0
        try:
            con = cx_Oracle.connect(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry3.get()))
        except cx_Oracle.DatabaseError:
            self.labelVariable.set (self.entryConnectStringVariable.get()+": Unable to connect!")
            error_con = 1
        
        if error_con != 1:
            cur = con.cursor()
            try:
                cur.execute('create table dwhstat (elapsed int)')
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 955:
                    cur.execute('truncate table dwhstat')
            cur.close()
            con.close()

    def DropTableStat(self):
        """ Procedure used to drop the statistics table.
            Not used so far.
        """    
        error_con = 0
        try:
            con = cx_Oracle.connect(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry3.get()))
        except cx_Oracle.DatabaseError:
            self.labelVariable.set (self.entryConnectStringVariable.get()+": Unable to connect!")
            error_con = 1
        
        if error_con != 1:
            cur = con.cursor()
            cur.execute('drop table dwhstat')
            cur.close()
            con.close()
            
    def test_SID(self,origin):
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
                con = cx_Oracle.connect(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry3.get()))
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 1017:
                    self.labelVariable.set (self.entryConnectStringVariable.get()+ \
                                            ": {0} Invalid username or password".format(str(self.Entry1.get())))
                    error_con = 1
                elif error.code == 12154:
                    self.labelVariable.set (self.entryConnectStringVariable.get()+": TNS couldn't resolve the SID")
                    error_con = 1
                elif error.code == 12543:
                    self.labelVariable.set (self.entryConnectStringVariable.get()+": Destination host not available")
                    error_con = 1
                else:
                    self.labelVariable.set (self.entryConnectStringVariable.get()+": Unable to connect")
                    error_con = 1
            
            if error_con != 1:
                cur = con.cursor()
                cur.execute('select * from global_name')
                for result in cur:
                    resultVar = str(result[0])
                    self.labelVariable.set ("{0}: {1}, Connection succesfull".format(resultVar, str(self.Entry1.get())))
                cur.close()
                con.close()
        elif origin == "System":
            try:
                con = cx_Oracle.connect("system", str(self.EntryPwdSys.get()), str(self.Entry3.get()))
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                if error.code == 1017:
                    self.labelVariable.set (self.entryConnectStringVariable.get()+": System invalid password")
                    #statWindow.VocableVariable.set(self.entryConnectStringVariable.get()+": Invalid username or password")
                    #messageretour = str(self.entryConnectStringVariable.get()+": Invalid username or password")
                    error_con = 1
                elif error.code == 12154:
                    self.labelVariable.set (self.entryConnectStringVariable.get()+": TNS couldn't resolve the SID")
                    error_con = 1
                elif error.code == 12543:
                    self.labelVariable.set (self.entryConnectStringVariable.get()+": Destination host not available")
                    error_con = 1
                else:
                    self.labelVariable.set (self.entryConnectStringVariable.get()+": System unable to connect")
                    error_con = 1
            
            if error_con != 1:
                cur = con.cursor()
                cur.execute('select * from global_name')
                for result in cur:
                    resultVar = str(result[0])
                    self.labelVariable.set ("{0}: System, connection succesfull".format(resultVar))
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
            con = cx_Oracle.connect(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry3.get()))
        except cx_Oracle.DatabaseError:
            self.labelVariable.set (self.entryConnectStringVariable.get()+": Unable to connect!")
            error_con = 1
        
        if error_con != 1:
            curRampUp = con.cursor()
            curRampUp.execute('select count(*) from dwhstat')
            for result in curRampUp:
                curExecTime = con.cursor()
                if int(result[0]) > 10:
                    curExecTime.execute('select (sum(elapsed))/10 from (select rownum r, elapsed from dwhstat) where r>(select max(rownum) - 10 from dwhstat)')
                    for result in curExecTime:
                        avgExecTime = str(int(result[0]))
                        self.LabelExecTimeVariable.set ('Avg completion: {0} S'.format(avgExecTime))
                else:
                    self.LabelExecTimeVariable.set ('Ramping up')
                curExecTime.close()
            curRampUp.close()
        con.close()


    def ExtendedStatistics(self):
        """ Advanced Statistics call method """
        statWindow = ExtendedStatistics (str(self.Entry3.get()), str(self.EntryPwdSys.get()))
        
        
if __name__ == "__main__":
    app = simpleapp_tk(None)
    app.title('DWH Workload Generator')
    app.mainloop()
    
    
