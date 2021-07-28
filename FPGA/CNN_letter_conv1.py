
# coding: utf-8

# In[3]:


from pynq import Overlay
from pynq import MMIO

design = Overlay("./DLA.bit")

cdma_address = design.ip_dict['axi_cdma_0']['phys_addr']
axi_gpio_address0 = design.ip_dict['axi_gpio_0']['phys_addr'] # start
axi_gpio_address1 = design.ip_dict['axi_gpio_1']['phys_addr'] # done
zynq_addr = 0x30000000


bram0_addr = 0xC0000000 # if
bram1_addr = 0xC2000000 # w
bram2_addr = 0xC4000000 # temp

zynq_sys = MMIO(zynq_addr,0x1500)
cdma = MMIO(cdma_address, 0x1500)

'''

initial input file to bram0
    
    
'''
print('start initial!\n')
print('Input feature map initial!\n')
bram0_offset = 0x0

with open("letter_conv1_32_in.hex", "r") as f_in:
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

initial input weight to bram1
    
    
'''
print('Weight initial!\n')

bram1_offset = 0x0

with open("letter_conv1_32_w.hex", "r") as f_in:
    for line1 in f_in:
        if not line1:
            break
        zynq_sys.write(bram1_offset,int('0x'+line1,16))      
        bram1_offset += 4

cdma.write(0x00,0x04)
cdma.write(0x18,zynq_addr)
cdma.write(0x20,bram1_addr)
cdma.write(0x28,0x98)



print('initial finish!\n')

'''


 write '1' into AXI_GPIO for start!
 
 
''' 
count=0
gpio_b = MMIO(axi_gpio_address1,8)
print("done = ", hex(gpio_b.read()))
gpio_a = MMIO(axi_gpio_address0,8)
gpio_a.write(0x4,0)
gpio_a.write(0,1) # write 1 to start

         

bram2_offset = 0x0

cdma.write(0x0,0x04)
cdma.write(0x18,bram2_addr)
cdma.write(0x20,zynq_addr)
cdma.write(0x28,0x498)


print("done = ", hex(gpio_b.read()))
with open('cnn_output_letter.hex', 'w') as f_out:
    while bram2_offset<294*4:   
        ans = str(hex(zynq_sys.read(bram2_offset)))[2:]
        if len(ans)!=8:    # 補 0 
            ans = '0'*(8-len(ans))+ans
        f_out.write(ans+'\n')
        bram2_offset += 4


        
print('all finish!')

