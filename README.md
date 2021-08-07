FPGA-Based Neural Network Acceleration for Handwritten Digits & Alphabets Recognition 
=========================
This repository is about our undergraduate graduation project from NCKUEE, implementing LeNet-5 by using Vivado and PYNQ-Z2

## Contributors:
* `Jack` from NCKUEE
* `Charley` from NCKUES
## Tools:
* `PYNQ-Z2`
* `Vivado`
* `Jupyter notebook`
## Programming language:
* `Verilog`
* `Python`

## Demo:
<img src="/Image/demo.gif"/>

## Running:
* In localhost:
```
    python3 main.py
```
* In pynq terminal:
```
    sudo python3 server.py
```

> NOTE: You should execute server.py first or you will get connection error and you should change path of Overlay to where you put your bitstream file

## Lenet-5 Architecture
<img src="/Image/Lenet-5_architecture.png"/>

<img src="/Image/Lenet-5.png"/>

> In layer 5, there are 27 nodes for alphabets recognition.

## Data format
* Input image : 8 bits integer
* Weight : 1 bits integer and 7 bits fraction

## DLA Architecture
<img src="/Image/DLA_architecture.png"/>
<img src="/Image/PE_architecture.png"/>


## PYNQ-Z2 board
### Utilization
|Resource              |Utilization  |Avaliable    |Utilization % |
|  -----               | -----       | -----       | -----        |
|LUT     	           |37972        |53200        |71.38         |
|LUTRAM                |1883         |17400        |10.82         |
|FF                    |42834        |106400       |40.26         |
|BRAM   	           |30           |140          |21.43         |
|DSP                   |200          |220          |90.91         |
|BUFG                  |2            |32           |6.25          |

<img src="/Image/Utilization_graph.png" height="50%" width="50%"/>

### Power
<img src="/Image/power.png"/>

## Performance
### Accuracy:
        Number recognition accuracy: 98.34 %
        Letter recognition accuracy: 93.14 %
> From DLA_Accuracy_test.ipynb
### FPS:
        Clock rate: 70 MHz
        FPS: 805.64

## 

## References:
* [1] https://github.com/ChrisZonghaoLi/Rudi_CNN_Conv_Accelerator
* [2] https://github.com/eecheng87/Convolution
* [3] https://github.com/WeiCheng14159/MNIST_accelerator
* [4] NCKU Courses:
    - AI-ON-CHIP FOR MACHINE LEARNING AND INFERENCE -- Lectured by Professor Chen Chung-Ho
    - DEEP LEARNING INTEGRATED CIRCUIT DESIGN AND ACCELERATION -- Lectured by Professor Lin Ing-Chao
* [5] LeCun, Yann  (1998), "Gradient-Based Learning Applied to Document Recognition"
* [6] Dai Rongshi  (2019), "Accelerator Implementation of Lenet-5 Convolution Neural Network Based on FPGA with HLS"
* [7] Yu-Hsin Chen (2017), "Eyeriss: An Energy-Efficient Reconfigurable Accelerator for Deep Convolutional Neural Networks"
* [8] Vivienne Sze, Yu-Hsin Chen, Tien-Ju Yang, Joel S. Emer (2017), "Efficient Processing of Deep Neural Networks: A Tutorial and Survey"
* [9] David Gschwend (2016), "ZynqNet: An FPGA-Accelerated Embedded Convolutional Neural Network"
