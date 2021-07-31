## Weight arrangement methodology

* **Layer 1 :** 
    - `5(w)*5(h)*1(c)*6(n)` 
    - width-wise -> height-wise -> batch-wise -> channel-wise
* **Layer 2 :** 
    - `5(w)*5(h)*6(c)*16(n)` 
    - width-wise -> height-wise -> batch-wise -> channel-wise
* **Layer 3 :** 
    - `5(w)*5(h)*16(c)*120(n)` 
    - width-wise -> height-wise -> batch-wise -> channel-wise
