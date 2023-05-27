library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;

entity wr_control is
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	finish:in std_logic;
	layer:in std_logic_vector(3 DOWNTO 0);
	data_out:in std_logic_vector(7 downto 0);
	data_out1, data_out2, data_out3, data_out4:in std_logic_vector(7 downto 0);
	wr_addr:out std_logic_vector(9 DOWNTO 0);
	wr_data_a, wr_data_b, wr_data_c, wr_data_d:out  std_logic_vector (7 downto 0);
	wr_en_ain,wr_en_bin,wr_en_cin,wr_en_din:out std_logic;
	wr_en_aout1,wr_en_bout1,wr_en_cout1,wr_en_dout1:out std_logic;
	wr_en_aout2,wr_en_bout2,wr_en_cout2,wr_en_dout2:out std_logic;
	layer_done:out std_logic
	);
end entity;

architecture behav of wr_control is

signal rel_addr:std_logic_vector(9 downto 0):="0000000000";
signal wr_en_group1, wr_en1:std_logic;
signal wr_en_group2, wr_en2:std_logic;
signal wr_en_group3, wr_en3:std_logic;
signal layer_over, channel_over:std_logic;
signal delay:std_logic_vector(6 downto 0);
signal current_channel:std_logic_vector(3 downto 0):="0000";
signal delay_channel:std_logic_vector(5 downto 0):="000000";
signal data:std_logic_vector (7 downto 0);
signal matrix2_out:std_logic_vector(9 DOWNTO 0);
signal out_channel:std_logic_vector(3 DOWNTO 0);
signal start_wr_addr:std_logic_vector(9 DOWNTO 0);
signal data_a, data_b ,data_c, data_d:std_logic_vector(7 downto 0):="00000000";
signal data_1,data_2,data_3,data_4,data_5:std_logic_vector(7 downto 0):="00000000";

begin

data_1<=data_out when data_out(7)='0' else "00000000";
data_2<=data_out1 when data_out1(7)='0' else "00000000";
data_3<=data_out2 when data_out2(7)='0' else "00000000";
data_4<=data_out3 when data_out3(7)='0' else "00000000";
data_5<=data_out4 when data_out4(7)='0' else "00000000";

------------------wr_dara/wr_en-------------------------
PROCESS(clk)
begin
if rst_n='0' then
	wr_en_group1 <= '0';
	wr_en_group2 <= '0';
	wr_en_group3 <= '0';
elsif(rising_edge(clk))then
	wr_en_group1 <= wr_en1;
	wr_en_group2 <= wr_en2;
	wr_en_group3 <= wr_en3;
end if;
end process;

PROCESS(clk)
begin
if rst_n='0' then
	wr_en1 <= '0';
	wr_en2 <= '0';
	wr_en3 <= '0';
elsif(rising_edge(clk))then
	if finish='1' then
		case(layer) is
			when "0001"|"0100"|"0111" => wr_en2 <= '1';wr_en1 <= '0';wr_en3 <= '0';
			when "0010"|"0101" => wr_en3 <= '1';wr_en1 <= '0';wr_en2 <= '0';
			when "0011"|"0110" => wr_en1 <= '1';wr_en2 <= '0';wr_en3 <= '0';
			when others=>wr_en1 <= '0';wr_en2 <= '0';wr_en3 <= '0';
		end case;
	else wr_en1 <= '0';wr_en2 <= '0';wr_en3 <= '0';
	end if;
end if;
end process;

PROCESS(clk, rst_n)
begin
if rst_n='0' then
	wr_en_aout1 <= '0';wr_en_aout2 <= '0';wr_en_ain <= '0';data_a <= (others=>'0');
	wr_en_bout1 <= '0';wr_en_bout2 <= '0';wr_en_bin <= '0';data_b <= (others=>'0');
	wr_en_cout1 <= '0';wr_en_cout2 <= '0';wr_en_cin <= '0';data_c <= (others=>'0');
	wr_en_dout1 <= '0';wr_en_dout2 <= '0';wr_en_din <= '0';data_d <= (others=>'0');
elsif rising_edge(clk) then
case(layer) is
when "0001"|"0011"|"0110" =>
		data_a <= data_2 ; wr_en_aout1 <= wr_en_group2;wr_en_ain <= wr_en_group1;wr_en_aout2 <= '0';
		data_b <= data_3 ; wr_en_bout1 <= wr_en_group2;wr_en_bin <= wr_en_group1;wr_en_bout2 <= '0';
		data_c <= data_4 ; wr_en_cout1 <= wr_en_group2;wr_en_cin <= wr_en_group1;wr_en_cout2 <= '0';
		data_d <= data_5 ; wr_en_dout1 <= wr_en_group2;wr_en_din <= wr_en_group1;wr_en_dout2 <= '0';
when "0010"|"0100"|"0101"|"0111" =>
	case(current_channel) is
		when "0000"|"0100"|"1000"|"1100" => data_a <= data_1 ; wr_en_aout2 <= wr_en_group3;wr_en_aout1 <= wr_en_group2;
							wr_en_bout1 <= '0';wr_en_bout2 <= '0';wr_en_bin <= '0';wr_en_ain <= '0';
							wr_en_cout1 <= '0';wr_en_cout2 <= '0';wr_en_cin <= '0';
							wr_en_dout1 <= '0';wr_en_dout2 <= '0';wr_en_din <= '0';
		when "0001"|"0101"|"1001"|"1101" => data_b <= data_1 ; wr_en_bout2 <= wr_en_group3;wr_en_bout1 <= wr_en_group2;
							wr_en_aout1 <= '0';wr_en_aout2 <= '0';wr_en_ain <= '0';wr_en_bin <= '0';
							wr_en_cout1 <= '0';wr_en_cout2 <= '0';wr_en_cin <= '0';
							wr_en_dout1 <= '0';wr_en_dout2 <= '0';wr_en_din <= '0';
		when "0010"|"0110"|"1010"|"1110" => data_c <= data_1 ; wr_en_cout2 <= wr_en_group3;wr_en_cout1 <= wr_en_group2;
							wr_en_aout1 <= '0';wr_en_aout2 <= '0';wr_en_ain <= '0';wr_en_cin <= '0';
							wr_en_bout1 <= '0';wr_en_bout2 <= '0';wr_en_bin <= '0';
							wr_en_dout1 <= '0';wr_en_dout2 <= '0';wr_en_din <= '0';
		when "0011"|"0111"|"1011"|"1111" => data_d <= data_1 ; wr_en_dout2 <= wr_en_group3;wr_en_dout1 <= wr_en_group2;
							wr_en_aout1 <= '0';wr_en_aout2 <= '0';wr_en_ain <= '0';wr_en_din <= '0';
							wr_en_bout1 <= '0';wr_en_bout2 <= '0';wr_en_bin <= '0';
							wr_en_cout1 <= '0';wr_en_cout2 <= '0';wr_en_cin <= '0';
		when others => data_a <= (others=>'0') ;data_b <= (others=>'0') ;data_c <= (others=>'0') ;data_d <= (others=>'0') ;
	end case;
when others=>	wr_en_aout1 <= '0';wr_en_aout2 <= '0';wr_en_ain <= '0';
				wr_en_bout1 <= '0';wr_en_bout2 <= '0';wr_en_bin <= '0';
				wr_en_cout1 <= '0';wr_en_cout2 <= '0';wr_en_cin <= '0';
				wr_en_dout1 <= '0';wr_en_dout2 <= '0';wr_en_din <= '0';
end case;
end if;
end process;

process(clk)
begin
if rst_n='0' then
	wr_data_a <= (others=>'0');
	wr_data_b <= (others=>'0');
	wr_data_c <= (others=>'0');
	wr_data_d <= (others=>'0');
elsif rising_edge(clk) then
	wr_data_a <= data_a;
	wr_data_b <= data_b;
	wr_data_c <= data_c;
	wr_data_d <= data_d;
end if;
end process;
---------------------------current_channel/layer_done---------------------
PROCESS(clk)
begin
if rst_n='0' then
	channel_over <= '0';
	layer_over <= '0';
elsif(rising_edge(clk))then
	if finish='1' then
		if rel_addr=matrix2_out then
			channel_over <= '1';
			if current_channel=out_channel then
				layer_over <= '1';
			else layer_over <= '0';
			end if;
			else channel_over <= '0';layer_over <= '0';
		end if;
	else channel_over <= '0';layer_over <= '0';
	end if;
end if;
end process;

process(clk)
begin
if rst_n='0' then
	current_channel <= "0000";
elsif rising_edge(clk) then
	if delay_channel(5)='1' then
		current_channel <= current_channel + '1';
	elsif delay(6) = '1' then
		current_channel <= "0000";
	end if;
end if;
end process;

process(clk)
begin
if rst_n='0' then
	delay <= "0000000";
	delay_channel <="000000";
elsif rising_edge(clk) then
	delay_channel(0) <= channel_over;
	delay(0) <= layer_over;
	delay(6 downto 1) <= delay(5 downto 0);
	delay_channel(5 downto 1) <= delay_channel(4 downto 0);
end if;
end process;
layer_done <= delay(6);


-----------------------matrix2_out/out_channel--------------------
process(layer)
begin
case(layer) is
when "0001"|"0010" => matrix2_out <= "1100001111";--783/255
when "0011"|"0100"|"0101" => matrix2_out <= "0011000011";--195/63
when "0110"|"0111" => matrix2_out <= "0000110000";--48/15
when others => matrix2_out <= (others=>'0');
end case;
end process;

process(layer)
begin
case(layer) is
when "0001"|"0011" => out_channel <= "0000";--1
when "0010" => out_channel <= "0011";--4
when "0100"|"0101" => out_channel <= "0111";--8
when "0110" => out_channel <= "0001";--2
when "0111" => out_channel <= "1111";--16
when "1000" => out_channel<="0011";
when others => out_channel <= (others=>'0');
end case;
end process;
-------------------wr_address----------------------------
process(clk)
begin
if rst_n='0' then
 rel_addr <= "0000000000";
elsif(rising_edge(clk))then
 if delay(6)='0' then
  if(finish='1')then
   if (rel_addr /= matrix2_out+'1') then
    rel_addr <= rel_addr + '1';
   else rel_addr <= "0000000001";
   end if;
  end if;
 else rel_addr <= "0000000000";
end if;
end if;
end process;

process(layer)
begin
case(layer) is
when "0001"|"0010"|"0011" => start_wr_addr <= (others=>'0');
when "0100"|"0101" => 
	case(current_channel) is
		when "0000"|"0001"|"0010"|"0011" => start_wr_addr <= (others=>'0');
		when "0100"|"0101"|"0110"|"0111" => start_wr_addr <= "0110001000"; -- 392
		when others => start_wr_addr <= (others=>'0') ;
	end case;
when "0110" => 
	case(current_channel) is
		when "0000" => start_wr_addr <= (others=>'0');
		when "0001" => start_wr_addr <= "0110001000"; -- 392
		when others => start_wr_addr <= (others=>'0') ;
	end case;
when "0111" => 
	case(current_channel) is
		when "0000"|"0001"|"0010"|"0011" => start_wr_addr <= (others=>'0');
		when "0100"|"0101"|"0110"|"0111" => start_wr_addr <= "0011000100"; -- 196
		when "1000"|"1001"|"1010"|"1011" => start_wr_addr <= "0110001000"; -- 392
		when "1100"|"1101"|"1110"|"1111" => start_wr_addr <= "1001001100"; -- 588
		when others => start_wr_addr <= (others=>'0') ;
	end case;
when others => start_wr_addr <= (others=>'0');
end case;
end process;
wr_addr <= start_wr_addr + rel_addr - '1';
-----------------------------------------------------------
end behav;

