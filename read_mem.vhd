library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity read_mem is
	port(
		clk:in std_logic;
		rst_n:in std_logic;
		qq:out std_logic_vector(9 downto 0);
		ren:out std_logic
	);
	
end entity;

architecture behav of read_mem is

signal q:std_logic_vector(9 downto 0);

begin

process(clk,rst_n)
begin
if(rst_n='0')then
	q<=(others=>'0');
elsif(rising_edge(clk))then
	q<=q+'1';
end if;
end process;

process(rst_n)
begin
if(rst_n='0')then
	ren<='0';
else
	ren<='1';
end if;

end process;

qq<=q;

end behav;