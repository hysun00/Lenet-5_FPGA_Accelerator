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
<img src="/Image/DLA_architecture.jpg"/>

> **Two** feature BRAMs for **ifmp/ofmp** storage & **Five** weight BRAMs for **layer 1~5** weight storage.

<img src="/Image/PE_architecture.png"/>




## PYNQ-Z2 board
### Utilization
|Resource              |Utilization  |Avaliable    |Utilization % |
|  -----               | -----       | -----       | -----        |
|LUT     	           |38690        |53200        |72.73         |
|LUTRAM                |1883         |17400        |10.82         |
|FF                    |43396        |106400       |40.79         |
|BRAM   	           |30           |140          |21.43         |
|DSP                   |200          |220          |90.91         |
|BUFG                  |2            |32           |6.25          |


### Power
|   	           |Total On-Chip Power(W)   |Dynamic Power(W)  |Device Static Power(W)    % |
|  -----           | -----                   | -----            | -----                      |
|Software          |1.733                    |1.587             |0.145                       |


## Performance
|   	           |Accuracy(%)   |Average Inference time   |FPS       % |
|  -----           | -----        | -----                   | -----      |
|Software          |85.8          |80.86                    |12          |
|Hardware          |85.6          |0.50                     |1991        |

## Issue


## References
* [1] https://github.com/ChrisZonghaoLi/Rudi_CNN_Conv_Accelerator
* [2] https://github.com/eecheng87/Convolution
* [3] https://github.com/WeiCheng14159/MNIST_accelerator
* [4] https://github.com/x4nth055/pythoncode-tutorials/tree/master/general/transfer-files
* [5] https://github.com/syshen/mnist-cnn/blob/master/mnist-CNN.ipynb
* [6] NCKU Courses:
    - AI-ON-CHIP FOR MACHINE LEARNING AND INFERENCE -- Lectured by Professor Chen Chung-Ho
    - DEEP LEARNING INTEGRATED CIRCUIT DESIGN AND ACCELERATION -- Lectured by Professor Lin Ing-Chao
* [7]	Y. Lecun, L. Bottou, Y. Bengio and P. Haffner, "Gradient-based learning applied to document recognition," in Proceedings of the IEEE, vol. 86, no. 11, pp. 2278-2324, Nov. 1998.
* [8]	Y.-H. Chen, T. Krishna, J. Emer, and V. Sze, “Eyeriss: An energy-efficient reconfigurable accelerator for deep convolutional neural networks,” IEEE J. Solid-State Circuits, vol. 51, no. 1, pp. 127–138, Jan. 2017.
* [9] 	V. Sze, Y. Chen, T. Yang and J. S. Emer, "Efficient Processing of Deep Neural Networks: A Tutorial and Survey," in Proceedings of the IEEE, vol. 105, no. 12, pp. 2295-2329, Dec. 2017.
* [10] 	Amir Gholami, Sehoon Kim, Zhen Dong, Zhewei Yao, Michael W. Mahoney, Kurt Keutzer, "A Survey of Quantization Methods for Efficient Neural Network Inference", University of California, Berkeley,  Jun. 2021. 
* [11] 	Gregory Cohen, Saeed Afshar, Jonathan Tapson, André van Schaik, ''EMNIST: an extension of MNIST to handwritten letters'', The MARCS Institute for Brain, Behaviour and Development Western Sydney University,  Mar. 2017.

