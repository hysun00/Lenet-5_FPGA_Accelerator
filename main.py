from tkinter import *
from tkinter.filedialog import asksaveasfilename as saveAs
import PIL
from PIL import Image, ImageDraw
import socket
import tqdm
import os

SEPARATOR = "<SEPARATOR>"
BUFFER_SIZE = 1024 * 4 # 4KB

def activate_paint(e):
    global lastx, lasty
    cv.bind('<B1-Motion>', paint)
    lastx, lasty = e.x, e.y

def paint(e):
    global lastx, lasty
    x, y = e.x, e.y
    cv.create_line((lastx, lasty, x, y), width=20)
    draw.line((lastx, lasty, x, y), fill='black', width=20)
    lastx, lasty = x, y

def clear():
    cv.delete('all')
    draw.rectangle((0, 0, 250, 250), fill="white")
    
def exitt():
    exit()

def start():
    filename = "image.jpg"
    image1.save(filename)
    host = "192.168.1.103" # Before executing, you should check your pynq ip by typing "ifconfig" on pynq terminal, and copy the "eth0: inet 192.168.1.X"
    port = 5001
    filesize = os.path.getsize(filename) # get the file size
    # create the client socket
    s = socket.socket()
    print(f"[+] Connecting to {host}:{port}")
    s.connect((host, port))
    print("[+] Connected.")

    s.send(f"{filename}{SEPARATOR}{filesize}".encode()) # send the filename and filesize
    progress = tqdm.tqdm(range(filesize), f"Sending {filename}", unit="B", unit_scale=True, unit_divisor=1024) # start sending the file
    with open(filename, "rb") as f:
        while True:
            bytes_read = f.read(BUFFER_SIZE) # read the bytes from the file
            if not bytes_read:  # file transmitting is done
                break
            s.sendall(bytes_read) # use sendall to assure transimission in busy networks
            progress.update(len(bytes_read)) # update the progress bar
    s.close() # close the socket
    

# GUI
win = Tk()
win.title("Hand-written recognition system")
win.resizable(0,0) # cancel the maximize button
win.iconbitmap('./Image/paint.ico') # Delete this line if you don't have file "Paint.ico" in this folder
lastx, lasty = None, None

cv = Canvas(win, width=250, height=250, bg='white')
image1 = PIL.Image.new('RGB', (250, 250), 'white')
draw = ImageDraw.Draw(image1)

cv.bind('<1>', activate_paint)
cv.pack(expand=YES, fill=BOTH)

# button setup
start = Button(text="Start", command=start)
start.place(relx=.5, rely=.955, anchor="center")

reset=Button(text='Reset',command=clear)
reset.pack(side=LEFT)

_exit=Button(text='Exit',command=exitt)
_exit.pack(side=RIGHT)

win.mainloop()