library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity top_control is
	port(
		clk:in std_logic;
		rst_n:in std_logic;
		cnn_ready:in std_logic;
		once_finish:in std_logic;
		layer_done:in std_logic; 
		current_layer:out std_logic_vector(3 downto 0);
		w_start_addr:out std_logic_vector(11 downto 0);
		pix_start_addr:out std_logic_vector(9 downto 0);
		is_onetofour:out std_logic; --是前四个通道还是后四个通道
		pool_ready:out std_logic;
		gobal_ready:out std_logic;
		weight_ready:out std_logic
	);
end entity;

architecture behav of top_control is
signal layer:std_logic_vector(3 downto 0);
signal layer_delay, weight_ready_delay, delay, delay1, delay2:std_logic:='0';
signal count:std_logic_vector(9 DOWNTO 0):="0000000000";
signal delay_count:std_logic_vector(4 DOWNTO 0):="00000";
signal pool_reload, weight_done, weight_en, onetofour:std_logic;
signal cnt_pool_reload:std_logic_vector(1 DOWNTO 0):="00";
signal cnt_gobal_pool_reload:std_logic_vector(1 DOWNTO 0):="00";
signal w_addr_init:std_logic_vector(11 DOWNTO 0):="000000000000";

begin
----------------ready-----------------------
--------------layer------------
process(clk)
begin
if rst_n='0' then
	layer_delay <= '0';
elsif rising_edge(clk) then
	if(cnn_ready='1')or(layer_done='1') then
		layer_delay <= '1';
	else layer_delay <= '0';
	end if;
end if;
end process;

process(clk)
begin
if rst_n='0' then
	layer <= "0000";
elsif rising_edge(clk) then
	if layer_delay='1' then
		layer <= layer + '1';
	end if;
end if;
end process;
current_layer <= layer;

------------wehght_ready------------
process(clk)
begin
if rst_n='0' then
	weight_ready_delay <= '0';
elsif rising_edge(clk) then
	if (cnn_ready='1') then
		weight_ready_delay <= '1';
	else weight_ready_delay <= '0';
	end if;
end if;
end process;

process(clk)
begin
if rst_n='0' then
	weight_ready <= '0';
elsif rising_edge(clk) then
	if weight_ready_delay='1' then
		weight_ready <= '1';
	else weight_ready <= '0';
	end if;
end if;
end process;


---------------pool_ready--------------
process(clk)
begin
if rst_n='0' then
	pool_ready <= '0';
elsif rising_edge(clk) then
	if((layer_delay='1')and((layer="0010")or(layer="0101")))or((pool_reload='1')and(layer="0110")) then
		pool_ready <= '1';
	else pool_ready <= '0';
	end if;
end if;
end process;
--------------gobal_pool_ready------------
process(clk)
begin
if rst_n='0' then
	gobal_ready <= '0';
elsif rising_edge(clk) then
	if((layer_delay='1')and(layer="0111"))or((pool_reload='1')and(layer="1000")) then
		gobal_ready <= '1';
	else gobal_ready <= '0';
	end if;
end if;
end process;
----------------------------------------------


----------------start_address------------------------
----------------weight_done/weight_en----------------
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
		when "0111" => if count="0000110001" then --49 "0000110001" 
							count <= (others=>'0');
							weight_done <= '1';
						else weight_done <= '0';
						end if;
		when "1000" => if (count="0000000001")then --49"0000110001"
							count <= (others=>'0');
							end if;
							weight_done <= '0';
		when others => weight_done <= '0';
					   count <= (others=>'0');
	end case;
end if;
end process;

-------------w_start_address/weight_en------------
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


--------------------pool_reload--------------------------
process(clk)
begin
if rst_n='0' then
	onetofour <= '1';
	pool_reload <= '0';
	cnt_pool_reload <= "00";
	cnt_gobal_pool_reload <= "00";
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
						cnt_gobal_pool_reload <= cnt_gobal_pool_reload + '1';
						if cnt_gobal_pool_reload/="11" then
							pool_reload <= '1';
							cnt_gobal_pool_reload <= cnt_gobal_pool_reload + '1';
						else cnt_gobal_pool_reload <= "00"; pool_reload <= '0';
						end if;
					else pool_reload <= '0';
					end if;
	when others=> onetofour <= '1';cnt_gobal_pool_reload <= "00";pool_reload <= '0';
end case;
end if;
end process;

----------delay/is_onetofour----------------
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
is_onetofour <= delay2;
------------pix_start_address-------------------
process(delay2, cnt_gobal_pool_reload, layer)
begin
case(layer)is
when "0001"|"0010"|"0011"|"0100"|"0101"|"0110"|"0111" =>
	if (delay2='1')then
		pix_start_addr <= (others=>'0');
	else 
		pix_start_addr <= "0110001000"; --392
	end if;
when "1000" => 
	case(cnt_gobal_pool_reload)is
		when "00" => pix_start_addr <= (others=>'0');
		when "01" => pix_start_addr <= "0011000100"; --196
		when "10" => pix_start_addr <= "0110001000"; --392
		when "11" => pix_start_addr <= "1001001100"; --588
		when others =>null;
	end case;
when others => NULL;
end case;
end process;

----------------------------------------------
end behav;