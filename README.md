FPGA-Based Neural Network Acceleration for Handwritten Digits & Alphabets Recognition 
=========================
This repository is about our undergraduate graduation project from NCKUEE, implementing LeNet-5 by using Vivado and PYNQ-Z2

## Contributors
* `Jack` from **NCKU EE**
* `Charley` from **NCKU ES**
## Tools
* `PYNQ-Z2`
* `Vivado`
* `Jupyter notebook`
## Programming language
* `Verilog`
* `Python`

## Demo
<img src="/Image/demo.gif"/>

## Usage
* Dependency :
```
    pip install -r requirements.txt
``` 

* In localhost (Win10) :
```
    python main.py
```
* In pynq terminal :
```
    sudo python3 server.py
```

> **NOTE :** You should execute server.py first or you will get connection error and you should change the path of Overlay to where you put your bitstream file.

## Lenet-5 Architecture
<img src="/Image/Lenet-5_architecture.png"/>

<img src="/Image/Lenet-5.png"/>

> In layer 5, there are 27 nodes for alphabets recognition.

## Data format
* Input image : 8 bits integer
* Weight : 1 bits integer and 7 bits fraction

## DLA Architecture
<img src="/Image/DLA_architecture.png"/>

> **Two** feature BRAMs for **ifmp/ofmp** storage & **Five** weight BRAMs for **layer 1~5** weight storage.

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

<img src="/Image/Utilization_graph.png"/>

### Power
<img src="/Image/power.png"/>

## Performance
### Accuracy
        Number recognition accuracy: 98.34 %
        Letter recognition accuracy: 93.14 %
> From DLA_Accuracy_test.ipynb
### FPS
        Clock rate: 70 MHz
        FPS: 805.64


## References
* [1] https://github.com/ChrisZonghaoLi/Rudi_CNN_Conv_Accelerator
* [2] https://github.com/eecheng87/Convolution
* [3] https://github.com/WeiCheng14159/MNIST_accelerator
* [4] https://github.com/x4nth055/pythoncode-tutorials/tree/master/general/transfer-files
* [5] NCKU Courses:
    - AI-ON-CHIP FOR MACHINE LEARNING AND INFERENCE -- Lectured by Professor Chen Chung-Ho
    - DEEP LEARNING INTEGRATED CIRCUIT DESIGN AND ACCELERATION -- Lectured by Professor Lin Ing-Chao
* [6] LeCun, Yann  (1998), "Gradient-Based Learning Applied to Document Recognition"
* [7] Dai Rongshi  (2019), "Accelerator Implementation of Lenet-5 Convolution Neural Network Based on FPGA with HLS"
* [8] Yu-Hsin Chen (2017), "Eyeriss: An Energy-Efficient Reconfigurable Accelerator for Deep Convolutional Neural Networks"
* [9] Vivienne Sze, Yu-Hsin Chen, Tien-Ju Yang, Joel S. Emer (2017), "Efficient Processing of Deep Neural Networks: A Tutorial and Survey"
* [10] David Gschwend (2016), "ZynqNet: An FPGA-Accelerated Embedded Convolutional Neural Network"
