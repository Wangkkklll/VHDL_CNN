library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;


entity conv is
	port(
		ready:in std_logic;
		d1,d2,d3,d4,d5,d6,d7,d8,d9:in std_logic_vector(7 downto 0);
		w1,w2,w3,w4,w5,w6,w7,w8,w9:in std_logic_vector(1 downto 0);
		y:out std_logic_vector(13 downto 0) --conv_output	
	);
	
end entity;

architecture behav of conv is



signal y_tmp1:std_logic_vector(11 downto 0);
signal y_tmp2:std_logic_vector(13 downto 0);
signal fini:std_logic;

signal w_1,w_2,w_3,w_4,w_5,w_6,w_7,w_8,w_9:std_logic_vector(3 downto 0);

begin
	process(ready)
	begin
		if(rising_edge(ready))then
			
			y_tmp1<=d1*w_1+d2*w_2+d3*w_3+d4*w_4+d5*w_5+d6*w_6+d7*w_7+d8*w_8+d9*w_9;
		end if;
	end process;
	
	process(y_tmp1)
	begin
		if(y_tmp1(11)='0')then
			y_tmp2<="00"& y_tmp1;
		else
			y_tmp2<="11"& y_tmp1;
		end if;
	end process;


y<=y_tmp2;
w_1<="11"& w1 when w1="11" else "00"& w1;
w_2<="11"& w2 when w2="11" else "00"& w2;
w_3<="11"& w3 when w3="11" else "00"& w3;
w_4<="11"& w4 when w4="11" else "00"& w4;
w_5<="11"& w5 when w5="11" else "00"& w5;
w_6<="11"& w6 when w6="11" else "00"& w6;
w_7<="11"& w7 when w7="11" else "00"& w7;
w_8<="11"& w8 when w8="11" else "00"& w8;
w_9<="11"& w9 when w9="11" else "00"& w9;
	
end behav;
