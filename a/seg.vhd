library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity seg is
	port(clk:in std_logic;
			rst_n:in std_logic;
			idis_data:in std_logic_vector(3 downto 0);
			seg_w:out std_logic_vector(5 downto 0);
			seg_d:out std_logic_vector(7 downto 0)
			);
end seg;

architecture behav of seg is
   --设置段码值
	constant SEG_NUM0:std_logic_vector(7 downto 0):=x"c0";
	constant SEG_NUM1:std_logic_vector(7 downto 0):=x"f9";
	constant SEG_NUM2:std_logic_vector(7 downto 0):=x"a4";
	constant SEG_NUM3:std_logic_vector(7 downto 0):=x"b0";
	constant SEG_NUM4:std_logic_vector(7 downto 0):=x"99";
	constant SEG_NUM5:std_logic_vector(7 downto 0):=x"92";
	constant SEG_NUM6:std_logic_vector(7 downto 0):=x"82";
	constant SEG_NUM7:std_logic_vector(7 downto 0):=x"F8";
	constant SEG_NUM8:std_logic_vector(7 downto 0):=x"80";
	constant SEG_NUM9:std_logic_vector(7 downto 0):=x"90";
	constant SEG_NUMA:std_logic_vector(7 downto 0):=x"88";
	constant SEG_NUMB:std_logic_vector(7 downto 0):=x"83";
	constant SEG_NUMC:std_logic_vector(7 downto 0):=x"c6";
	constant SEG_NUMD:std_logic_vector(7 downto 0):=x"a1";
	constant SEG_NUME:std_logic_vector(7 downto 0):=x"86";
	constant SEG_NUMF:std_logic_vector(7 downto 0):=x"8e";
	signal cnt:integer range 0 to 49999999;
	signal refresh_en:std_logic;
	signal seg_num:std_logic_vector(3 downto 0);
	signal seg_duan:std_logic_vector(7 downto 0);

	
	
begin 
	---------------------------数据输入-------------------------------------
	process(clk,rst_n)
		begin
		if(rst_n='0')then
			seg_duan<=(others=>'1');
		elsif(rising_edge(clk))then
			case seg_num is
				when "0000"=>seg_duan<=SEG_NUM0;
				when "0001"=>seg_duan<=SEG_NUM1;
				when "0010"=>seg_duan<=SEG_NUM2;
				when "0011"=>seg_duan<=SEG_NUM3;
				when "0100"=>seg_duan<=SEG_NUM4;
				when "0101"=>seg_duan<=SEG_NUM5;
				when "0110"=>seg_duan<=SEG_NUM6;
				when "0111"=>seg_duan<=SEG_NUM7;
				when "1000"=>seg_duan<=SEG_NUM8;
				when "1001"=>seg_duan<=SEG_NUM9;
			
				when others=>null;
			end case;
		end if;
	end process;
-----------------------------------------------------------------------------	
	
process(clk, rst_n)
begin
if rst_n='0' then
	refresh_en <= '0';
elsif rising_edge(clk)then
	cnt <= cnt + 1;
	if cnt=49999999 then
		refresh_en <= '1';
		cnt <= 0;
	else refresh_en <= '0';
	end if;
end if;
end process;



---------------------将需要显示的数据送入seg_num----------------------------------

	process(clk,rst_n)
		begin
		if(rst_n='0')then
			seg_num<=(others=>'0');
		elsif(rising_edge(clk))then
			if refresh_en='1' then
				seg_num<=idis_data;
			end if;
		end if;
	end process;
--------------------------------------------------------------------------------	

seg_w<="110111";
seg_d<=seg_duan;
			

end behav;