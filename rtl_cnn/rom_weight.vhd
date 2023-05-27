--从ROM读取数据，时序正确
-------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;

entity rom_weight is
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	load_ready:in std_logic;
	w_start_addr:in std_logic_vector(11 DOWNTO 0);
	--w1, w2 ,w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18:out std_logic_vector(1 DOWNTO 0);
	--w19, w20 ,w21, w22, w23, w24, w25, w26, w27, w28, w29, w30, w31, w32, w33, w34, w35, w36:out std_logic_vector(1 DOWNTO 0);
	weight_out:out std_logic_vector(71 downto 0);
	w_pre_ready:out std_logic
	);
end entity;

architecture behav of rom_weight is

COMPONENT w_buffer
	port(
	clk:in std_logic;
	clk_en:in std_logic;
	weight:in STD_LOGIC_VECTOR (1 DOWNTO 0);
	--w1, w2 ,w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18:out std_logic_vector(1 DOWNTO 0);
	--w19, w20 ,w21, w22, w23, w24, w25, w26, w27, w28, w29, w30, w31, w32, w33, w34, w35, w36:out std_logic_vector(1 DOWNTO 0);
	weight_out:out std_logic_vector(71 downto 0);
	w_pre_ready:out std_logic
	);
end COMPONENT;

COMPONENT weight_addr_ctrl
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	ready:in std_logic;
	w_start_addr:in std_logic_vector(11 DOWNTO 0);
	addr:out std_logic_vector(11 DOWNTO 0);
	clk_en:out std_logic
	);
end COMPONENT;

comPONENT rom_read IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		rden		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
	);
END comPONENT;
signal addr:std_logic_vector(11 DOWNTO 0);
signal clk_en:std_logic;
signal data:STD_LOGIC_VECTOR (1 DOWNTO 0);
begin

U0:weight_addr_ctrl
	PORT map(clk, rst_n, load_ready, w_start_addr, addr, clk_en);
U1:w_buffer
	PORT map(clk, clk_en, data, weight_out, w_pre_ready);
rom_read_inst : rom_read 
	PORT MAP (
		address	 => addr,
		clock	 => clk,
		rden => clk_en,
		q	 => data
	);

end behav;

---------------------------------------------------------------------
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;
--USE IEEE.std_logic_unsigned.All; error:Error (10621): VHDL Use Clause error at conv.vhd(55): 
--more than one Use Clause imports a declaration of simple name ""="" -- none of the declarations are directly visible

entity weight_addr_ctrl is
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	ready:in std_logic;
	w_start_addr:in std_logic_vector(11 DOWNTO 0);
	addr:out std_logic_vector(11 DOWNTO 0);
	clk_en:out std_logic
	);
end entity;

architecture behav of weight_addr_ctrl is
signal w_num:std_logic_vector(6 DOWNTO 0):="0000000";
begin
PROCESS(clk,rst_n)
variable stay:std_logic:='0';
begin
if rst_n='0' then
	w_num <= (others=>'0');
	clk_en <='0';
	stay :='0';
elsif(rising_edge(clk))then
	if ready='1' then
		stay :='1';
	end if;
	if stay='1' then
		if w_num="0100101" then
			clk_en <='0';
			w_num <= "0000000";
			stay :='0'; 
		else
			w_num <= w_num + '1';clk_en <='1';
		end if;
	else clk_en <='0';
	end if;
end if;
end process;
addr <= w_start_addr + w_num -'1';
end behav;
-------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;
--USE IEEE.std_logic_unsigned.All; error:Error (10621): VHDL Use Clause error at conv.vhd(55): 
--more than one Use Clause imports a declaration of simple name ""="" -- none of the declarations are directly visible


entity w_buffer is
	port(
	clk:in std_logic;
	clk_en:in std_logic;
	--address: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
	weight:in STD_LOGIC_VECTOR (1 DOWNTO 0);
	--w1, w2 ,w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18:out std_logic_vector(1 DOWNTO 0);
	--w19, w20 ,w21, w22, w23, w24, w25, w26, w27, w28, w29, w30, w31, w32, w33, w34, w35, w36:out std_logic_vector(1 DOWNTO 0);
	weight_out:out std_logic_vector(71 downto 0);
	w_pre_ready:out std_logic
	);
end entity;

architecture behav of w_buffer is
signal times:std_logic_vector(5 DOWNTO 0):="000000";
begin

process(clk, weight)
begin
if(rising_edge(clk))then
	if clk_en='1' then
		case(times) is
			when "000001"=> weight_out(1 downto 0)<=weight;
			when "000010"=> weight_out(3 downto 2)<=weight;
			when "000011"=> weight_out(5 downto 4)<=weight;
			when "000100"=> weight_out(7 downto 6)<=weight;
			when "000101"=> weight_out(9 downto 8)<=weight;
			when "000110"=> weight_out(11 downto 10)<=weight;
			when "000111"=> weight_out(13 downto 12)<=weight;
			when "001000"=> weight_out(15 downto 14)<=weight;
			when "001001"=> weight_out(17 downto 16)<=weight;
			when "001010"=> weight_out(19 downto 18)<=weight;
			when "001011"=> weight_out(21 downto 20)<=weight;
			when "001100"=> weight_out(23 downto 22)<=weight;
			when "001101"=> weight_out(25 downto 24)<=weight;
			when "001110"=> weight_out(27 downto 26)<=weight;
			when "001111"=> weight_out(29 downto 28)<=weight;
			when "010000"=> weight_out(31 downto 30)<=weight;
			when "010001"=> weight_out(33 downto 32)<=weight;
			when "010010"=> weight_out(35 downto 34)<=weight;
			when "010011"=> weight_out(37 downto 36)<=weight;
			when "010100"=> weight_out(39 downto 38)<=weight;
			when "010101"=> weight_out(41 downto 40)<=weight;
			when "010110"=> weight_out(43 downto 42)<=weight;
			when "010111"=> weight_out(45 downto 44)<=weight;
			when "011000"=> weight_out(47 downto 46)<=weight;
			when "011001"=> weight_out(49 downto 48)<=weight;
			when "011010"=> weight_out(51 downto 50)<=weight;
			when "011011"=> weight_out(53 downto 52)<=weight;
			when "011100"=> weight_out(55 downto 54)<=weight;
			when "011101"=> weight_out(57 downto 56)<=weight;
			when "011110"=> weight_out(59 downto 58)<=weight;
			when "011111"=> weight_out(61 downto 60)<=weight;
			when "100000"=> weight_out(63 downto 62)<=weight;
			when "100001"=> weight_out(65 downto 64)<=weight;
			when "100010"=> weight_out(67 downto 66)<=weight;
			when "100011"=> weight_out(69 downto 68)<=weight;
			when "100100"=> weight_out(71 downto 70)<=weight;
			when others =>NULL;
		end case;
		if times="100100" then
			times<="000000";
			w_pre_ready <= '1';
		else times<=times+'1';
		w_pre_ready <= '0';
		end if;
	else times<="000000";w_pre_ready<='0';
end if;
end if;
end process;

end behav;

