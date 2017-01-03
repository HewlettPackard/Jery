#!/usr/local/bin/python3

import tkinter
from tkinter import *
import time
import cx_Oracle

def test_SID():
        #dsn_tns = cx_Oracle.makedsn('15.136.28.39', 1526, SID)
        dsn_tns = ('scott/tiger@' + str(SID))
        version_DB['text'] = str(SID.get())
        error_con = 0
        try:
            con = cx_Oracle.connect('scott', 'tiger', str(SID.get()))
        except cx_Oracle.DatabaseError:
            version_DB['text'] = "unknown SID..."
            error_con = 1
        
        if error_con != 1:
            cur = con.cursor()
            cur.execute('select * from global_name')
            for result in cur:
                version_DB['text'] = result
            cur.close()
            con.close()
        
    
def repondre():
        affichage['text'] = SID.get()
        
root = Tk()
root.title('DWH Workload Generator')

Label(text='Enter the Oracle SID:').pack(side=TOP,padx=10,pady=10)
SID=Entry(root)

version_DB = Label(root, width=30)
affichage = Label(root, width=30)

votre_SID=Label(root, text='The database name is: ')
Button(root, text='Print', command=repondre).pack(side=LEFT)
Button(root, text='Test SID', command=test_SID).pack(side=LEFT)
Button(root, text='Quit', command=root.destroy).pack(side=RIGHT)
SID.pack(expand=tkinter.YES, fill=tkinter.X)
votre_SID.pack()
version_DB.pack()       
affichage.pack()
root.mainloop()
