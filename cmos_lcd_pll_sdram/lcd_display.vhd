library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity lcd_display is
port(
	lcd_clk:		in std_logic;								--lcd驱动时钟
	sys_rst_n:	in std_logic;								--复位信号
	lcd_id:		in std_logic_vector(15 downto 0);	--LCD屏ID
	
	pixel_xpos:	in std_logic_vector(10 downto 0);	--像素点横坐标
	pixel_ypos:	in std_logic_vector(10 downto 0);	--像素点纵坐标 
	cmos_data:	in std_logic_vector(15 downto 0);	--CMOS传感器像素点数据
	h_disp:		in std_logic_vector(10 downto 0);	--LCD屏水平分辨率
	v_disp:		in std_logic_vector(10 downto 0);	--LCD屏垂直分辨率 
	
	lcd_data:	out std_logic_vector(15 downto 0);	--LCD像素点数据
	data_req:	out std_logic								--请求像素点颜色数据输入
);
end lcd_display;

architecture behav of lcd_display is
constant v_cmos_disp:std_logic_vector(10 downto 0):="00111100000";	--CMOS分辨率——行
constant h_cmos_disp:std_logic_vector(10 downto 0):="01010000000";	--CMOS分辨率——列

constant black:std_logic_vector(15 downto 0):="0000000000000000";		--RGB565 黑色

signal data_val:std_logic;				--数据有效信号
signal display_border_pos_l:std_logic_vector(10 downto 0);		--左侧边界的横坐标
signal display_border_pos_r:std_logic_vector(10 downto 0);		--右侧边界的横坐标
signal display_border_pos_t:std_logic_vector(10 downto 0);		--上端边界的纵坐标
signal display_border_pos_b:std_logic_vector(10 downto 0);		--下端边界的纵坐标

SIGNAL data_req_signal       : STD_LOGIC;
signal h_extra1				:std_LOGIC_VECTOR(10 downto 0);	 --多出来的水平分辨率
signal v_extra1				:std_LOGIC_VECTOR(10 downto 0);	 --多出来的垂直分辨率
	
begin
data_req <= data_req_signal;
--计算裁剪后的图像坐标
	h_extra1 <= h_disp - h_cmos_disp;
	v_extra1 <= v_disp - v_cmos_disp;
--左侧边界的横坐标计算
display_border_pos_l <= ('0' &h_extra1(10 downto 1)) - "00000000001";

--右侧边界的横坐标计算
display_border_pos_r <= h_cmos_disp +('0' &h_extra1(10 downto 1)) - "00000000001";

--上端边界的纵坐标计算
display_border_pos_t <= ('0' &v_extra1(10 downto 1));

--下端边界的纵坐标计算
display_border_pos_b <= v_cmos_disp + ('0' &v_extra1(10 downto 1));

--请求像素点颜色数据输入 范围:79~718，共640个时钟周期
data_req_signal <= '1' when ((pixel_xpos >= display_border_pos_l) and (pixel_xpos < display_border_pos_r) and (pixel_ypos > display_border_pos_t) and (pixel_ypos <= display_border_pos_b)) else
				'0';

--在数据有效范围内，将摄像头采集的数据赋值给LCD像素点数据
lcd_data <= cmos_data when data_val = '1' else
				black;
			
--有效数据滞后于请求信号一个时钟周期,所以数据有效信号在此延时一拍
process(lcd_clk,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		data_val <= '0';
	elsif(rising_edge(lcd_clk)) then
		data_val <= data_req_signal;
	end if;
end process;

end behav;
