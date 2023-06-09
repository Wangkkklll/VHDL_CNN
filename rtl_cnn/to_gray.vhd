library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity to_gray is
port(
	gray_clk:in std_logic;			--接lcd驱动时钟(lcd_clk)
	rst_n:in std_logic;			--复位信号

	gray_de:in std_logic;			--数据输入开始信号(接lcd_de)
	
	x:in std_logic_vector(10 downto 0);		--像素点横坐标(pixel_xpos)
	y:in std_logic_vector(10 downto 0);		--像素点纵坐标(pixel_ypos)
	rgb_in:in std_logic_vector(15 downto 0);			--rgb颜色数据(lcd_rgb)
	
	gray_out:out std_logic_vector(10 downto 0);		--灰度图数据
	i:out std_logic_vector(4 downto 0);					--输出像素点横坐标
	j:buffer std_logic_vector(4 downto 0);				--输出像素点纵坐标

	end_pre:out std_logic;				--数据输出结束信号
	data_req:out std_logic				--数据输出信号
	
	);
end entity;

architecture stru of to_gray is

signal h_cnt:std_logic_vector(10 downto 0);
signal v_cnt:std_logic_vector(10 downto 0);

signal sr_data_0_0:std_logic_vector(17 downto 0);
signal wr_sr_data_0:std_logic;
signal output_data_0_0:std_logic_vector(10 downto 0);
signal sr_data_1_0:std_logic_vector(17 downto 0);
signal wr_sr_data_1:std_logic;
signal output_data_1_0:std_logic_vector(10 downto 0);
signal sr_data_2_0:std_logic_vector(17 downto 0);
signal wr_sr_data_2:std_logic;
signal output_data_2_0:std_logic_vector(10 downto 0);
signal sr_data_3_0:std_logic_vector(17 downto 0);
signal wr_sr_data_3:std_logic;
signal output_data_3_0:std_logic_vector(10 downto 0);
signal sr_data_4_0:std_logic_vector(17 downto 0);
signal wr_sr_data_4:std_logic;
signal output_data_4_0:std_logic_vector(10 downto 0);
signal sr_data_5_0:std_logic_vector(17 downto 0);
signal wr_sr_data_5:std_logic;
signal output_data_5_0:std_logic_vector(10 downto 0);
signal sr_data_6_0:std_logic_vector(17 downto 0);
signal wr_sr_data_6:std_logic;
signal output_data_6_0:std_logic_vector(10 downto 0);
signal sr_data_7_0:std_logic_vector(17 downto 0);
signal wr_sr_data_7:std_logic;
signal output_data_7_0:std_logic_vector(10 downto 0);
signal sr_data_8_0:std_logic_vector(17 downto 0);
signal wr_sr_data_8:std_logic;
signal output_data_8_0:std_logic_vector(10 downto 0);
signal sr_data_9_0:std_logic_vector(17 downto 0);
signal wr_sr_data_9:std_logic;
signal output_data_9_0:std_logic_vector(10 downto 0);
signal sr_data_10_0:std_logic_vector(17 downto 0);
signal wr_sr_data_10:std_logic;
signal output_data_10_0:std_logic_vector(10 downto 0);
signal sr_data_11_0:std_logic_vector(17 downto 0);
signal wr_sr_data_11:std_logic;
signal output_data_11_0:std_logic_vector(10 downto 0);
signal sr_data_12_0:std_logic_vector(17 downto 0);
signal wr_sr_data_12:std_logic;
signal output_data_12_0:std_logic_vector(10 downto 0);
signal sr_data_13_0:std_logic_vector(17 downto 0);
signal wr_sr_data_13:std_logic;
signal output_data_13_0:std_logic_vector(10 downto 0);
signal sr_data_14_0:std_logic_vector(17 downto 0);
signal wr_sr_data_14:std_logic;
signal output_data_14_0:std_logic_vector(10 downto 0);
signal sr_data_15_0:std_logic_vector(17 downto 0);
signal wr_sr_data_15:std_logic;
signal output_data_15_0:std_logic_vector(10 downto 0);
signal sr_data_16_0:std_logic_vector(17 downto 0);
signal wr_sr_data_16:std_logic;
signal output_data_16_0:std_logic_vector(10 downto 0);
signal sr_data_17_0:std_logic_vector(17 downto 0);
signal wr_sr_data_17:std_logic;
signal output_data_17_0:std_logic_vector(10 downto 0);
signal sr_data_18_0:std_logic_vector(17 downto 0);
signal wr_sr_data_18:std_logic;
signal output_data_18_0:std_logic_vector(10 downto 0);
signal sr_data_19_0:std_logic_vector(17 downto 0);
signal wr_sr_data_19:std_logic;
signal output_data_19_0:std_logic_vector(10 downto 0);
signal sr_data_20_0:std_logic_vector(17 downto 0);
signal wr_sr_data_20:std_logic;
signal output_data_20_0:std_logic_vector(10 downto 0);
signal sr_data_21_0:std_logic_vector(17 downto 0);
signal wr_sr_data_21:std_logic;
signal output_data_21_0:std_logic_vector(10 downto 0);
signal sr_data_22_0:std_logic_vector(17 downto 0);
signal wr_sr_data_22:std_logic;
signal output_data_22_0:std_logic_vector(10 downto 0);
signal sr_data_23_0:std_logic_vector(17 downto 0);
signal wr_sr_data_23:std_logic;
signal output_data_23_0:std_logic_vector(10 downto 0);
signal sr_data_24_0:std_logic_vector(17 downto 0);
signal wr_sr_data_24:std_logic;
signal output_data_24_0:std_logic_vector(10 downto 0);
signal sr_data_25_0:std_logic_vector(17 downto 0);
signal wr_sr_data_25:std_logic;
signal output_data_25_0:std_logic_vector(10 downto 0);
signal sr_data_26_0:std_logic_vector(17 downto 0);
signal wr_sr_data_26:std_logic;
signal output_data_26_0:std_logic_vector(10 downto 0);
signal sr_data_27_0:std_logic_vector(17 downto 0);
signal wr_sr_data_27:std_logic;
signal output_data_27_0:std_logic_vector(10 downto 0);

signal r:std_logic_vector(10 downto 0);
signal g:std_logic_vector(10 downto 0);
signal b:std_logic_vector(10 downto 0);
signal gray:std_logic_vector(17 downto 0);

begin

process(gray_clk,rst_n)
begin
	if(rst_n = '0') then
		i <= "00000";
		j <= "00000";
		sr_data_0_0 <= "000000000000000000";
		sr_data_1_0 <= "000000000000000000";
		sr_data_2_0 <= "000000000000000000";
		sr_data_3_0 <= "000000000000000000";
		sr_data_4_0 <= "000000000000000000";
		sr_data_5_0 <= "000000000000000000";
		sr_data_6_0 <= "000000000000000000";
		sr_data_7_0 <= "000000000000000000";
		sr_data_8_0 <= "000000000000000000";
		sr_data_9_0 <= "000000000000000000";
		sr_data_10_0 <= "000000000000000000";
		sr_data_11_0 <= "000000000000000000";
		sr_data_12_0 <= "000000000000000000";
		sr_data_13_0 <= "000000000000000000";
		sr_data_14_0 <= "000000000000000000";
		sr_data_15_0 <= "000000000000000000";
		sr_data_16_0 <= "000000000000000000";
		sr_data_17_0 <= "000000000000000000";
		sr_data_18_0 <= "000000000000000000";
		sr_data_19_0 <= "000000000000000000";
		sr_data_20_0 <= "000000000000000000";
		sr_data_21_0 <= "000000000000000000";
		sr_data_22_0 <= "000000000000000000";
		sr_data_23_0 <= "000000000000000000";
		sr_data_24_0 <= "000000000000000000";
		sr_data_25_0 <= "000000000000000000";
		sr_data_26_0 <= "000000000000000000";
		sr_data_27_0 <= "000000000000000000";
		end_pre <= '0';
		gray <= "000000000000000000";
	elsif(rising_edge(gray_clk)) then
		if(gray_de = '1') then
			r <= "00000000000";
			r(9) <= rgb_in(15);
			r(8) <= rgb_in(14);
			r(7) <= rgb_in(13);
			r(6) <= rgb_in(12);
			r(5) <= rgb_in(11);
			
			g <= "00000000000";
			g(9) <= rgb_in(10);
			g(8) <= rgb_in(9);
			g(7) <= rgb_in(8);
			g(6) <= rgb_in(7);
			g(5) <= rgb_in(6);
			g(4) <= rgb_in(5);
			
			b <= "00000000000";
			b(9) <= rgb_in(4);
			b(8) <= rgb_in(3);
			b(7) <= rgb_in(2);
			b(6) <= rgb_in(1);
			b(5) <= rgb_in(0);
			
			gray <= "0000011"*b + "0001000"*g + "0000101"*r;
			gray <= "0000" & gray(13 downto 0);
			
				if((x > ("00100011111"+("00000"*"00000010000"))) and (x < ("00100110000"+("00000"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_0_0 <= sr_data_0_0 + gray;		--(x>(287+0*16)&(x<(304+(0*16))&(y>(75+(j*16))&(y<(92+(j*16))   //304=288+16,92=76+16
				elsif((x > ("00100011111"+("00001"*"00000010000"))) and (x < ("00100110000"+("00001"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_1_0 <= sr_data_1_0 + gray;		--(x>(287+1*16)&(x<(304+(1*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("00010"*"00000010000"))) and (x < ("00100110000"+("00010"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_2_0 <= sr_data_2_0 + gray;		--(x>(287+2*16)&(x<(304+(2*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("00011"*"00000010000"))) and (x < ("00100110000"+("00011"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_3_0 <= sr_data_3_0 + gray;		--(x>(287+3*16)&(x<(304+(3*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("00100"*"00000010000"))) and (x < ("00100110000"+("00100"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_4_0 <= sr_data_4_0 + gray;		--(x>(287+4*16)&(x<(304+(4*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("00101"*"00000010000"))) and (x < ("00100110000"+("00101"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_5_0 <= sr_data_5_0 + gray;		--(x>(287+5*16)&(x<(304+(5*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("00110"*"00000010000"))) and (x < ("00100110000"+("00110"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_6_0 <= sr_data_6_0 + gray;		--(x>(287+6*16)&(x<(304+(6*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("00111"*"00000010000"))) and (x < ("00100110000"+("00111"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_7_0 <= sr_data_7_0 + gray;		--(x>(287+7*16)&(x<(304+(7*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("01000"*"00000010000"))) and (x < ("00100110000"+("01000"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_8_0 <= sr_data_8_0 + gray;		--(x>(287+8*16)&(x<(304+(8*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("01001"*"00000010000"))) and (x < ("00100110000"+("01001"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_9_0 <= sr_data_9_0 + gray;		--(x>(287+9*16)&(x<(304+(9*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("01010"*"00000010000"))) and (x < ("00100110000"+("01010"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_10_0 <= sr_data_10_0 + gray;		--(x>(287+10*16)&(x<(304+(10*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("01011"*"00000010000"))) and (x < ("00100110000"+("01011"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_11_0 <= sr_data_11_0 + gray;		--(x>(287+11*16)&(x<(304+(11*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("01100"*"00000010000"))) and (x < ("00100110000"+("01100"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_12_0 <= sr_data_12_0 + gray;		--(x>(287+12*16)&(x<(304+(12*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("01101"*"00000010000"))) and (x < ("00100110000"+("01101"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_13_0 <= sr_data_13_0 + gray;		--(x>(287+13*16)&(x<(304+(13*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("01110"*"00000010000"))) and (x < ("00100110000"+("01110"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_14_0 <= sr_data_14_0 + gray;		--(x>(287+14*16)&(x<(304+(14*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("01111"*"00000010000"))) and (x < ("00100110000"+("01111"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_15_0 <= sr_data_15_0 + gray;		--(x>(287+15*16)&(x<(304+(15*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("10000"*"00000010000"))) and (x < ("00100110000"+("10000"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_16_0 <= sr_data_16_0 + gray;		--(x>(287+16*16)&(x<(304+(16*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("10001"*"00000010000"))) and (x < ("00100110000"+("10001"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_17_0 <= sr_data_17_0 + gray;		--(x>(287+17*16)&(x<(304+(17*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("10010"*"00000010000"))) and (x < ("00100110000"+("10010"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_18_0 <= sr_data_18_0 + gray;		--(x>(287+18*16)&(x<(304+(18*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("10011"*"00000010000"))) and (x < ("00100110000"+("10011"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_19_0 <= sr_data_19_0 + gray;		--(x>(287+19*16)&(x<(304+(19*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("10100"*"00000010000"))) and (x < ("00100110000"+("10100"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_20_0 <= sr_data_20_0 + gray;		--(x>(287+20*16)&(x<(304+(20*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("10101"*"00000010000"))) and (x < ("00100110000"+("10101"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_21_0 <= sr_data_21_0 + gray;		--(x>(287+21*16)&(x<(304+(21*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("10110"*"00000010000"))) and (x < ("00100110000"+("10110"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_22_0 <= sr_data_22_0 + gray;		--(x>(287+22*16)&(x<(304+(22*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("10111"*"00000010000"))) and (x < ("00100110000"+("10111"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_23_0 <= sr_data_23_0 + gray;		--(x>(287+23*16)&(x<(304+(23*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("11000"*"00000010000"))) and (x < ("00100110000"+("11000"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_24_0 <= sr_data_24_0 + gray;		--(x>(287+24*16)&(x<(304+(24*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("11001"*"00000010000"))) and (x < ("00100110000"+("11001"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_25_0 <= sr_data_25_0 + gray;		--(x>(287+25*16)&(x<(304+(25*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("11010"*"00000010000"))) and (x < ("00100110000"+("11010"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_26_0 <= sr_data_26_0 + gray;		--(x>(287+26*16)&(x<(304+(26*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				elsif((x > ("00100011111"+("11011"*"00000010000"))) and (x < ("00100110000"+("11011"*"00000010000"))) 
				and (y>("00001001011"+(j*"00000010000"))) and (y<("00001011100"+(j*"00000010000")))) then
					sr_data_27_0 <= sr_data_27_0 + gray;		--(x>(287+27*16)&(x<(304+(27*16))&(y>(75+(j*16))&(y<(92+(j*16)) 
				end if;
				
				
				if((x=("00100110001"+("00000"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_0_0;		--(x=305+0*16)&(y=91+j*16)
					i <= "00000";
				end if;
				if((x>("00100110011"+("00000"*"00000010000"))) and (x<("000100111101"+("00000"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_0 <= '1';					--(x>307+0*16)&(x<317+0*16)&(y=91+j*16)
				else
					wr_sr_data_0 <= '0';
				end if;

				if((x=("00100110001"+("00001"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_1_0;		--(x=305+1*16)&(y=91+j*16)
					i <= "00001";
				end if;
				if((x>("00100110011"+("00001"*"00000010000"))) and (x<("000100111101"+("00001"*"00000010000")))
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_1 <= '1';					--(x>307+1*16)&(x<317+1*16)&(y=91+j*16)
				else
					wr_sr_data_1 <= '0';
				end if;				
					
				if((x=("00100110001"+("00010"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_2_0;		--(x=305+2*16)&(y=91+j*16)
					i <= "00010";
				end if;
				if((x>("00100110011"+("00010"*"00000010000"))) and (x<("000100111101"+("00010"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_2 <= '1';					--(x>307+2*16)&(x<317+2*16)&(y=91+j*16)
				else
					wr_sr_data_2 <= '0';
				end if;					
					
				if((x=("00100110001"+("00011"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_3_0;		--(x=305+3*16)&(y=91+j*16)
					i <= "00011";
				end if;
				if((x>("00100110011"+("00011"*"00000010000"))) and (x<("000100111101"+("00011"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_3 <= '1';					--(x>307+3*16)&(x<317+3*16)&(y=91+j*16)
				else
					wr_sr_data_3 <= '0';
				end if;	
				
				if((x=("00100110001"+("00100"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_4_0;		--(x=305+4*16)&(y=91+j*16)
					i <= "00100";
				end if;
				if((x>("00100110011"+("00100"*"00000010000"))) and (x<("000100111101"+("00100"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_4 <= '1';					--(x>307+4*16)&(x<317+4*16)&(y=91+j*16)
				else
					wr_sr_data_4 <= '0';
				end if;
				
				if((x=("00100110001"+("00101"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_5_0;		--(x=305+5*16)&(y=91+j*16)
					i <= "00101";
				end if;
				if((x>("00100110011"+("00101"*"00000010000"))) and (x<("000100111101"+("00101"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_5 <= '1';					--(x>307+5*16)&(x<317+5*16)&(y=91+j*16)
				else
					wr_sr_data_5 <= '0';
				end if;
				
				if((x=("00100110001"+("00110"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_6_0;		--(x=305+6*16)&(y=91+j*16)
					i <= "00110";
				end if;
				if((x>("00100110011"+("00110"*"00000010000"))) and (x<("000100111101"+("00110"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_6 <= '1';					--(x>307+6*16)&(x<317+6*16)&(y=91+j*16)
				else
					wr_sr_data_6 <= '0';
				end if;
				
				if((x=("00100110001"+("00111"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_7_0;		--(x=305+7*16)&(y=91+j*16)
					i <= "00111";
				end if;
				if((x>("00100110011"+("00111"*"00000010000"))) and (x<("000100111101"+("00111"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_7 <= '1';					--(x>307+7*16)&(x<317+7*16)&(y=91+j*16)
				else
					wr_sr_data_7 <= '0';
				end if;
				
				if((x=("00100110001"+("01000"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_8_0;		--(x=305+8*16)&(y=91+j*16)
					i <= "01000";
				end if;
				if((x>("00100110011"+("01000"*"00000010000"))) and (x<("000100111101"+("01000"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_8 <= '1';					--(x>307+8*16)&(x<317+8*16)&(y=91+j*16)
				else
					wr_sr_data_8 <= '0';
				end if;
				
				if((x=("00100110001"+("01001"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_9_0;		--(x=305+9*16)&(y=91+j*16)
					i <= "01001";
				end if;
				if((x>("00100110011"+("01001"*"00000010000"))) and (x<("000100111101"+("01001"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_9 <= '1';					--(x>307+9*16)&(x<317+9*16)&(y=91+j*16)
				else
					wr_sr_data_9 <= '0';
				end if;
				
				if((x=("00100110001"+("01010"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_10_0;		--(x=305+10*16)&(y=91+j*16)
					i <= "01010";
				end if;
				if((x>("00100110011"+("01010"*"00000010000"))) and (x<("000100111101"+("01010"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_10 <= '1';					--(x>307+10*16)&(x<317+10*16)&(y=91+j*16)
				else
					wr_sr_data_10 <= '0';
				end if;

				if((x=("00100110001"+("01011"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_11_0;		--(x=305+11*16)&(y=91+j*16)
					i <= "01011";
				end if;
				if((x>("00100110011"+("01011"*"00000010000"))) and (x<("000100111101"+("01011"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_11 <= '1';					--(x>307+11*16)&(x<317+11*16)&(y=91+j*16)
				else
					wr_sr_data_11 <= '0';
				end if;				
					
				if((x=("00100110001"+("01100"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_12_0;		--(x=305+12*16)&(y=91+j*16)
					i <= "01100";
				end if;
				if((x>("00100110011"+("01100"*"00000010000"))) and (x<("000100111101"+("01100"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_12 <= '1';					--(x>307+12*16)&(x<317+12*16)&(y=91+j*16)
				else
					wr_sr_data_12 <= '0';
				end if;					
					
				if((x=("00100110001"+("01101"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_13_0;		--(x=305+13*16)&(y=91+j*16)
					i <= "01101";
				end if;
				if((x>("00100110011"+("01101"*"00000010000"))) and (x<("000100111101"+("01101"*"00000010000")))
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_13 <= '1';					--(x>307+13*16)&(x<317+13*16)&(y=91+j*16)
				else
					wr_sr_data_13 <= '0';
				end if;	
				
				if((x=("00100110001"+("01110"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_14_0;		--(x=305+14*16)&(y=91+j*16)
					i <= "01110";
				end if;
				if((x>("00100110011"+("01110"*"00000010000"))) and (x<("000100111101"+("01110"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_14 <= '1';					--(x>307+14*16)&(x<317+14*16)&(y=91+j*16)
				else
					wr_sr_data_14 <= '0';
				end if;
				
				if((x=("00100110001"+("01111"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_15_0;		--(x=305+15*16)&(y=91+j*16)
					i <= "01111";
				end if;
				if((x>("00100110011"+("01111"*"00000010000"))) and (x<("000100111101"+("01111"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_15 <= '1';					--(x>307+15*16)&(x<317+15*16)&(y=91+j*16)
				else
					wr_sr_data_15 <= '0';
				end if;
				
				if((x=("00100110001"+("10000"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_16_0;		--(x=305+16*16)&(y=91+j*16)
					i <= "10000";
				end if;
				if((x>("00100110011"+("10000"*"00000010000"))) and (x<("000100111101"+("10000"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_16 <= '1';					--(x>307+16*16)&(x<317+16*16)&(y=91+j*16)
				else
					wr_sr_data_16 <= '0';
				end if;
				
				if((x=("00100110001"+("10001"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_17_0;		--(x=305+17*16)&(y=91+j*16)
					i <= "10001";
				end if;
				if((x>("00100110011"+("10001"*"00000010000"))) and (x<("000100111101"+("10001"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_17 <= '1';					--(x>307+17*16)&(x<317+17*16)&(y=91+j*16)
				else
					wr_sr_data_17 <= '0';
				end if;
				
				if((x=("00100110001"+("10010"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_18_0;		--(x=305+18*16)&(y=91+j*16)
					i <= "10010";
				end if;
				if((x>("00100110011"+("10010"*"00000010000"))) and (x<("000100111101"+("10010"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_18 <= '1';					--(x>307+18*16)&(x<317+18*16)&(y=91+j*16)
				else
					wr_sr_data_18 <= '0';
				end if;
				
				if((x=("00100110001"+("10011"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_19_0;		--(x=305+19*16)&(y=91+j*16)
					i <= "10011";
				end if;
				if((x>("00100110011"+("10011"*"00000010000"))) and (x<("000100111101"+("10011"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_19 <= '1';					--(x>307+19*16)&(x<317+19*16)&(y=91+j*16)
				else
					wr_sr_data_19 <= '0';
				end if;
				
				if((x=("00100110001"+("10100"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_20_0;		--(x=305+20*16)&(y=91+j*16)
					i <= "10100";
				end if;
				if((x>("00100110011"+("10100"*"00000010000"))) and (x<("000100111101"+("10100"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_20 <= '1';					--(x>307+20*16)&(x<317+20*16)&(y=91+j*16)
				else
					wr_sr_data_20 <= '0';
				end if;

				if((x=("00100110001"+("10101"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_21_0;		--(x=305+21*16)&(y=91+j*16)
					i <= "10101";
				end if;
				if((x>("00100110011"+("10101"*"00000010000"))) and (x<("000100111101"+("10101"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_21 <= '1';					--(x>307+21*16)&(x<317+21*16)&(y=91+j*16)
				else
					wr_sr_data_21 <= '0';
				end if;				
					
				if((x=("00100110001"+("10110"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_22_0;		--(x=305+22*16)&(y=91+j*16)
					i <= "10110";
				end if;
				if((x>("00100110011"+("10110"*"00000010000"))) and (x<("000100111101"+("10110"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_22 <= '1';					--(x>307+22*16)&(x<317+22*16)&(y=91+j*16)
				else
					wr_sr_data_22 <= '0';
				end if;					
					
				if((x=("00100110001"+("10111"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_23_0;		--(x=305+23*16)&(y=91+j*16)
					i <= "10111";
				end if;
				if((x>("00100110011"+("10111"*"00000010000"))) and (x<("000100111101"+("10111"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_23 <= '1';					--(x>307+23*16)&(x<317+23*16)&(y=91+j*16)
				else
					wr_sr_data_23 <= '0';
				end if;	
				
				if((x=("00100110001"+("11000"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_24_0;		--(x=305+24*16)&(y=91+j*16)
					i <= "11000";
				end if;
				if((x>("00100110011"+("11000"*"00000010000"))) and (x<("000100111101"+("11000"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_24 <= '1';					--(x>307+24*16)&(x<317+24*16)&(y=91+j*16)
				else
					wr_sr_data_24 <= '0';
				end if;
				
				if((x=("00100110001"+("11001"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_25_0;		--(x=305+25*16)&(y=91+j*16)
					i <= "11001";
				end if;
				if((x>("00100110011"+("11001"*"00000010000"))) and (x<("000100111101"+("11001"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_25 <= '1';					--(x>307+25*16)&(x<317+25*16)&(y=91+j*16)
				else
					wr_sr_data_25 <= '0';
				end if;
				
				if((x=("00100110001"+("11010"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_26_0;		--(x=305+26*16)&(y=91+j*16)
					i <= "11010";
				end if;
				if((x>("00100110011"+("11010"*"00000010000"))) and (x<("000100111101"+("11010"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_26 <= '1';					--(x>307+26*16)&(x<317+26*16)&(y=91+j*16)
				else
					wr_sr_data_26 <= '0';
				end if;
				
				if((x=("00100110001"+("11011"*"00000010000"))) and (y=("00001011011"+(j*"00000010000")))) then
					gray_out <= output_data_27_0;		--(x=305+27*16)&(y=91+j*16)
					i <= "11011";
				end if;
				if((x>("00100110011"+("11011"*"00000010000"))) and (x<("000100111101"+("11011"*"00000010000"))) 
				and (y=("00001011011"+(j*"00000010000")))) then
					wr_sr_data_27 <= '1';					--(x>307+27*16)&(x<317+27*16)&(y=91+j*16)
				else
					wr_sr_data_27 <= '0';
				end if;
				
				
				if((x="01111111111") and (y=("00001011011"+(j*"00000010000")))) then			--((x=1023)and (y=91+j*16)
					if(j >= "11011" ) then
						end_pre <= '1';
					else
						j <= j + "00001";
						sr_data_0_0 <= "000000000000000000";
						sr_data_1_0 <= "000000000000000000";
						sr_data_2_0 <= "000000000000000000";
						sr_data_3_0 <= "000000000000000000";
						sr_data_4_0 <= "000000000000000000";
						sr_data_5_0 <= "000000000000000000";
						sr_data_6_0 <= "000000000000000000";
						sr_data_7_0 <= "000000000000000000";
						sr_data_8_0 <= "000000000000000000";
						sr_data_9_0 <= "000000000000000000";
						sr_data_10_0 <= "000000000000000000";
						sr_data_11_0 <= "000000000000000000";
						sr_data_12_0 <= "000000000000000000";
						sr_data_13_0 <= "000000000000000000";
						sr_data_14_0 <= "000000000000000000";
						sr_data_15_0 <= "000000000000000000";
						sr_data_16_0 <= "000000000000000000";
						sr_data_17_0 <= "000000000000000000";
						sr_data_18_0 <= "000000000000000000";
						sr_data_19_0 <= "000000000000000000";
						sr_data_20_0 <= "000000000000000000";
						sr_data_21_0 <= "000000000000000000";
						sr_data_22_0 <= "000000000000000000";
						sr_data_23_0 <= "000000000000000000";
						sr_data_24_0 <= "000000000000000000";
						sr_data_25_0 <= "000000000000000000";
						sr_data_26_0 <= "000000000000000000";
						sr_data_27_0 <= "000000000000000000";
					end if;
				else
					i <= "00000";
					j <= "00000";
					sr_data_0_0 <= "000000000000000000";
					sr_data_1_0 <= "000000000000000000";
					sr_data_2_0 <= "000000000000000000";
					sr_data_3_0 <= "000000000000000000";
					sr_data_4_0 <= "000000000000000000";
					sr_data_5_0 <= "000000000000000000";
					sr_data_6_0 <= "000000000000000000";
					sr_data_7_0 <= "000000000000000000";
					sr_data_8_0 <= "000000000000000000";
					sr_data_9_0 <= "000000000000000000";
					sr_data_10_0 <= "000000000000000000";
					sr_data_11_0 <= "000000000000000000";
					sr_data_12_0 <= "000000000000000000";
					sr_data_13_0 <= "000000000000000000";
					sr_data_14_0 <= "000000000000000000";
					sr_data_15_0 <= "000000000000000000";
					sr_data_16_0 <= "000000000000000000";
					sr_data_17_0 <= "000000000000000000";
					sr_data_18_0 <= "000000000000000000";
					sr_data_19_0 <= "000000000000000000";
					sr_data_20_0 <= "000000000000000000";
					sr_data_21_0 <= "000000000000000000";
					sr_data_22_0 <= "000000000000000000";
					sr_data_23_0 <= "000000000000000000";
					sr_data_24_0 <= "000000000000000000";
					sr_data_25_0 <= "000000000000000000";
					sr_data_26_0 <= "000000000000000000";
					sr_data_27_0 <= "000000000000000000";
					end_pre <= '0';
					gray <= "000000000000000000";
				end if;
		end if;
	end if;

end process;

output_data_0_0 <= sr_data_0_0(17 downto 7);			--右移8位（除以256=16*16）相当于求平均
output_data_1_0 <= sr_data_1_0(17 downto 7);	
output_data_2_0 <= sr_data_2_0(17 downto 7);
output_data_3_0 <= sr_data_3_0(17 downto 7);
output_data_4_0 <= sr_data_4_0(17 downto 7);
output_data_5_0 <= sr_data_5_0(17 downto 7);
output_data_6_0 <= sr_data_6_0(17 downto 7);	
output_data_7_0 <= sr_data_7_0(17 downto 7);
output_data_8_0 <= sr_data_8_0(17 downto 7);
output_data_9_0 <= sr_data_9_0(17 downto 7);
output_data_10_0 <= sr_data_10_0(17 downto 7);
output_data_11_0 <= sr_data_11_0(17 downto 7);	
output_data_12_0 <= sr_data_12_0(17 downto 7);
output_data_13_0 <= sr_data_13_0(17 downto 7);
output_data_14_0 <= sr_data_14_0(17 downto 7);
output_data_15_0 <= sr_data_15_0(17 downto 7);
output_data_16_0 <= sr_data_16_0(17 downto 7);
output_data_17_0 <= sr_data_17_0(17 downto 7);
output_data_18_0 <= sr_data_18_0(17 downto 7);
output_data_19_0 <= sr_data_19_0(17 downto 7);
output_data_20_0 <= sr_data_20_0(17 downto 7);
output_data_21_0 <= sr_data_21_0(17 downto 7);
output_data_22_0 <= sr_data_22_0(17 downto 7);
output_data_23_0 <= sr_data_23_0(17 downto 7);
output_data_24_0 <= sr_data_24_0(17 downto 7);
output_data_25_0 <= sr_data_25_0(17 downto 7);
output_data_26_0 <= sr_data_26_0(17 downto 7);
output_data_27_0 <= sr_data_27_0(17 downto 7);

data_req <= wr_sr_data_0 or wr_sr_data_1 or wr_sr_data_2 or wr_sr_data_3 or wr_sr_data_4 
			or wr_sr_data_5 or wr_sr_data_6 or wr_sr_data_7 or wr_sr_data_8 or wr_sr_data_9
			or wr_sr_data_10 or wr_sr_data_11 or wr_sr_data_12 or wr_sr_data_13 or wr_sr_data_14
			or wr_sr_data_15 or wr_sr_data_16 or wr_sr_data_17 or wr_sr_data_18 or wr_sr_data_19
			or wr_sr_data_20 or wr_sr_data_21 or wr_sr_data_22 or wr_sr_data_23 or wr_sr_data_24
			or wr_sr_data_25 or wr_sr_data_26 or wr_sr_data_27;
			
end stru;