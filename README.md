# FPGA
There is a Minesweeper on FPGA Implementation

**Device**: DEVKIT on Spartan3E (XC3S500E-4PQ208C)
	http://www.sz-21eda.com/

## Info
* **Input**: PS/2 keyboard, 8 triggers, 5 buttons
PS/2 Keyboard: https://eewiki.net/pages/viewpage.action?pageId=28278929

* **Output**: VGA display (640x480), LED Matrix 8x8
VGA Controller:	https://eewiki.net/pages/viewpage.action?pageId=15925278 
 
* **Video**: 

**Software**:
* Aldec Active-HDL 9.3: 
	https://www.aldec.com/
* Xilinx ISE 14.7: 
	http://www.xilinx.com/

**Design Summary Report (Unilization %) XC3S500E-4PQ208C**:

* Number of External IOBs                  26 out of 158    16%;
* Number of BUFGMUXs                        2 out of 24      8%;
* Number of DCMs                            1 out of 4      25%;
* Number of RAMB16s                         3 out of 20     15%;
* Number of MULT18x18s                      0 out of 20      0%;
* Number of Slices                        515 out of 4656   11%;
*   Number of SLICEMs                     23 out of 2328    1%;
