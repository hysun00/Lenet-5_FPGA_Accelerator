
# coding: utf-8

# In[3]:


from pynq import Overlay
from pynq import MMIO
import time
design = Overlay("./cnn.bit")

cdma_address = design.ip_dict['axi_cdma_0']['phys_addr']
axi_gpio_address0 = design.ip_dict['axi_gpio_0']['phys_addr'] # start
axi_gpio_address1 = design.ip_dict['axi_gpio_1']['phys_addr'] # done
zynq_addr = 0x30000000


bram0_addr = 0xC0000000 # if1
bram1_addr = 0xC2000000 # w1
bram2_addr = 0xC4000000 # w2
bram3_addr = 0xC6000000 # if2

zynq_sys = MMIO(zynq_addr,0x1500)
cdma = MMIO(cdma_address, 0x1500)

'''

initial input file to bram0
    
    
'''
print('start initial!\n')
print('Input feature map initial!\n')
bram0_offset = 0x0

with open("number_conv1_32_in.hex", "r") as f_in:
    for line1 in f_in:
        if not line1:
            break
        zynq_sys.write(bram0_offset,int('0x'+line1,16))      
        bram0_offset += 4
       
cdma.write(0x00,0x04) #start
cdma.write(0x18,zynq_addr)
cdma.write(0x20,bram0_addr)
cdma.write(0x28,0x400)



'''

initial conv1 weight to bram1
    
    
'''
print('Weight initial!\n')

bram1_offset = 0x0

with open("number_conv1_32.hex", "r") as f_in:
    for line1 in f_in:
        if not line1:
            break
        zynq_sys.write(bram1_offset,int('0x'+line1,16))      
        bram1_offset += 4

cdma.write(0x00,0x04)
cdma.write(0x18,zynq_addr)
cdma.write(0x20,bram1_addr)
cdma.write(0x28,0x98)

'''

initial conv2 weight to bram2
    
    
'''
print('Weight initial!\n')

bram2_offset = 0x0

with open("number_conv2_32.hex", "r") as f_in:
    for line1 in f_in:
        if not line1:
            break
        zynq_sys.write(bram2_offset,int('0x'+line1,16))      
        bram2_offset += 4

cdma.write(0x00,0x04)
cdma.write(0x18,zynq_addr)
cdma.write(0x20,bram2_addr)
cdma.write(0x28,0x960)


print('initial finish!\n')

'''


 write '1' into AXI_GPIO for start!
 
 
''' 

gpio_a = MMIO(axi_gpio_address0,8)
gpio_b = MMIO(axi_gpio_address1,8)
print("done = ", hex(gpio_b.read()))
gpio_a.write(0x4,0)
start_time = time.time()
gpio_a.write(0,1) # write 1 to start

         
if gpio_b.read() == 0xffffffff:
    print("--- %s seconds ---" % (time.time() - start_time))
    
    
bram3_offset = 0x0

cdma.write(0x0,0x04)
cdma.write(0x18,bram0_addr)
cdma.write(0x20,zynq_addr)
cdma.write(0x28,0x190) # conv1: 498 = 14 * 14 * 6


print("done = ", hex(gpio_b.read()))
with open('cnn_output_number.hex', 'w') as f_out:
    while bram3_offset<100*4:   # conv1: 294
        ans = str(hex(zynq_sys.read(bram3_offset)))[2:]
        if len(ans)!=8:    # 補 0 
            ans = '0'*(8-len(ans))+ans
        f_out.write(ans+'\n')
        bram3_offset += 4


        
print('all finish!')

