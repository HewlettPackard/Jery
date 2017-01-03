# -*- coding: ISO-8859-1 -*-
import Tkinter as Tk
       
class InfoBulle(Tk.Toplevel):
    def __init__(self, parent=None, texte='', temps=1000):
        Tk.Toplevel.__init__(self, parent, bd=1, bg='black')
        self.tps = temps
        self.parent = parent
        self.withdraw()
        self.overrideredirect(1)  ## permet que la fenêtre n'est pas de bord
        self.transient()     
        l = Tk.Label(self, text=texte, bg="yellow", justify='left')
        l.update_idletasks()
        l.pack()
        l.update_idletasks()
        self.tipwidth = l.winfo_width()
        self.tipheight = l.winfo_height()
        self.parent.bind('<Enter>', self.delai)
        self.parent.bind('<Button-1>', self.efface)
        self.parent.bind('<Leave>', self.efface)
        
    ## On attend self.tps avant d'afficher l'infobulle
    def delai(self,event):
        self.action = self.parent.after(self.tps, self.affiche)

    ## Affichage de l'infobulle       
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

    ## On cache l'infobulle ou on annulle son affichage   
    def efface(self,event):
        self.withdraw()
        self.parent.after_cancel(self.action)
 
if __name__ == '__main__':
    root = Tk.Tk()
    root.title("Exemple de création d'une classe InfoBulle")
    lab1 = Tk.Label(root, text='Infobulle 1')
    lab1.pack()
    lab2 = Tk.Label(root, text='Infobulle 2')
    lab2.pack()
    i1 = InfoBulle(parent=lab1, texte="Infobulle 1")
    i2 = InfoBulle(parent=lab2, texte="Infobulle 2")
    root.mainloop()
