# # reciever
"""
Server receiver of the file
"""
import socket
import tqdm
import os
import numpy as np
import cv2

import time
from pynq import Overlay
from pynq import MMIO
LABELS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 
          'A', 'B', ('C', 'c') , 'D', 'E', 'F', 'G', 'H', ('I', 'i') , ('J', 'j') , ('K', 'k') , ('L', 'l') , ('M', 'm') , 
          'N', ('O', 'o') , ('P', 'p'), 'Q', 'R', ('S', 's') , 'T', ('U', 'u') , ('V', 'v') , ('W', 'w') , ('X', 'x') , 
          ('Y', 'y') , ('Z', 'z'), 'a', 'b', 'd', 'e', 'f', 'g', 'h', 'n', 'q', 'r', 't']

def extract_data():
    time.sleep(3)
    img = cv2.imread("./image.jpg")
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    list = []
    resize_img = cv2.resize(gray, (28,28))
    dst = 255 - resize_img
    # print(dst)
    arr_2d = np.pad(array=dst, pad_width=((2,2),(2,2)), mode='constant', constant_values=0)
    arr_2d = np.reshape(arr_2d, (1024, 1)) 
    np.savetxt("./temp.hex", arr_2d, delimiter ="",fmt ='% s')
    with open("./temp.hex", "r") as f :
        for j in f:
            list.append(int(j))
    l_i_hex1 = ['{:02x}'.format(l) for l in list]
    arr_2d = np.reshape(l_i_hex1, (256,4))
    np.savetxt("./image.hex", arr_2d, delimiter ="",fmt ='% s')
    
def pynq():
    design = Overlay("./Vivado/DLA.bit")
    cdma_address = design.ip_dict['axi_cdma_0']['phys_addr']
    axi_gpio_address0 = design.ip_dict['axi_gpio_0']['phys_addr'] # start
    axi_gpio_address1 = design.ip_dict['axi_gpio_1']['phys_addr'] # done
    axi_gpio_address2 = design.ip_dict['axi_gpio_2']['phys_addr'] # result
    axi_gpio_address3 = design.ip_dict['axi_gpio_3']['phys_addr'] # refresh



    global zynq_sys
    global cdma
    global gpio_a
    global gpio_b
    global gpio_c
    global gpio_d
    
    zynq_sys = MMIO(zynq_addr,    0xC000)
    cdma     = MMIO(cdma_address, 0xC000)
    gpio_a = MMIO(axi_gpio_address0,8)
    gpio_b = MMIO(axi_gpio_address1,8)
    gpio_c = MMIO(axi_gpio_address2,8)
    gpio_d = MMIO(axi_gpio_address3,8)
    
    gpio_a.write(0x4,0)
    gpio_b.write(0x4,0)
    gpio_c.write(0x4,0)
    gpio_d.write(0x4,0)

    print('start initial!\n')


    '''

    initial conv1 weight to bram2


    '''
    print('Weight1 initial!\n')

    bram2_offset = 0x0

    with open("out_conv1_32.hex", "r") as f_in:
        for line1 in f_in:
            if not line1:
                break
            zynq_sys.write(bram2_offset,int('0x'+line1,16))      
            bram2_offset += 4

    cdma.write(0x00,0x04)
    cdma.write(0x18,zynq_addr)
    cdma.write(0x20,bram2_addr)
    cdma.write(0x28,0x98) # 152 = 38 * 4

    '''

    initial conv2 weight to bram3


    '''
    print('Weight2 initial!\n')

    bram3_offset = 0x0

    with open("out_conv2_32.hex", "r") as f_in:
        for line1 in f_in:
            if not line1:
                break
            zynq_sys.write(bram3_offset,int('0x'+line1,16))      
            bram3_offset += 4

    cdma.write(0x00,0x04)
    cdma.write(0x18,zynq_addr)
    cdma.write(0x20,bram3_addr)
    cdma.write(0x28,0x960) # 2400 = 600 * 4


    '''

    initial conv3 weight to bram4


    '''
    print('Weight3 initial!\n')

    bram4_offset = 0x0

    with open("out_conv3_32.hex", "r") as f_in:
        for line1 in f_in:
            if not line1:
                break
            zynq_sys.write(bram4_offset,int('0x'+line1,16))      
            bram4_offset += 4

    cdma.write(0x00,0x04)
    cdma.write(0x18,zynq_addr)
    cdma.write(0x20,bram4_addr)
    cdma.write(0x28,0xBB80) # 48000 = 12000 * 4

    '''

    initial fc1 weight to bram5


    '''
    print('Weight4 initial!\n')

    bram5_offset = 0x0

    with open("out_fc1_32.hex", "r") as f_in:
        for line1 in f_in:
            if not line1:
                break
            zynq_sys.write(bram5_offset,int('0x'+line1,16))      
            bram5_offset += 4

    cdma.write(0x00,0x04)
    cdma.write(0x18,zynq_addr)
    cdma.write(0x20,bram5_addr)
    cdma.write(0x28,0x2760) # 10080 = 2520 * 4

    '''

    initial fc2 weight to bram6


    '''
    print('Weight5 initial!\n')

    bram6_offset = 0x0

    with open("out_fc2_32.hex", "r") as f_in:
        for line1 in f_in:
            if not line1:
                break
            zynq_sys.write(bram6_offset,int('0x'+line1,16))      
            bram6_offset += 4

    cdma.write(0x00,0x04)
    cdma.write(0x18,zynq_addr)
    cdma.write(0x20,bram6_addr)
    cdma.write(0x28,0xF6C) # 2268 = 567 * 4
    


    print('initial finish!\n')
def load_if():
    print('Input feature map initial!\n')
    bram0_offset = 0x0
    time.sleep(2)
    with open("image.hex", "r") as f_in:
        for line1 in f_in:
            if not line1:
                break
            zynq_sys.write(bram0_offset,int('0x'+line1,16))      
            bram0_offset += 4

    cdma.write(0x00,0x04) #start
    cdma.write(0x18,zynq_addr)
    cdma.write(0x20,bram0_addr)
    cdma.write(0x28,0x400) # 1024
    
def main():
    start_time = time.time()
    gpio_a.write(0,1) # write 1 to start
    gpio_a.write(0,0)
    while gpio_b.read() == 0:
        pass
    softmax_int = gpio_c.read()
    print("--- %s seconds ---" % (time.time() - start_time))
    gpio_d.write(0,1)
    gpio_d.write(0,0)
#     print("Inference value: ", LABELS[softmax_int])
    if type(LABELS[softmax_int]) == tuple:
        print("inference value:", LABELS[softmax_int][0], " or ", LABELS[softmax_int][1])
    else:
        print("inference value:", LABELS[softmax_int])
    print('all finish!')

def sckt():
    # device's IP address
    SERVER_HOST = "0.0.0.0"
    SERVER_PORT = 5001
    # receive 4096 bytes each time
    BUFFER_SIZE = 4096
    SEPARATOR = "<SEPARATOR>"
    # create the server socket
    # TCP socket
    s = socket.socket()
    # bind the socket to our local address
    s.bind((SERVER_HOST, SERVER_PORT))
    # enabling our server to accept connections
    # 5 here is the number of unaccepted connections that
    # the system will allow before refusing new connections
    s.listen(5)
    print(f"[*] Listening as {SERVER_HOST}:{SERVER_PORT}")
    # accept connection if there is any
    client_socket, address = s.accept() 
    # if below code is executed, that means the sender is connected
    print(f"[+] {address} is connected.")

    # receive the file infos
    # receive using client socket, not server socket
    received = client_socket.recv(BUFFER_SIZE).decode()
    filename, filesize = received.split(SEPARATOR)
    # remove absolute path if there is
    filename = os.path.basename(filename)
    # convert to integer
    filesize = int(filesize)
    # start receiving the file from the socket
    # and writing to the file stream
    progress = tqdm.tqdm(range(filesize), f"Receiving {filename}", unit="B", unit_scale=True, unit_divisor=1024)
    with open(filename, "wb") as f:
        while True:
            # read 1024 bytes from the socket (receive)
            bytes_read = client_socket.recv(BUFFER_SIZE)
            if not bytes_read:    
                # nothing is received
                # file transmitting is done
                break
            # write to the file the bytes we just received
            f.write(bytes_read)
            # update the progress bar
            progress.update(len(bytes_read))

    # close the client socket
    client_socket.close()
    # close the server socket
    s.close()
    
if __name__ == "__main__":
    zynq_addr  = 0x30000000
    bram0_addr = 0xC0000000 # if1
    bram1_addr = 0xC2000000 # if2
    bram2_addr = 0xC4000000 # w1
    bram3_addr = 0xC6000000 # w2
    bram4_addr = 0xC8000000 # w3
    bram5_addr = 0xCA000000 # w4
    bram6_addr = 0xCC000000 # w5
    pynq()
    while 1:
        sckt()
        extract_data()
        load_if()
        main()
