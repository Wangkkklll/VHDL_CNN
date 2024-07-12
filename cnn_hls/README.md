# 基于HLS的CNN设计
将项目的网络用HLS进行实现，高层次综合的结果如下：  
![image](https://github.com/Wangkkklll/VHDL_CNN/assets/71534709/d360076d-28d7-4cba-aaa3-8f0dcecdc268)  
**使用的LUT为8707，DSP为8个**  
## 1、整体设计
设计环境  
```
Vitis HLS 2023
```
  
整体上的设计采用了**乒乓buffer**的形式，以**粗粒度流水线**的方式进行加速  
在卷积层、池化层、权重读取、输入读取、输出写入等模块采用了部分展开进行流水线加速  
卷积加速器：采用的是**input_channel=4,output_channel=4,kernel_size=3,input_feature_size=36**的加速模块并进行复用(乒乓buffer)  
## 2、文件说明
```
cnn.cpp:整体模型的调用，配置层之间的数据流
conv2d.cpp:可复用的Conv2D的配置
AvgPooling2d.cpp:可复用的平均池化层的配置
GlobalAvgPooling2d.cpp:可复用的全局平均池化层的配置
Linear.cpp:可复用的全连接层的配置
layer_super_parm.h:层参数的定义
```
## 3、使用方法
**(1)Conv2D**
```
void Conv2d(ap_uint<8>*In_ddr,ap_uint<8>*W_ddr,ap_uint<8>* Out_ddr,
		int Chin,int Chou,int Insize,int Outsize,ap_uint<8> In_0[4][36][36],ap_uint<8> W_0[4][4][K][K],
		ap_uint<8> In_1[4][36][36],ap_uint<8> W_1[4][4][K][K],
		ap_uint<8> Out[4][34][34]);
```
参数说明：  
In_ddr:ap_uint<8>* 输入地址，读入8bit输入  
W_ddr:ap_uint<8>* 权重地址，读入8bit权重  
Out_ddr:ap_uint<8>* 输出地址，写入8bit输出  
Chin:int 输入通道数  
Chou:int 输出通道数  
Insize:int 输入特征大小  
Outsize:int 输出特征大小  
In_0,In_1:ap_uint<8>[4][36][36] 输入特征数组，静态变量  
W_0,W_1:ap_uint<8>[4][4][K][K] 输入权重数组，静态变量  
Out:ap_uint<8>[4][34][34] 输出数组，静态变量  
**(2)AvgPooling2d**  
```
void AvgPooling2d(ap_uint<8>*In_ddr,ap_uint<8>* Out_ddr,
		int Chin,int Chou,int Insize,int Outsize,ap_uint<8> In_0[4][36][36],
		ap_uint<8> In_1[4][36][36],ap_uint<8> Out[4][34][34]);
```
**(3)GlobalAvgPooling2d**  
```
void GlobalAvgPooling2d(ap_uint<8>*In_ddr,ap_uint<8>* Out_ddr,
		int Chin,int Chou,int Insize,int Outsize,ap_uint<8> In_0[4][36][36],
		ap_uint<8> In_1[4][36][36],ap_uint<8> Out[4][34][34]);
```
**(4)Linear**  
```
void Linear(ap_uint<8>*In_ddr,ap_uint<8>*W_ddr,ap_uint<8>* Out_ddr );
```
## 延时测试
由于还未进行仿真，因此使用HLS设计得到的各层延时的和作为总的延时，各层延时的测试如下  
(1)Conv2d(1,4,kernelsize=3) **cycles=4636**
![image](https://github.com/Wangkkklll/VHDL_CNN/assets/71534709/ca3e4466-3b8a-47aa-99d0-7a3926a0f38f)  
(2)Conv2d(4,4,kernelsize=3) **cycles=8902**
![image](https://github.com/Wangkkklll/VHDL_CNN/assets/71534709/57389504-58d4-4534-8ee5-b38072a7a091)  
(3)AvgPooling2d(kernelsize=2) **cycles=5145**
![image](https://github.com/Wangkkklll/VHDL_CNN/assets/71534709/a355d7d0-d3dd-4bd6-a4b0-8007d766a063)  
(4)Conv2d(4,8,kernelsize=3) **cycles=3985**
![image](https://github.com/Wangkkklll/VHDL_CNN/assets/71534709/3e9994a8-afd2-49c7-afd8-65d4d38a256d)  
(5)Conv2d(8,8,kernelsize=3) **cycles=1917**
![image](https://github.com/Wangkkklll/VHDL_CNN/assets/71534709/31ae7dbf-c1f6-45a1-abfb-f1e764b5b3e8)  
(6)AvgPooling2d(kernelsize=2) **cycles=1185**
![image](https://github.com/Wangkkklll/VHDL_CNN/assets/71534709/aebd1a29-633e-4000-9f55-70a86f3d8e34)  
(7)Conv2d(8,16,kernelsize=3) **cycles=637**
![image](https://github.com/Wangkkklll/VHDL_CNN/assets/71534709/14c2e8ed-8f7c-40d6-b98a-6406f9624b92)  
(8)GlobalAvgPooling2d+Linear **cycles=319**
![image](https://github.com/Wangkkklll/VHDL_CNN/assets/71534709/e7bed1a9-b35d-4e06-8e93-4663cd3b6518)  
  
**整体上的延时比纯RTL设计的要少，主要得益于乒乓buffer和部分展开的高效并行计算**
## Contact us
kangliwang@stu.pku.edu.cn  
## License
MIT
