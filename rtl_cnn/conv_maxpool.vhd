----------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;
--USE IEEE.std_logic_unsigned.All; error:Error (10621): VHDL Use Clause error at conv.vhd(55): 
--more than one Use Clause imports a declaration of simple name ""="" -- none of the declarations are directly visible

entity conv_maxpool is
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	conv_stop:in std_logic;
	maxpool_over:in std_logic;
	pool_start:in std_logic;
	position:in std_logic_vector(3 DOWNTO 0);
	q_out_a:in std_logic_vector(7 DOWNTO 0);
	q_out_b:in std_logic_vector(7 DOWNTO 0);
	q_out_c:in std_logic_vector(7 DOWNTO 0);
	q_out_d:in std_logic_vector(7 DOWNTO 0);
	--w1, w2 ,w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18:in std_logic_vector(1 DOWNTO 0);
	--w19, w20 ,w21, w22, w23, w24, w25, w26, w27, w28, w29, w30, w31, w32, w33, w34, w35, w36:in std_logic_vector(1 DOWNTO 0);
	weight_out:in std_logic_vector(71 downto 0);
	conv_over:in std_logic;
	layer:in std_logic_vector(3 DOWNTO 0);
	is_onetofour:in std_logic; --是前四个通道还是后四个通道
	once_finish:out std_logic;
	finish:out std_logic;
	data_out:out std_logic_vector(7 downto 0);
	data_out1:out std_logic_vector(7 downto 0);
	data_out2:out std_logic_vector(7 downto 0);
	data_out3:out std_logic_vector(7 downto 0);
	data_out4:out std_logic_vector(7 downto 0)
	);
end entity;

architecture structure of conv_maxpool is

COMPONENT read_data_sipo
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	position:in std_logic_vector(3 DOWNTO 0);
	q_out_a:in std_logic_vector(7 DOWNTO 0);
	q_out_b:in std_logic_vector(7 DOWNTO 0);
	q_out_c:in std_logic_vector(7 DOWNTO 0);
	q_out_d:in std_logic_vector(7 DOWNTO 0);
	conv_over:in std_logic;
	p1, p2 ,p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18:out std_logic_vector(7 DOwNTO 0);
	p19, p20 ,p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31, p32, p33, p34, p35, p36:out std_logic_vector(7 DOwNTO 0);
	p_pre_ready:out std_logic
	);
end COMPONENT;

COMPONENT Parallel_Conv
	port(
		clk:in std_logic;
		ready:in std_logic;
		rst_n:in std_logic;
		conv_stop:in std_logic;
		layer:in std_logic_vector(3 downto 0);
		d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18:in std_logic_vector(7 downto 0);
		d19,d20,d21,d22,d23,d24,d25,d26,d27,d28,d29,d30,d31,d32,d33,d34,d35,d36:in std_logic_vector(7 downto 0);
		--w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15,w16,w17,w18:in std_logic_vector(1 downto 0);
		--w19,w20,w21,w22,w23,w24,w25,w26,w27,w28,w29,w30,w31,w32,w33,w34,w35,w36:in std_logic_vector(1 downto 0);
		weight_out:in std_logic_vector(71 downto 0);
		data_out:out std_logic_vector(7 downto 0);
		data_out1:out std_logic_vector(7 downto 0);
		data_out2:out std_logic_vector(7 downto 0);
		data_out3:out std_logic_vector(7 downto 0);
		data_out4:out std_logic_vector(7 downto 0);
		finish:out std_logic
	);

end COMPONENT;

COMPONENT pool2d
	port(
		layer:in std_logic_vector(3 downto 0);    --3/6/8
		clk:in std_logic;
		rst_n:in std_logic;
		ready:in std_logic;
		maxpool_over:in std_logic;
		data_in1:in std_logic_vector(7 downto 0);
		data_in2:in std_logic_vector(7 downto 0);
		data_in3:in std_logic_vector(7 downto 0);
		data_in4:in std_logic_vector(7 downto 0);
		data_out1:out std_logic_vector(7 downto 0);
		data_out2:out std_logic_vector(7 downto 0);
		data_out3:out std_logic_vector(7 downto 0);
		data_out4:out std_logic_vector(7 downto 0);
		finish:out std_logic
	);
end COMPONENT;

COMPONENT ftoe
	port(
		is_size7:in std_logic; --7*7 or 14*14
		clk:in std_logic;
		rst_n:in std_logic;
		data_in:in std_logic_vector(7 downto 0);
		is_onetofour:in std_logic; --是前四个通道还是后四个通道
		ready:in std_logic;
		data_out:out std_logic_vector(7 downto 0);
		finish:out std_logic
	);
end COMPONENT;

COMPONENT sig_select
	port(
		layer:in std_logic_vector(3 downto 0);
		data_out1:in std_logic_vector(7 downto 0);
		data_out2:in std_logic_vector(7 downto 0);
		finish1:in std_logic;
		finish2:in std_logic;
		data_out_select:out std_logic_vector(7 downto 0);
		finish_select:out std_logic
	);
end COMPONENT;

COMPONENT result_select
	port(
		layer:in std_logic_vector(3 downto 0);
		conv_finish:in std_logic;
		pool_finish:in std_logic;
		finish_select:in std_logic;
		conv_data, conv_data1, conv_data2, conv_data3, conv_data4, data_out_select:in std_logic_vector(7 downto 0);
		pool_data1, pool_data2, pool_data3, pool_data4:in std_logic_vector(7 downto 0);
		once_finish:out std_logic;
		finish:out std_logic;
		data_out, data_out1, data_out2, data_out3, data_out4:out std_logic_vector(7 downto 0)
	);
end COMPONENT;

signal p1, p2 ,p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18:std_logic_vector(7 DOwNTO 0);
signal p19, p20 ,p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31, p32, p33, p34, p35, p36:std_logic_vector(7 DOwNTO 0);
signal p_pre_ready, data_ready, data_buffer, ready1:std_logic;
signal conv_finish, pool_finish, finish_select:std_logic;
signal pool_data1, pool_data2, pool_data3, pool_data4:std_logic_vector(7 downto 0);
signal conv_data, conv_data1, conv_data2, conv_data3, conv_data4:std_logic_vector(7 downto 0);
signal data_out_select:std_logic_vector(7 downto 0);
----
signal data_o:std_logic_vector(7 downto 0);
signal finish1, is_size7:std_logic;
signal pool_data_ready:std_logic;
begin
is_size7 <= '1' when layer="0111" else '0';

U0:read_data_sipo
	PORT map(clk, rst_n, position, q_out_a, q_out_b, q_out_c, q_out_d, conv_over,
	p1, p2 ,p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18,
	p19, p20 ,p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31, p32, p33, p34, p35, p36,p_pre_ready);
	
U1:Parallel_Conv
	PORT map(clk, p_pre_ready, rst_n, conv_stop, layer,
	p1, p2 ,p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18,
	p19, p20 ,p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31, p32, p33, p34, p35, p36,
	weight_out, conv_data, conv_data1, conv_data2, conv_data3, conv_data4, conv_finish);

U2:pool2d
	PORT map(layer, clk, rst_n, pool_data_ready, maxpool_over, q_out_a, q_out_b, q_out_c, q_out_d, 
	pool_data1, pool_data2, pool_data3, pool_data4, pool_finish);	

U3:ftoe
	PORT map(is_size7, clk, rst_n, conv_data, is_onetofour, conv_finish, data_o, finish1);	

U4:sig_select
	PORT map(layer, data_o, conv_data, finish1, conv_finish, data_out_select, finish_select);	

U5:result_select
	PORT map(layer, conv_finish, pool_finish, finish_select, conv_data, conv_data1, conv_data2, conv_data3, conv_data4, data_out_select, 
	pool_data1, pool_data2, pool_data3, pool_data4, once_finish, finish, data_out, data_out1, data_out2, data_out3, data_out4);	



---------delay for pool_start----------
process(clk)
begin
if rst_n='0' then
	data_buffer <= '0';
	ready1 <= '0';
	data_ready <= '0';
	pool_data_ready <= '0';
elsif(rising_edge(clk))then
	data_buffer <= pool_start;
	ready1 <= data_buffer;
	data_ready <= ready1;
	pool_data_ready <= data_ready;
end if;
end process;
---------------------------------------


end structure;
-------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;
--USE IEEE.std_logic_unsigned.All; error:Error (10621): VHDL Use Clause error at conv.vhd(55): 
--more than one Use Clause imports a declaration of simple name ""="" -- none of the declarations are directly visible

entity read_data_sipo is
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	position:in std_logic_vector(3 DOWNTO 0);
	q_out_a:in std_logic_vector(7 DOWNTO 0);
	q_out_b:in std_logic_vector(7 DOWNTO 0);
	q_out_c:in std_logic_vector(7 DOWNTO 0);
	q_out_d:in std_logic_vector(7 DOWNTO 0);
	conv_over:in std_logic;
	p1, p2 ,p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18:out std_logic_vector(7 DOwNTO 0);
	p19, p20 ,p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31, p32, p33, p34, p35, p36:out std_logic_vector(7 DOwNTO 0);
	p_pre_ready:out std_logic
	);
end entity;

architecture behav of read_data_sipo is
signal done:std_logic_vector(1 downto 0);
signal p_1, p_2 ,p_3, p_4, p_5, p_6, p_7, p_8, p_9, p_10, p_11, p_12, p_13, p_14, p_15, p_16, p_17, p_18:std_logic_vector(7 DOwNTO 0);
signal p_19, p_20 ,p_21, p_22, p_23, p_24, p_25, p_26, p_27, p_28, p_29, p_30, p_31, p_32, p_33, p_34, p_35, p_36:std_logic_vector(7 DOwNTO 0);
begin
process(clk, q_out_a, q_out_b, q_out_c, q_out_d)
begin
if (rising_edge(clk)) then
	case(position) is
		when "0010"=> p_1<=q_out_a;p_10<=q_out_b;p_19<=q_out_c;p_28<=q_out_d;
		when "0011"=> p_2<=q_out_a;p_11<=q_out_b;p_20<=q_out_c;p_29<=q_out_d;
		when "0100"=> p_3<=q_out_a;p_12<=q_out_b;p_21<=q_out_c;p_30<=q_out_d;
		when "0101"=> p_4<=q_out_a;p_13<=q_out_b;p_22<=q_out_c;p_31<=q_out_d;
		when "0110"=> p_5<=q_out_a;p_14<=q_out_b;p_23<=q_out_c;p_32<=q_out_d;
		when "0111"=> p_6<=q_out_a;p_15<=q_out_b;p_24<=q_out_c;p_33<=q_out_d;
		when "1000"=> p_7<=q_out_a;p_16<=q_out_b;p_25<=q_out_c;p_34<=q_out_d;
		when "0000"=> p_8<=q_out_a;p_17<=q_out_b;p_26<=q_out_c;p_35<=q_out_d;
		when "0001"=> if done="01" then
						p1<=p_1;p10<=p_10;p19<=p_19;p28<=p_28;
						p2<=p_2;p11<=p_11;p20<=p_20;p29<=p_29;
						p3<=p_3;p12<=p_12;p21<=p_21;p30<=p_30;
						p4<=p_4;p13<=p_13;p22<=p_22;p31<=p_31;
						p5<=p_5;p14<=p_14;p23<=p_23;p32<=p_32;
						p6<=p_6;p15<=p_15;p24<=p_24;p33<=p_33;
						p7<=p_7;p16<=p_16;p25<=p_25;p34<=p_34;
						p8<=p_8;p17<=p_17;p26<=p_26;p35<=p_35;
						p9<=q_out_a;p18<=q_out_b;p27<=q_out_c;p36<=q_out_d;
						end if;
		when others =>NULL;
	end case;
end if;
end process;

process(clk)
begin
if (rising_edge(clk)) then
	if (conv_over='1')or(position="0001") then
		done<=done+'1';
	else done<="00";
	end if;
	if (done="10") then
		p_pre_ready<='1';
	else p_pre_ready<='0';
	end if;
end if;
end process;

end behav;


-------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity Parallel_Conv is
	port(
		clk:in std_logic;
		ready:in std_logic;
		rst_n:in std_logic;
		conv_stop:in std_logic;
		layer:in std_logic_vector(3 downto 0);
		d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18:in std_logic_vector(7 downto 0);
		d19,d20,d21,d22,d23,d24,d25,d26,d27,d28,d29,d30,d31,d32,d33,d34,d35,d36:in std_logic_vector(7 downto 0);
		--w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15,w16,w17,w18:in std_logic_vector(1 downto 0);
		--w19,w20,w21,w22,w23,w24,w25,w26,w27,w28,w29,w30,w31,w32,w33,w34,w35,w36:in std_logic_vector(1 downto 0);
		weight_out:in std_logic_vector(71 downto 0);
		data_out:out std_logic_vector(7 downto 0);
		data_out1:out std_logic_vector(7 downto 0);
		data_out2:out std_logic_vector(7 downto 0);
		data_out3:out std_logic_vector(7 downto 0);
		data_out4:out std_logic_vector(7 downto 0);
		finish:out std_logic
	);

end entity;


architecture behav of Parallel_Conv is
component conv is
	port(
		ready:in std_logic;
		d1,d2,d3,d4,d5,d6,d7,d8,d9:in std_logic_vector(7 downto 0);
		w1,w2,w3,w4,w5,w6,w7,w8,w9:in std_logic_vector(1 downto 0);
		y:out std_logic_vector(13 downto 0) 	
	);
	
end component;
signal w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15,w16,w17,w18,w19,w20,w21,w22,w23,w24,w25,w26,w27,w28,w29,w30,w31,w32,w33,w34,w35,w36:std_logic_vector(1 downto 0);
signal y1:std_logic_vector(13 downto 0);
signal y2:std_logic_vector(13 downto 0);
signal y3:std_logic_vector(13 downto 0);
signal y4:std_logic_vector(13 downto 0);
signal y_out:std_logic_vector(13 downto 0);
signal ok1:std_logic;
signal ok2:std_logic;
signal y_co:std_logic_vector(7 downto 0);
signal y_co1:std_logic_vector(7 downto 0);
signal y_co2:std_logic_vector(7 downto 0);
signal y_co3:std_logic_vector(7 downto 0);
signal y_co4:std_logic_vector(7 downto 0);
signal fini1:std_logic;
signal fini2:std_logic;
signal stop1,stop12:std_logic;
--signal stop21,stop22,stop23:std_logic;
signal stop2:std_logic;

begin
w1<= weight_out(1 downto 0) ;
w2<= weight_out(3 downto 2) ;
w3<= weight_out(5 downto 4) ;
w4<= weight_out(7 downto 6) ;
w5<= weight_out(9 downto 8) ;
w6<= weight_out(11 downto 10) ;
w7<= weight_out(13 downto 12) ;
w8<= weight_out(15 downto 14) ;
w9<= weight_out(17 downto 16) ;
w10<= weight_out(19 downto 18) ;
w11<= weight_out(21 downto 20) ;
w12<= weight_out(23 downto 22) ;
w13<= weight_out(25 downto 24) ;
w14<= weight_out(27 downto 26) ;
w15<= weight_out(29 downto 28) ;
w16<= weight_out(31 downto 30) ;
w17<= weight_out(33 downto 32) ;
w18<= weight_out(35 downto 34) ;
w19<= weight_out(37 downto 36) ;
w20<= weight_out(39 downto 38) ;
w21<= weight_out(41 downto 40) ;
w22<= weight_out(43 downto 42) ;
w23<= weight_out(45 downto 44) ;
w24<= weight_out(47 downto 46) ;
w25<= weight_out(49 downto 48) ;
w26<= weight_out(51 downto 50) ;
w27<= weight_out(53 downto 52) ;
w28<= weight_out(55 downto 54) ;
w29<= weight_out(57 downto 56) ;
w30<= weight_out(59 downto 58) ;
w31<= weight_out(61 downto 60) ;
w32<= weight_out(63 downto 62) ;
w33<= weight_out(65 downto 64) ;
w34<= weight_out(67 downto 66) ;
w35<= weight_out(69 downto 68) ;
w36<= weight_out(71 downto 70) ;

c1:conv port map(ready,d1,d2,d3,d4,d5,d6,d7,d8,d9,w1,w2,w3,w4,w5,w6,w7,w8,w9,y1);
c2:conv port map(ready,d10,d11,d12,d13,d14,d15,d16,d17,d18,w10,w11,w12,w13,w14,w15,w16,w17,w18,y2);
c3:conv port map(ready,d19,d20,d21,d22,d23,d24,d25,d26,d27,w19,w20,w21,w22,w23,w24,w25,w26,w27,y3);
c4:conv port map(ready,d28,d29,d30,d31,d32,d33,d34,d35,d36,w28,w29,w30,w31,w32,w33,w34,w35,w36,y4);

process(clk,rst_n)
begin
	if(rst_n='0')then
		ok1<='0';
		ok2<='0';
	elsif(rising_edge(clk))then
		ok1<=ready;
		if(stop2='1')then
			ok2<='0';
		else
			ok2<=ok1;
		end if;
	end if;
end process;

process(clk,rst_n)
begin
	if(rst_n='0')then
		stop1<='0';
		stop12<='0';
		stop2<='0';
	elsif(rising_edge(clk))then
		stop1<=conv_stop;
		stop12<=stop1;
		stop2<=stop12;
	end if;
end process;


process(ok1,rst_n)
begin
	if(rst_n='0')then
		y_out<="00000000000000";
	elsif(rising_edge(ok1))then
		y_out<=y1+y2+y3+y4;
		
	end if;
end process;

process(y_out)
begin
	if(y_out(13 downto 7)="0000000")then
		y_co<=y_out(7 downto 0); --姝ｆ暟娌℃湁瓒呯晫
	elsif(y_out(13)='0'and y_out(12 downto 7)/="000000")then
		y_co<="01111111";  --姝ｆ暟瓒呯晫
	elsif(y_out(13 downto 7)="1111111")then
		y_co<='1'& y_out(6 downto 0); --璐熸暟鐨勮祴鍊兼柟娉?
	else
		y_co<='1'& "0000000";
	end if;
	
end process;

process(y1)
begin
	if(layer="0001")then
		if(y1(13 downto 7)="0000000")then
			y_co1<=y1(7 downto 0); --姝ｆ暟娌℃湁瓒呯晫
		elsif(y1(13)='0'and y1(12 downto 7)/="000000")then
			y_co1<="01111111";  --姝ｆ暟瓒呯晫
		elsif(y1(13 downto 7)="1111111")then
			y_co1<='1'& y1(6 downto 0); --璐熸暟鐨勮祴鍊兼柟娉?
		else
			y_co1<='1'& "0000000";
		end if;
	else
		y_co1<=x"00";
		
	end if;
end process;

process(y2)
begin
	if(layer="0001")then
		if(y2(13 downto 7)="0000000")then
			y_co2<=y2(7 downto 0); --姝ｆ暟娌℃湁瓒呯晫
		elsif(y2(13)='0'and y2(12 downto 7)/="000000")then
			y_co2<="01111111";  --姝ｆ暟瓒呯晫
		elsif(y2(13 downto 7)="1111111")then
			y_co2<='1'& y2(6 downto 0); --璐熸暟鐨勮祴鍊兼柟娉?
		else
			y_co2<='1'& "0000000";
		end if;
	else
		y_co2<=x"00";
		end if;
	
end process;

process(y3)
begin
	if(layer="0001")then
		if(y3(13 downto 7)="0000000")then
			y_co3<=y3(7 downto 0); --姝ｆ暟娌℃湁瓒呯晫
		elsif(y3(13)='0'and y3(12 downto 7)/="000000")then
			y_co3<="01111111";  --姝ｆ暟瓒呯晫
		elsif(y3(13 downto 7)="1111111")then
			y_co3<='1'& y3(6 downto 0); --璐熸暟鐨勮祴鍊兼柟娉?
		else
			y_co3<='1'& "0000000";
		end if;
	else
		y_co3<=x"00";
	
	end if;
end process;

process(y4)
begin
	if(layer="0001")then
		if(y4(13 downto 7)="0000000")then
			y_co4<=y4(7 downto 0); --姝ｆ暟娌℃湁瓒呯晫
		elsif(y4(13)='0'and y4(12 downto 7)/="000000")then
			y_co4<="01111111";  --姝ｆ暟瓒呯晫
		elsif(y4(13 downto 7)="1111111")then
			y_co4<='1'& y4(6 downto 0); --璐熸暟鐨勮祴鍊兼柟娉?
		else
			y_co4<='1'& "0000000";
		end if;
	else
		y_co4<=x"00";
		
	end if;
end process;
		


data_out<=y_co;
finish<=ok2;

data_out1<=y_co1;
data_out2<=y_co2;
data_out3<=y_co3;
data_out4<=y_co4;

end behav;


-------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

---池化+relu进行输出

entity pool2d is
	port(
		layer:in std_logic_vector(3 downto 0);    --3/6/8
		clk:in std_logic;
		rst_n:in std_logic;
		ready:in std_logic;
		maxpool_over:in std_logic;
		data_in1:in std_logic_vector(7 downto 0);
		data_in2:in std_logic_vector(7 downto 0);
		data_in3:in std_logic_vector(7 downto 0);
		data_in4:in std_logic_vector(7 downto 0);
		data_out1:out std_logic_vector(7 downto 0);
		data_out2:out std_logic_vector(7 downto 0);
		data_out3:out std_logic_vector(7 downto 0);
		data_out4:out std_logic_vector(7 downto 0);
		finish:out std_logic
	);
	
end entity;


architecture behav of pool2d is

component maxpool_one is
	port(
		layer:in std_logic_vector(3 downto 0);    --3/6
		maxpool_over:in std_logic;
		clk:in std_logic;
		rst_n:in std_logic;
		ready:in std_logic;
		data_in: in std_logic_vector(7 downto 0);
		data_out:out std_logic_vector(7 downto 0);
		finish:out std_logic
		
	);

end component;
signal finish2:std_logic;
signal finish3:std_logic;
signal finish4:std_logic;

begin

u0:maxpool_one
	port map(layer,maxpool_over,clk,rst_n,ready,data_in1,data_out1,finish);

u1:maxpool_one
	port map(layer,maxpool_over,clk,rst_n,ready,data_in2,data_out2,finish2);

u2:maxpool_one
	port map(layer,maxpool_over,clk,rst_n,ready,data_in3,data_out3,finish3);

u3:maxpool_one
	port map(layer,maxpool_over,clk,rst_n,ready,data_in4,data_out4,finish4);


end behav;

--------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

--池化+relu激活

entity maxpool_one is
	port(
		layer:in std_logic_vector(3 downto 0);    --3/6
		maxpool_over:in std_logic;
		clk:in std_logic;
		rst_n:in std_logic;
		ready:in std_logic;
		data_in: in std_logic_vector(7 downto 0);
		data_out:out std_logic_vector(7 downto 0);
		finish:out std_logic
		
	);

end entity;

architecture behav of maxpool_one is

signal cnt_num:integer;
signal cnt:integer;
signal start:std_logic;
signal y_tmp_max:std_logic_vector(7 downto 0);
signal y_max:std_logic_vector(7 downto 0);
signal finish1:std_logic;
signal finish2:std_logic;
signal addr_max:std_logic_vector(9 downto 0);
signal add_en:std_logic_vector(9 downto 0);
signal stop1:std_logic;
signal stop2:std_logic;



constant num1:integer:=783;
constant num2:integer:=195;

begin

process(ready,rst_n)
begin
	if(rst_n='0')then
		start<='0';
	elsif(rising_edge(ready))then
		start<='1';
	end if;
end process;

process(clk,rst_n)
begin
	if(rst_n='0')then
		cnt<=0;
		y_tmp_max<=x"00";
	elsif(rising_edge(clk))then
		if(ready='1')then
			if(data_in>y_tmp_max and cnt/=cnt_num)then
				y_tmp_max<=data_in;
				cnt<=cnt+1;
				finish1<='0';
			elsif(data_in>y_tmp_max and cnt=cnt_num)then
				y_max<=data_in;
				cnt<=0;
				y_tmp_max<=x"00";
				finish1<='1';
			elsif(data_in<=y_tmp_max and cnt=cnt_num)then
				y_max<=y_tmp_max;
				cnt<=0;
				y_tmp_max<=x"00";
				finish1<='1';
			else
				cnt<=cnt+1;
				finish1<='0';
			end if;
		else
			finish1<='0';
			cnt<=0;	
		end if;
	end if;
end process;

process(clk,rst_n)
begin
	if(rst_n='0')then
		finish2<='0';
	elsif(rising_edge(clk))then
		if(stop2='1')then
			finish2<='0';
		else
			finish2<=finish1;
		end if;
		finish<=finish2;
	end if;
end process;

process(clk,rst_n)
begin
	if(rst_n='0')then
		stop1<='0';
		stop2<='0';
	elsif(rising_edge(clk))then
		stop1<=maxpool_over;
		stop2<=stop1;
	end if;
end process;



data_out<=y_max;
cnt_num<=48 when layer="1000" else 3;

end behav;


-------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
entity ftoe is
	port(
		is_size7:in std_logic; --7*7 or 14*14
		clk:in std_logic;
		rst_n:in std_logic;
		data_in:in std_logic_vector(7 downto 0);
		is_onetofour:in std_logic; --是前四个通道还是后四个通道
		ready:in std_logic;
		data_out:out std_logic_vector(7 downto 0);
		finish:out std_logic
	);
end entity;

architecture behav of ftoe is

constant matrix_num1 :integer:=195; --定义数组大小
constant matrix_num2 :integer:=48;

type output_array is array (matrix_num1 downto 0) of std_logic_vector(8 downto 0);

signal y_tmp:output_array;
signal y_t: std_logic_vector(8 downto 0);
signal y_tmp1: std_logic_vector(8 downto 0);
signal y_tmp2: std_logic_vector(8 downto 0);
signal y_out: std_logic_vector(7 downto 0);
signal ready1:std_logic;
signal ready2:std_logic;


begin

process(ready,rst_n) 
    --循环变量定义并初始化
    variable i: integer := 0;
	 variable j: integer :=0;
	 variable tmp:output_array;
    begin 
      if (rst_n = '0')then 
        i := 0;  
        --利用while loop循环赋值
        while(i<=matrix_num1) loop 
          y_tmp(i) <="000000000";
			 tmp(i):="000000000";
          i := i+1;
        end loop;
		 elsif(rising_edge(ready))then
			if(is_onetofour='1')then
				y_tmp(j)<=y_t;
				if (is_size7='1' and j=matrix_num2)then
					j:=0;
				elsif(is_size7='0' and j=matrix_num1)then
					j:=0;
				else
					j:=j+1;	
				end if;
			end if;
      end if;
end process;

process(ready,rst_n)
begin
	if(rst_n='0')then
		y_tmp1<="000000000";
	elsif(rising_edge(ready))then
		if(is_onetofour='0')then
			y_tmp1<=y_t;
		else
			y_tmp1<=y_tmp1;
		end if;
	end if;
end process;


process(ready2)

variable i :integer:=0;
variable tm:std_logic_vector(8 downto 0);

begin
	if(rising_edge(ready2))then
	if(is_onetofour='0')then
		tm:=y_tmp(i);
		y_tmp2<=tm+y_tmp1;
		if (is_size7='1' and i=matrix_num2)then
				i:=0;
		elsif(is_size7='0' and i=matrix_num1)then
				i:=0;
		else
				i:=i+1;		
		end if;
	end if;
	end if;
	
end process;

process(clk,rst_n)
begin
	if(rst_n='0')then
		ready1<='0';
		ready2<='0';
	elsif(rising_edge(clk))then
		if(is_onetofour='0')then
		ready1<=ready;
		ready2<=ready1;
		end if;
	end if;
end process;

y_t<='0'& data_in when data_in(7)='0' else '1' & data_in;


with y_tmp2(8 downto 7) select
data_out<=y_tmp2(7 downto 0) when "00",
			"01111111" when "01",
			'1' & y_tmp2(6 downto 0) when "11",
			"10000000" when "10",
			unaffected when others;

finish<=ready2;
	
end behav;

-------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity sig_select is
	port(
		layer:in std_logic_vector(3 downto 0);
		data_out1:in std_logic_vector(7 downto 0);
		data_out2:in std_logic_vector(7 downto 0);
		finish1:in std_logic;
		finish2:in std_logic;
		data_out_select:out std_logic_vector(7 downto 0);
		finish_select:out std_logic
	);
end entity;

architecture dataflow of sig_select is

begin
finish_select<=finish1 when (layer="0111" or layer="0101") else finish2;

data_out_select<=data_out1 when (layer="0111" or layer="0101") else data_out2;

end dataflow;


-------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity result_select is
	port(
		layer:in std_logic_vector(3 downto 0);
		conv_finish:in std_logic;
		pool_finish:in std_logic;
		finish_select:in std_logic;
		conv_data, conv_data1, conv_data2, conv_data3, conv_data4, data_out_select:in std_logic_vector(7 downto 0);
		pool_data1, pool_data2, pool_data3, pool_data4:in std_logic_vector(7 downto 0);
		once_finish:out std_logic;
		finish:out std_logic;
		data_out, data_out1, data_out2, data_out3, data_out4:out std_logic_vector(7 downto 0)
	);
end entity;

architecture dataflow of result_select is
begin
process(layer, conv_finish, pool_finish)
begin
case(layer) IS
when "0001"|"0010"|"0100"|"0101"|"0111"=> once_finish <= conv_finish;
when "0011"|"0110"|"1000" => once_finish <= pool_finish;
when others=>once_finish<='0';
end case;
end process;

process(layer, conv_finish, pool_finish, finish_select)
begin
case(layer) is
when "0001"|"0010"|"0100" => finish <= conv_finish;
when "0011"|"0110"|"1000" => finish <= pool_finish;
when "0101"|"0111" => finish <= finish_select;
when others => finish <= '0';
end case;
end process;

process(layer, conv_data, data_out_select)
begin
case(layer) is
when "0010"|"0100" => data_out <= conv_data;
when "0101"|"0111" => data_out <= data_out_select;
when others => data_out <= (others=>'0');
end case;
end process;

process(layer, conv_data1, pool_data1)
begin
case(layer) is
when "0001" => data_out1 <= conv_data1;
when "0011"|"0110"|"1000" => data_out1 <= pool_data1;
when others => data_out1 <= (others=>'0');
end case;
end process;

process(layer, conv_data2, pool_data2)
begin
case(layer) is
when "0001" => data_out2 <= conv_data2;
when "0011"|"0110"|"1000" => data_out2 <= pool_data2;
when others => data_out2 <= (others=>'0');
end case;
end process;

process(layer, conv_data3, pool_data3)
begin
case(layer) is
when "0001" => data_out3 <= conv_data3;
when "0011"|"0110"|"1000" => data_out3 <= pool_data3;
when others => data_out3 <= (others=>'0');
end case;
end process;

process(layer, conv_data4, pool_data4)
begin
case(layer) is
when "0001" => data_out4 <= conv_data4;
when "0011"|"0110"|"1000" => data_out4 <= pool_data4;
when others => data_out4 <= (others=>'0');
end case;
end process;
end dataflow;