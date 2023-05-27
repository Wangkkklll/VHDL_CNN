library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rd_id is
port(
	clk,rst_n:in std_logic;
	lcd_rgb:in std_logic_vector(15 downto 0);		--RGB LCD像素数据,用于读取ID
	lcd_id:out std_logic_vector(15 downto 0)		--LCD屏ID
);
end entity;

architecture behav of rd_id is
signal rd_flag:std_logic;		--读ID标志
signal lcd_rgb_41015:std_logic_vector(2 downto 0);
begin

process(clk,rst_n)
begin
	lcd_rgb_41015 <= lcd_rgb(4) & lcd_rgb(10) & lcd_rgb(15);
	if(rst_n = '0') then
		rd_flag <= '0';
		lcd_id <= "0000000000000000";
	elsif(rising_edge(clk)) then
		if(rd_flag = '0') then
			rd_flag <= '1';
			case lcd_rgb_41015 is
				when "000" => lcd_id <= "0100001101000010";		--4342
				when "001" => lcd_id <= "0111000010000100";		--7084
				when "010" => lcd_id <= "0111000000010110";		--7016
				when "100" => lcd_id <= "0100001110000100";		--4384
				when "101" => lcd_id <= "0001000000011000";		--1018
				when others =>lcd_id <= "0000000000000000";
			end case;
		end if;
	end if;
end process;

end behav;
