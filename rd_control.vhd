----------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;
--USE IEEE.std_logic_unsigned.All; error:Error (10621): VHDL Use Clause error at conv.vhd(55): 
--more than one Use Clause imports a declaration of simple name ""="" -- none of the declarations are directly visible

entity rd_control is
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	w_pre_ready:in std_logic;
	pool_ready:in std_logic;
	gobal_ready:in std_logic;
	layer:in std_logic_vector(3 DOWNTO 0);
	pix_start_addr:in std_logic_vector(9 downto 0);
	rd_addr:out std_logic_vector(9 DOWNTO 0);
	group1_en, group2_en, group3_en:out std_logic;
	position_out:out std_logic_vector(3 DOWNTO 0);
	conv_over:out std_logic;
	maxpool_over:out std_logic;
	pool_start:out std_logic;
	conv_stop:out std_logic
	);
end entity;

architecture structure of rd_control is

COMPONENT conv_position
port(
clk:in std_logic;
rst_n:in std_logic;
w_pre_ready:in std_logic;
matrix_in:in std_logic_vector(5 DOWNTO 0);
i:out std_logic_vector(5 DOWNTO 0);
j:out std_logic_vector(5 DOWNTO 0);
position:out std_logic_vector(3 DOWNTO 0);
conv_over:out std_logic;
conv_stop:out std_logic
);
END COMPONENT;

COMPONENT conv_ctrl
port(
clk:in std_logic;
rst_n:in std_logic;
w_pre_ready:in std_logic;
position:in std_logic_vector(3 DOWNTO 0);
matrix_in:in std_logic_vector(5 downto 0);
i:in std_logic_vector(5 DOWNTO 0);
j:in std_logic_vector(5 DOWNTO 0);
pix_start_addr:in std_logic_vector(9 downto 0);
pixel_read_address:out std_logic_vector(9 DOWNTO 0);
rd_en_conv:out std_logic;
conv_stop:in std_logic
);
END COMPONENT;

COMPONENT maxpool_ctrl
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	pool_ready:in std_logic;
	matrix_in:in std_logic_vector(5 downto 0);
	pix_start_addr:in std_logic_vector(9 DOWNTO 0);
	maxpool_read_address:out std_logic_vector(9 DOWNTO 0);
	rd_en_pool:out std_logic;
	maxpool_over:out std_logic
	);
end COMPONENT;

COMPONENT gobal_maxpool_ctrl
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	gobal_ready:in std_logic;
	matrix_in:in std_logic_vector(5 downto 0);
	pix_start_addr:in std_logic_vector(9 DOWNTO 0);
	gobalpool_read_address:out std_logic_vector(9 DOWNTO 0);
	rd_en_gobalpool:out std_logic;
	maxpool_over:out std_logic
	);
end COMPONENT;

COMPONENT rd_addr_enable
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	layer:in std_logic_vector(3 DOWNTO 0);
	conv_read_address:in std_logic_vector(9 DOWNTO 0);
	maxpool_read_address:in std_logic_vector(9 DOWNTO 0);
	gobalpool_read_address:in std_logic_vector(9 DOWNTO 0);
	rd_addr:out std_logic_vector(9 DOWNTO 0)
	);
end COMPONENT;

COMPONENT read_enable
port(
clk:in std_logic;
rst_n:in std_logic;
layer:in std_logic_vector(3 DOWNTO 0);
rd_en_conv:in std_logic;
rd_en_pool:in std_logic;
rd_en_gobalpool:in std_logic;
group1_en:out std_logic;
group2_en:out std_logic;
group3_en:out std_logic
);
end COMPONENT;

signal i, j :std_logic_vector(5 DOWNTO 0);
signal position:std_logic_vector(3 DOWNTO 0);
signal rd_en_conv, rd_en_gobalpool, rd_en_pool:std_logic;
signal conv_read_address, maxpool_read_address, gobalpool_read_address:std_logic_vector(9 DOWNTO 0);
signal maxpool_over1, maxpool_over2, stop_conv:std_logic;
signal matrix_in, real_matrix_in:std_logic_vector(5 DOWNTO 0);
begin
real_matrix_in <= matrix_in + '1';

U0:conv_position
	PORT map(clk, rst_n, w_pre_ready, matrix_in, i, j, position, conv_over, stop_conv);
U1: conv_ctrl
	PORT map(clk, rst_n, w_pre_ready, position, real_matrix_in, i, j, pix_start_addr, conv_read_address, rd_en_conv, stop_conv);
U2:read_enable
	PORT map(clk, rst_n, layer, rd_en_conv, rd_en_pool, rd_en_gobalpool, group1_en, group2_en, group3_en);
U3:maxpool_ctrl
	PORT map(clk, rst_n, pool_ready, matrix_in, pix_start_addr, maxpool_read_address, rd_en_pool, maxpool_over1);
U4:gobal_maxpool_ctrl
	PORT map(clk, rst_n, gobal_ready, matrix_in, pix_start_addr, gobalpool_read_address, rd_en_gobalpool, maxpool_over2);
U5:rd_addr_enable
	PORT map(clk, rst_n, layer, conv_read_address, maxpool_read_address, gobalpool_read_address, rd_addr);

pool_start <= '1' when (rd_en_pool = '1')or(rd_en_gobalpool = '1') else '0';
conv_stop <= stop_conv;
position_out <= position;

process(layer, maxpool_over1, maxpool_over2)
begin
case(layer) is
when "0011"|"0110" => maxpool_over <= maxpool_over1;
when "1000" => maxpool_over <= maxpool_over2;
when others => maxpool_over <= '0';
end case;
end process;

process(layer)
begin
case(layer) is
when "0001"|"0010" => matrix_in <= "011011";--27"011011"
when "0011" => matrix_in <= "011100";--28"011100"
when "0100"|"0101" => matrix_in <= "001101" ;--13"1101"
when "0110" => matrix_in <= "001110";--14"1110"
when "0111" => matrix_in <= "000110";--6
when "1000" => matrix_in <= "110001";--49
when others => matrix_in <= (others=>'0');
end case;
end process;
end structure;
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;
--USE IEEE.std_logic_unsigned.All; error:Error (10621): VHDL Use Clause error at conv.vhd(55): 
--more than one Use Clause imports a declaration of simple name ""="" -- none of the declarations are directly visible

entity conv_position is
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	w_pre_ready:in std_logic;
	matrix_in:in std_logic_vector(5 DOWNTO 0);
	i:out std_logic_vector(5 DOWNTO 0);
	j:out std_logic_vector(5 DOWNTO 0);
	position:out std_logic_vector(3 DOWNTO 0);
	conv_over:out std_logic;
	conv_stop:out std_logic
	);
end entity;

architecture behav of conv_position is
signal row:std_logic_vector(5 DOWNTO 0):="000000";
signal column:std_logic_vector(5 DOWNTO 0):="000000";
signal conv_position:std_logic_vector(3 DOWNTO 0):="0000";
signal over, stop, stop1, stop2, stay:std_logic:='0';

signal stop_delay:std_logic_vector(9 downto 0);

begin
PROCESS(clk)
--variable stay:std_logic:='0';
begin
if rst_n='0' then
	conv_position <= "0000";
	over<='0';
	stay <='0';
elsif(rising_edge(clk))then
	if w_pre_ready='1' then
		stay <='1';
	elsif stay='1' then
		if stop2='0' then
			if (conv_position="1000") then 
				conv_position <= "0000";
				over<='1';
			else 
				conv_position <= conv_position + '1';
				over<='0';
			end if;
		else
			conv_position <= "0000";
			over<='0';
			stay <= '0';
		end if;
	else 
		conv_position <= "0000";
		over<='0';
end if;
end if;
end process;

PROCESS(clk)
begin
if rst_n='0' then
	row <= "000000";
elsif(rising_edge(clk))then
	if stop2='0' then
		if (conv_position="1000") then 
			row <= row +'1';
			if (row=matrix_in) then
				row <= "000000";
			end if;
		else row <= row;
		end if;
	else row <= "000000";
	end if;
end if;
end process;

PROCESS(clk, row)
begin
if rst_n='0' then
	column <= "000000";
	stop <= '0';
elsif(rising_edge(clk))then
	if w_pre_ready='1' then
		stop <= '0';
	elsif (row=matrix_in)and(conv_position="1000") then
		column <= column + '1';
		if (column=matrix_in) then
			column <= "000000";
			stop <= '1';
		end if;
	else column <= column;
	end if;
end if;
end process;

process(clk)
variable cnt:integer:=0;
begin
if rst_n='0' then
	stop1 <= '0';
	stop2 <= '0';
	stop_delay<=(others=>'0');
elsif rising_edge(clk) then
	if w_pre_ready='1' then
		stop1 <= '0';
		stop2 <= '0';
		stop_delay<=(others=>'0');
		
	else
		stop1<=stop;
		stop2<=stop1;
		--stop_delay(0)<=stop2;
		--stop_delay(9 downto 1)<=stop_delay(8 downto 0);
	end if;
end if;
end process;
conv_stop <= stop2;
i <= row;
j <= column;
position <= conv_position;
conv_over<=over;
end behav;



-------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;
--USE IEEE.std_logic_unsigned.All; error:Error (10621): VHDL Use Clause error at conv.vhd(55): 
--more than one Use Clause imports a declaration of simple name ""="" -- none of the declarations are directly visible

entity conv_ctrl is
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	w_pre_ready:in std_logic;
	position:in std_logic_vector(3 DOWNTO 0);
	matrix_in:in std_logic_vector(5 DOWNTO 0);
	i:in std_logic_vector(5 DOWNTO 0);
	j:in std_logic_vector(5 DOWNTO 0);
	pix_start_addr:in std_logic_vector(9 downto 0);
	pixel_read_address:out std_logic_vector(9 DOWNTO 0);
	rd_en_conv:out std_logic;
	conv_stop:in std_logic
	);
end entity;

architecture behav of conv_ctrl is
signal stay:std_logic:='0';
begin
process(clk)
--variable stay:std_logic:='0';
variable conv_column:std_logic_vector(5 DOWNTO 0):="000000";
variable rel_position:std_logic_vector(3 DOWNTO 0):="0000";
variable addr:std_logic_vector(11 DOWNTO 0):="000000000000";

begin
if rst_n='0' then
	rd_en_conv <= '0';
	pixel_read_address <= (others=>'0');
	stay<='0';
elsif(rising_edge(clk))then
	if w_pre_ready='1' then
		stay <='1';
	end if;
	if stay='1' then
		if conv_stop='0' then
			rd_en_conv <= '1';
			if (j /= "000000")and((position="0000")or(position="0001")or(position="0010")) then
			conv_column := j - '1';
			elsif (j /= matrix_in)and((position="0110")or(position="0111")or(position="1000")) then
				  conv_column := j + '1';
			else  conv_column := j;
			end if;
			case(position)is
			when "0000"|"0011"|"0110"=> rel_position := "0000";
			when "0001"|"0100"|"0111"=> rel_position := "0001";
			when others=> rel_position := "0010";
			end case;
			if ((i="000000")and ((position="0000")or(position="0011")or(position="0110"))) or
				((i=matrix_in)and ((position="1000")or(position="0010")or(position="0101"))) or
				((j="000000")and ((position="0000")or(position="0001")or(position="0010"))) or
				((j=matrix_in)and ((position="1000")or(position="0111")or(position="0110"))) then
				pixel_read_address <= "1100010000"; --784(0)
			else addr := conv_column*matrix_in;
				pixel_read_address <= pix_start_addr + i + addr(9 downto 0) + rel_position-'1';
			end if;
		else rd_en_conv <= '0';stay<='0';
		end if;
	else pixel_read_address <= "1100010000"; --784(0)
		 rd_en_conv <='0';
	end if;
end if;
end process;
end behav;

----------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;
--USE IEEE.std_logic_unsigned.All; error:Error (10621): VHDL Use Clause error at conv.vhd(55): 
--more than one Use Clause imports a declaration of simple name ""="" -- none of the declarations are directly visible

entity gobal_maxpool_ctrl is
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	gobal_ready:in std_logic;
	matrix_in:in std_logic_vector(5 downto 0);
	pix_start_addr:in std_logic_vector(9 DOWNTO 0);
	gobalpool_read_address:out std_logic_vector(9 DOWNTO 0);
	rd_en_gobalpool:out std_logic;
	maxpool_over:out std_logic
	);
end entity;

architecture behav of gobal_maxpool_ctrl is
signal rel_addr:std_logic_vector(9 DOWNTO 0):="0000000000";
signal over:std_logic:='0';
signal stay:std_logic:='0';
signal delay:std_logic_vector(3 downto 0):="0000";
begin

process(clk)
begin
if rst_n='0' then
	stay <= '0';
	rd_en_gobalpool <= '0';
	rel_addr <= (others=>'0');
	over <= '0';
elsif(rising_edge(clk))then
	if gobal_ready='1' then
		stay <='1';
		over <= '0';
	end if;
	if stay='1' then
		if rel_addr/= ("0000"&matrix_in) then --49
			rel_addr <= rel_addr + '1';
			rd_en_gobalpool <= '1';
			over <= '0';
		else rel_addr <= (others=>'0');
			 stay <='0';
			 over <= '1';
			 rd_en_gobalpool <= '0';
		end if;
	else rd_en_gobalpool <= '0';
	end if;
end if;
end process;

process(clk)
begin
if rst_n='0' then
	delay <= "0000";
elsif rising_edge(clk) then
	delay(0) <= over;
	delay(3 downto 1) <= delay(2 downto 0);
end if;
end process;
maxpool_over <= delay(3);
gobalpool_read_address <= pix_start_addr + rel_addr - '1';
end behav;


----------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;
--USE IEEE.std_logic_unsigned.All; error:Error (10621): VHDL Use Clause error at conv.vhd(55): 
--more than one Use Clause imports a declaration of simple name ""="" -- none of the declarations are directly visible

entity maxpool_ctrl is
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	pool_ready:in std_logic;
	matrix_in:in std_logic_vector(5 downto 0);
	pix_start_addr:in std_logic_vector(9 DOWNTO 0);
	maxpool_read_address:out std_logic_vector(9 DOWNTO 0);
	rd_en_pool:out std_logic;
	maxpool_over:out std_logic
	);
end entity;

architecture behav of maxpool_ctrl is
signal times:std_logic_vector(2 DOWNTO 0):="000";
signal pool_row:std_logic_vector(5 DOWNTO 0):="000000";
signal pool_column:std_logic_vector(5 DOWNTO 0):="000000";
signal rel_addr:std_logic_vector(11 DOWNTO 0):="000000000000";
signal over:std_logic:='0';
signal stay:std_logic:='0';
signal delay:std_logic_vector(3 downto 0):="0000";
begin

process(clk)
begin
if rst_n='0' then
	rel_addr <= (others=>'0');
elsif(rising_edge(clk))then
	if stay='1' then
		case(times) is
		when "001" => rel_addr <= pool_row + pool_column*matrix_in;
		when "010" => rel_addr <= pool_row + '1' + pool_column*matrix_in;
		when "011" => rel_addr <= pool_row + (pool_column+'1')*matrix_in;
		when "100" => rel_addr <= pool_row + '1' + (pool_column+'1')*matrix_in;
		when others => NULL;
		end case;
	else
		rel_addr <= (others=>'0');
	end if;
end if;
end process;

process(clk)
begin
if rst_n='0' then
	times <= "000";
elsif(rising_edge(clk))then
	if stay='1' then
		times <= times + '1';
		if times = "100" then
			times <= "001";
		end if;
	else 
		times <= "000";
	end if;
end if;
end process;

process(clk)
begin
if rst_n='0' then
	stay <= '0';
	rd_en_pool <= '0';
	pool_row <= "000000";
	pool_column <= "000000";
	over <= '0';
elsif(rising_edge(clk))then
	if pool_ready='1' then
		stay <='1';
		over <= '0';
	end if;
	if stay='1' then
		if times/="000" then
			rd_en_pool <= '1';
		end if;
		if times="100" then
			pool_row <= pool_row+"000010";
			if (pool_row=matrix_in-"000010") then
				pool_row <= "000000";
				pool_column <= pool_column + "000010";
			end if;
		end if;
		if  rel_addr=matrix_in*matrix_in-'1' then
			pool_column <= "000000";
			over <= '1';
			stay <='0';
			rd_en_pool <= '0';
		end if;
	else rd_en_pool <= '0';
	end if;
end if;
end process;

process(clk)
begin
if rst_n='0' then
	delay <= "0000";
elsif rising_edge(clk) then
	delay(0) <= over;
	delay(3 downto 1) <= delay(2 downto 0);
end if;
end process;
maxpool_over <= delay(3);

maxpool_read_address <= pix_start_addr + rel_addr(9 downto 0);
end behav;


--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;
--USE IEEE.std_logic_unsigned.All; error:Error (10621): VHDL Use Clause error at conv.vhd(55): 
--more than one Use Clause imports a declaration of simple name ""="" -- none of the declarations are directly visible

entity rd_addr_enable is
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	layer:in std_logic_vector(3 DOWNTO 0);
	conv_read_address:in std_logic_vector(9 DOWNTO 0);
	maxpool_read_address:in std_logic_vector(9 DOWNTO 0);
	gobalpool_read_address:in std_logic_vector(9 DOWNTO 0);
	rd_addr:out std_logic_vector(9 DOWNTO 0)
	);
end entity;
architecture behav of rd_addr_enable is
begin
process(layer, conv_read_address, maxpool_read_address, gobalpool_read_address)
begin
case(layer)is
	when "0001"|"0100"|"0111"|"0010"|"0101" => rd_addr<=conv_read_address;
	when "0011"|"0110" => rd_addr<=maxpool_read_address;
	when "1000" => rd_addr<=gobalpool_read_address;
	when others=> NULL;
end case;
end process;
end behav;


---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;
--USE IEEE.std_logic_unsigned.All; error:Error (10621): VHDL Use Clause error at conv.vhd(55): 
--more than one Use Clause imports a declaration of simple name ""="" -- none of the declarations are directly visible

entity read_enable is
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	layer:in std_logic_vector(3 DOWNTO 0);
	rd_en_conv:in std_logic;
	rd_en_pool:in std_logic;
	rd_en_gobalpool:in std_logic;
	group1_en:out std_logic;
	group2_en:out std_logic;
	group3_en:out std_logic
	);
end entity;
architecture behav of read_enable is
begin
process(layer, rd_en_conv, rd_en_pool, rd_en_gobalpool)
begin
case(layer)is
	when "0001"|"0100"|"0111" => group1_en<=rd_en_conv;group2_en<='0';group3_en<='0';
	when "0010"|"0101" => group2_en<=rd_en_conv;group1_en<='0';group3_en<='0';
	when "0011"|"0110" => group3_en<=rd_en_pool;group2_en<='0';group1_en<='0';
	when "1000" => group2_en<=rd_en_gobalpool;group1_en<='0';group3_en<='0';
	when others=> group1_en<='0';group2_en<='0';group3_en<='0';
end case;
end process;
end behav;

