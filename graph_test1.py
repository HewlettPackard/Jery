import Tkinter as tk

data = [40, 15, 10, 7, 5, 3, 2, 1, 1, 0, 15, 14, 12, 17, 18, 15, 13, 11, 10, 9]
root = tk.Tk()
c_width = 420
c_height = 600
c = tk.Canvas(root, width=c_width, height=c_height, bg='white')

c.pack()

y_stretch = 15
y_gap = 20
x_stretch = 10
x_width = 20
x_gap = 20

for x, y in enumerate(data):
#for x in enumerate(data):
    #x0 = x * x_stretch + x_width + x_gap
    x0 = x * 20 +10
    y0 = c_height - (y * y_stretch + y_gap)
    #y0 = c_height - (x * y_stretch + y_gap)
    
    #x1 = x * x_stretch + x * x_width + x_width + x_gap
    x1 = x * 20 +25
    y1 = c_height - y_gap
    
    c.create_rectangle (x0, y0, x1, y1, fill="red")
    c.create_text (x0+2, y0, anchor=tk.SW, text=str(y))
    #c.create_text (x0+2, y0, anchor=tk.SW, text=str(x))

root.mainloop()    
