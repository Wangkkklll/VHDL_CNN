

# VHDL_CNN
![license](https://img.shields.io/badge/license-MIT-blue)
![build](https://img.shields.io/badge/build-passing-yellowgreen)

## Introduction 
1、本项目是基于VHDL的卷积神经网络的RTL设计，所有的模块实现均采用手工设计  
2、我们验证了设计的时序的准确性，包括使用软件仿真与硬件仿真的方法  
3、我们加上了摄像头捕获数据与屏幕显示的数据流  
4、我们仿真的前向传播延时约为100000，具体可参考我们的报告：report.docx

## Requirements
1、simulation requirements
```
Quartus (Quartus Prime 18.0) Standard Edition + ModelSim - Intel FPGA Starter Edition 10.5b (Quartus Prime 18.0)
```
2、hardware requirements
```
ov7725 + EP4CE10F17C8 + Seven-inch RGB display
```

## Usage  
### 1、BNN模型的训练
```
cd Pytorch_Bnn
python main_binary.py --model alexnet_binary --epochs 150
```
### 2、硬件文件配置
(1) 开发环境为：Quartus (Quartus Prime 18.0) Standard Edition + ModelSim - Intel FPGA Starter Edition 10.5b (Quartus Prime 18.0)
(2) 硬件配置为：ov7725 + EP4CE10F17C8 + Seven-inch RGB display  
(3) 顶层文件的设置在：./top/top.vhd  
(4) 仿真文件的设置在: ./simulation/modelsim 其中两个work分别代表时序仿真和逻辑仿真  
(5) CNN模块的设置在: ./rtl_cnn/  
其中
```
cnn.vhd:整体模块的设置
top_control.chd:控制器部分
conv_maxpooling.vhd:卷积与池化部分的计算单元  
full_connect.vhd:全连接层部分
ram_piexl.vhd:像素读取部分
rom_weight.vhd:权重读取部分  
```
(6) 摄像头与屏幕的数据流在./cmos_lcd_pll_sdram  
(7) 所定义的RAM与ROM在./a  
### 3、代码使用
使用Quartus Prime 18.0打开项目，将./top/top.vhd设置为顶层文件，编译，然后烧录即可  
### 4、硬件资源耗用
如图所示：  
![image](https://github.com/Wangkkklll/VHDL_CNN/assets/71534709/4825a9ac-8ad3-455a-9650-7258945259f2)  
使用的LUT为6670，9bit专用乘法器为4个。

## FAQ 
## 项目扩展
上面的项目是基于纯手写的VHDL完成对CNN的设计，实际上基于HLS的高层次设计能在开发过程中实现更快的速度  
将上面的网络用HLS进行实现，待更新、、、、、、、、、、、、
## Authors
Wang    eewkl@mail.scut.edu.cn  
Wu      202030242140@mail.scut.edu.cn
## License
MIT
