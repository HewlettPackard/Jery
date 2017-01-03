#!/usr/local/bin/python3
#-*- coding: iso-8859-1 -*-

import tkinter
from tkinter import *
import cx_Oracle
#from threading import Thread
import threading


class OraLoadThread(threading.Thread):
    def __init__(self, OraUser, OraPwd,OraConnect):
    #def __init__(self):
        threading.Thread.__init__(self)
        self.OraUser = OraUser
        self.OraPwd = OraPwd
        self.OraConnect = OraConnect
        
    #def run(self, OraUser, OraPwd, OraConnect):
    def run(self):    
        error_con = 0
        try:
            con = cx_Oracle.connect(self.OraUser, self.OraPwd, self.OraConnect)
        except cx_Oracle.DatabaseError:
            error_con = 1
            return error_con
        
        if error_con != 1:
            cur = con.cursor()
            cur.execute('select e1.ename, min(e2.deptno), max(e2.deptno), avg(to_number(to_char(e2.sal))), \
                        avg(e2.comm), max(to_number(to_char(e2.comm))) from emp2 e2, emp e1 \
                        where e1.ename=e2.ename group by e1.ename')
            #for result in cur:
            #     self.labelVariable.set (result)
            cur.close()
            con.close()


class simpleapp_tk(tkinter.Tk):
    def __init__(self,parent):
        tkinter.Tk.__init__(self,parent)
        self.parent = parent
        self.initialize()

    def initialize(self):
        self.grid()

        can1 = Canvas(self, width = 80, height = 80, bg='white')
        self.logohp = PhotoImage(file='/usr/yann/dwh2/HP_round4.gif')
        item = can1.create_image(40,40, image=self.logohp)
        can1.grid(column=1, row=7, rowspan = 5, padx=5, pady=15)

        can2 = Canvas(self, width = 500, height=20)
        can2.grid(column=0, row=3, columnspan=3, padx=10, pady=10)
        can2.create_line (10,10,490,10,width=2,fill='gray')

        self.Label1 = tkinter.Label(self, text='Test schema owner')
        self.Label1.grid (column=0, row=0, sticky = W)
        self.Label2 = tkinter.Label(self, text='Test schema password')
        self.Label2.grid (column=1, row=0, sticky = W)
        self.Label3 = tkinter.Label(self, text='Connect string')
        self.Label3.grid (column=2, row=0, sticky = W)
        self.Label4 = tkinter.Label(self, text='Select the number of virtual users')
        self.Label4.grid (column=0, row=4, columnspan=3)


        self.entryUserVariable = tkinter.StringVar()
        self.Entry1 = tkinter.Entry(self, textvariable=self.entryUserVariable)
        self.Entry1.grid (column=0, row=1, sticky='EW')
        self.Entry1.bind('<Return>', self.OnPressEnter)
        self.entryUserVariable.set(u"SCOTT")

        self.entryPwdVariable = tkinter.StringVar()
        self.Entry2 = tkinter.Entry(self, textvariable=self.entryPwdVariable, show="*", width=15)
        self.Entry2.grid (column=1, row=1, sticky='EW')
        self.Entry2.bind('<Return>', self.OnPressEnter)
        self.entryPwdVariable.set(u"tiger")

        self.entryConnectStringVariable = tkinter.StringVar()
        self.Entry3 = tkinter.Entry(self, textvariable=self.entryConnectStringVariable)
        self.Entry3.grid (column=2, row=1, sticky='EW')
        self.Entry3.bind('<Return>', self.OnPressEnter)
        self.entryConnectStringVariable.set(u"DWH")

        self.entryConUsersVariable = tkinter.IntVar()
        self.EntryConUsers = tkinter.Entry(self, textvariable=self.entryConUsersVariable)
        self.EntryConUsers.grid (column=1, row=6, sticky='EW')
        self.EntryConUsers.bind('<Return>', self.OnPressEnter)
        self.entryConUsersVariable.set (4)


        buttonLess = tkinter.Button(self,text=u"-", command=self.OnButtonLessClick, width=10)
        buttonLess.grid(column=0, row=6, sticky=E)

        buttonMore = tkinter.Button(self,text=u"+", command=self.OnButtonMoreClick, width=10)
        buttonMore.grid(column=2, row=6, sticky=W)
        
        buttonTest = tkinter.Button(self,text=u"Check Connection!", command=self.OnButtonClick)
        buttonTest.grid(column=2, row=2, columnspan=2)

        buttonStartLoad = tkinter.Button(self,text=u"Start the load", command=self.OnButtonStartLoadClick)
        buttonStartLoad.grid(column=0, row=7, sticky=S)

        buttonStopLoad = tkinter.Button(self,text=u"Stop the load", command=self.OnButtonStopLoadClick)
        buttonStopLoad.grid(column=0, row=8, sticky=S)

        buttonQuit = tkinter.Button(self,text=u"Quit Application", command=self.destroy)
        buttonQuit.grid (column=2, row=7, sticky=S)


        self.labelVariable = tkinter.StringVar()
        label = tkinter.Label(self,textvariable=self.labelVariable,
                              anchor="w", fg="white", bg="blue")
        label.grid(column=0, row=2, columnspan=2, sticky='EW')
        self.labelVariable.set(u"Hello !")

        self.grid_columnconfigure(0,weight=1)
        self.resizable(True,False)
        self.update()
        self.geometry(self.geometry())
        self.Entry1.focus_set()
        self.Entry1.selection_range(0, tkinter.END)

        
    def OnButtonLessClick(self):
        ConcUsers = int(self.EntryConUsers.get ())
        ConcUsers -= 1
        self.entryConUsersVariable.set(ConcUsers)
        
    def OnButtonMoreClick(self):
        ConcUsers = int(self.EntryConUsers.get ())
        ConcUsers += 1
        self.entryConUsersVariable.set(ConcUsers)

    def OnButtonClick(self):
        self.test_SID()
        self.Entry1.focus_set()
        self.Entry1.selection_range(0, tkinter.END)

    def OnButtonStopLoadClick(self):
        self.loadRun = 1
        self.labelVariable.set (u"The workload will end shortly!")

    def OnButtonStartLoadClick(self):
        #self.loadRun = 0
        #error_con = 0
        #try:
        #    con = cx_Oracle.connect(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry3.get()))
        #except cx_Oracle.DatabaseError:
        #    self.labelVariable.set (self.entryConnectStringVariable.get()+": Unable to connect!")
        #    error_con = 1
        
        #if error_con != 1:
        #    cur = con.cursor()
        #    cur.execute('select count(*) from V$session where username like 'SCOTT"')
#            for result in cur:
                #version_DB['text'] = result
#                self.labelVariable.set (result)
#            cur.close()
#            con.close()
        #while self.loadRun == 0:
            
        for i in range(int(self.EntryConUsers.get ())):
            #my_thread = OraLoadThread()
            my_thread = OraLoadThread(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry3.get()))
            my_thread.name = i
            #my_thread.run(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry3.get()))
            #thread_return = my_thread.start()
            my_thread.start()
            self.labelVariable.set ("Number of Thread: "+str(threading.activeCount()))
            #if thread_return == 1:
            #    self.labelVariable.set (self.entryConnectStringVariable.get()+": Unable to connect!")
         
         #        error_con = 0
#        try:
#            con = cx_Oracle.connect(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry3.get()))
#        except cx_Oracle.DatabaseError:
#            self.labelVariable.set (self.entryConnectStringVariable.get()+": Unable to connect!")
#            error_con = 1
        
#        if error_con != 1:
#            cur = con.cursor()
#            cur.execute('select e1.ename, min(e2.deptno), max(e2.deptno), avg(to_number(to_char(e2.sal))), \
#                        avg(e2.comm), max(to_number(to_char(e2.comm))) from emp2 e2, emp e1 \
#                        where e1.ename=e2.ename group by e1.ename')
#            for result in cur:
                #version_DB['text'] = result
#                self.labelVariable.set (result)
#            cur.close()
#            con.close()
        self.labelVariable.set ("Number of Thread: "+my_thread.activeCount())

    def OnPressEnter(self,event):
        self.labelVariable.set (self.entryUserVariable.get()+" You pressed Enter!")
        self.Entry1.focus_set()
        self.Entry1.selection_range(0, tkinter.END)

    def test_SID(self):
        #dsn_tns = cx_Oracle.makedsn('15.136.28.39', 1526, SID)
        #dsn_tns = ('scott/tiger@' + str(self.Entry3.get()))
        #version_DB['text'] = str(self.Entry3.get())
        error_con = 0
        try:
            con = cx_Oracle.connect(str(self.Entry1.get()), str(self.Entry2.get()), str(self.Entry3.get()))
        except cx_Oracle.DatabaseError:
            self.labelVariable.set (self.entryConnectStringVariable.get()+": Unable to connect!")
            error_con = 1
        
        if error_con != 1:
            cur = con.cursor()
            cur.execute('select * from global_name')
            for result in cur:
                #version_DB['text'] = result
                self.labelVariable.set (result)
            cur.close()
            con.close()
        
    
    def repondre():
        affichage['text'] = SID.get()

if __name__ == "__main__":
    app = simpleapp_tk(None)
    app.title('DWH Workload Generator')
    app.mainloop()
    
