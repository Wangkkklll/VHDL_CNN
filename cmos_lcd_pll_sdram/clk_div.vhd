library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity clk_div is
port(
	clk:in std_logic;				--50Mhz
	rst_n:in std_logic;
	lcd_id:in std_logic_vector(15 downto 0);
	lcd_pclk:out std_logic
);
end clk_div;

architecture behav of clk_div is
signal clk_25m:std_logic;
signal clk_12_5m:std_logic;
signal div_4_cnt:std_logic;
begin


--时钟2分频 输出25MHz时钟
process(clk,rst_n)
begin
	if(rst_n = '0') then
		clk_25m <= '0';
	elsif(rising_edge(clk)) then
		clk_25m <= not clk_25m;
	end if;
end process;

--时钟4分频 输出12.5MHz时钟
process(clk,rst_n)
begin
	if(rst_n = '0') then
		div_4_cnt <= '0';
		clk_12_5m <= '0';
	elsif(rising_edge(clk)) then
		div_4_cnt <= not div_4_cnt;
		if(div_4_cnt = '1') then
			clk_12_5m <= not clk_12_5m;
		end if;
	end if;
end process;

process(lcd_id, clk_12_5m, clk_25m, clk)
begin
	case lcd_id is
		when "0100001101000010" => lcd_pclk <= clk_12_5m;
		when "0111000010000100" => lcd_pclk <= clk_25m;
		when "0111000000010110" => lcd_pclk <= clk;
		when "0100001110000100" => lcd_pclk <= clk_25m;
		when "0001000000011000" => lcd_pclk <= clk;
		when others => lcd_pclk <= '0';
	end case;
end process;

end behav;	









