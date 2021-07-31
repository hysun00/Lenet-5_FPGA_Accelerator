## Kernel arrangement methodology

|Parameter |Description  |
|  -----   | -----       |
|W         |Width        |
|H         |Height       |
|C         |Channel      |
|N         |Batch        |

> Four data in one row

* **Layer 1 :** 
    - `5(W)*5(H)*1(C)*6(N)` 
    - width-wise -> height-wise -> batch-wise -> channel-wise
* **Layer 2 :** 
    - `5(W)*5(H)*6(C)*16(N)` 
    - width-wise -> height-wise -> batch-wise -> channel-wise
* **Layer 3 :** 
    - `5(W)*5(H)*16(C)*120(N)` 
    - width-wise -> height-wise -> batch-wise -> channel-wise
* **Layer 4 :** 
    - `120(W)*84(H)` 
    - width-wise -> height-wise
* **Layer 5 :** 
    - `84(W)*10(H)` or `84(W)*27(H)`
    - width-wise -> height-wise
