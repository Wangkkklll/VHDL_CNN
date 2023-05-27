library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity addr_init is
	port(
		clk:in std_logic;
		rst_n:in std_logic;
		layer:in std_logic_vector(3 downto 0);
		once_finish:in std_logic; 
		weight_en:out std_logic;
		w_start_addr:out std_logic_vector(11 downto 0);
		pix_start_addr:out std_logic_vector(9 downto 0);
		is_onetofour:out std_logic; --是前四个通道还是后四个通道
		pool_reload:out std_logic;
		count_test:out std_logic_vector(9 downto 0)
	);
end entity;

architecture behav of addr_init is
signal count:std_logic_vector(9 DOWNTO 0):="0000000000";
signal weight_done, onetofour, delay, delay1, delay2:std_logic:='0';
signal gobal_pool_cnt:std_logic_vector(1 DOWNTO 0):="00";
signal w_addr_init:std_logic_vector(11 DOWNTO 0):="000000000000";
signal cnt_pool_reload:std_logic_vector(1 DOWNTO 0):="00";
signal delay_count:std_logic_vector(4 DOWNTO 0):="00000";
begin

process(clk)
begin
if rst_n='0' then
	count <= (others=>'0');
	weight_done <= '0';
elsif rising_edge(clk) then
	if(once_finish='1') then
		count <= count + '1';
	end if;
	case(layer) is
		when "0001"|"0010" => if count="1100010000" then --784 "1100010000"/256
									count <= (others=>'0');
									weight_done <= '1';
								else weight_done <= '0';
								end if;
		when "0011" => if count="0011000100" then --196 "0011000100"/64
									count <= (others=>'0');
									weight_done <= '1';
								else weight_done <= '0';
								end if;
		when "0100"|"0101" => if count="0011000100" then --196 "0011000100"/64
									count <= (others=>'0');
									weight_done <= '1';
								else weight_done <= '0';
								end if;
		when "0110" => if (count="0000110001")and(cnt_pool_reload="01") then --49"0000110001" 
							count <= (others=>'0');
							weight_done <= '1';
						elsif  (count="0000110001") then
								count <= (others=>'0');
								weight_done <= '0';
						else weight_done <= '0';
						end if;

						--weight_done <= '0';
		when "0111" => if count="0000110001" then --49 
							count <= (others=>'0');
							weight_done <= '1';
						else weight_done <= '0';
						end if;
		when "1000" => if (count="0000000001")then --49"0000110001" /9"0000001001"
							count <= (others=>'0');
							end if;
							weight_done <= '0';
		when others => weight_done <= '0';
					   count <= (others=>'0');
	end case;
end if;
end process;


process(clk)
variable stay:std_logic:='0';
begin
if rst_n='0' then
 w_addr_init <= (others=>'0');
 delay_count <= "00000";
 weight_en <= '0';
 stay:='0';
elsif rising_edge(clk) then
 if(weight_done='1') then
 stay:='1';
 end if;
 if stay='1' then
  if (delay_count="10000")and(layer/="0011")and(layer/="0110")and(layer/="1000") then
   weight_en <= '1';
   w_addr_init <= w_addr_init + "000000100100"; --+36
   stay:='0';
   delay_count <= "00000";
  else weight_en <= '0';
   delay_count <= delay_count +'1';
  end if;
 else delay_count <= "00000";
  weight_en <= '0';
 end if;
end if;
end process;
w_start_addr <= w_addr_init;
count_test<=count;
----------------------------------------------------------
process(clk)
begin
if rst_n='0' then
	gobal_pool_cnt <= "00";
	onetofour <= '1';
	pool_reload <= '0';
	cnt_pool_reload <= "00";
elsif rising_edge(clk) then
case(layer) is
	when "0001"|"0010"|"0011"|"0100" => onetofour <= '1';pool_reload <= '0';
	when "0101" => if count="0011000100" then --196 "0011000100"
						onetofour <= not onetofour;
				   end if;
				   pool_reload <= '0';
	when "0110" => if count="0000110001" then --49 "0000110001"
						onetofour <= not onetofour;
						if cnt_pool_reload/="01" then
							pool_reload <= '1';
							cnt_pool_reload <= cnt_pool_reload + '1';
						else cnt_pool_reload <= "00"; pool_reload <= '0';
						end if;
					else pool_reload <= '0';
				   end if;
	when "0111" => if count="0000110001" then --49 "0000110001"
						onetofour <= not onetofour;
				   end if;
				   pool_reload <= '0';
	when "1000" => if count="0000000001" then
						gobal_pool_cnt <= gobal_pool_cnt + '1';
						if gobal_pool_cnt/="11" then
							pool_reload <= '1';
							gobal_pool_cnt <= gobal_pool_cnt + '1';
						else gobal_pool_cnt <= "00"; pool_reload <= '0';
						end if;
					else pool_reload <= '0';
					end if;
	when others=> onetofour <= '1';gobal_pool_cnt <= "00";pool_reload <= '0';
end case;
end if;
end process;

process(clk)
begin
if rst_n='0' then
	delay <= '1';
	delay1 <= '1';
	delay2 <= '1'; 
elsif rising_edge(clk) then
	delay <= onetofour;
	delay1 <= delay;
	delay2 <= delay1;
end if;
end process;

process(delay2, gobal_pool_cnt, layer)
begin
case(layer)is
when "0001"|"0010"|"0011"|"0100"|"0101"|"0110"|"0111" =>
	if (delay2='1')then
		pix_start_addr <= (others=>'0');
	else 
		pix_start_addr <= "0110001000"; --392
	end if;
when "1000" => 
	case(gobal_pool_cnt)is
		when "00" => pix_start_addr <= (others=>'0');
		when "01" => pix_start_addr <= "0011000100"; --196
		when "10" => pix_start_addr <= "0110001000"; --392
		when "11" => pix_start_addr <= "1001001100"; --588
	end case;
when others => NULL;
end case;
end process;
is_onetofour <= delay2;
end behav;
