library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity lcd_driver is
port(
	lcd_clk:in std_logic;		--lcd模块驱动时钟
	sys_rst_n:in std_logic;		--/复位信号
	lcd_id:in std_logic_vector(15 downto 0);		--LCD屏ID
	pixel_data:in std_logic_vector(15 downto 0);		--像素点数据
	data_req:buffer std_logic;		--请求像素点颜色数据输入
	pixel_xpos:out std_logic_vector(10 downto 0);		--像素点横坐标
	pixel_ypos:out std_logic_vector(10 downto 0);		--像素点纵坐标
	h_disp:buffer std_logic_vector(10 downto 0);		--LCD屏水平分辨率
	v_disp:buffer std_logic_vector(10 downto 0);		--LCD屏垂直分辨率
	out_vsync:out std_logic;		--帧复位，高有效
	
	--RGB LCD接口
	lcd_hs:out std_logic;		--LCD 行同步信号
	lcd_vs:out std_logic;		--LCD 场同步信号
	lcd_de:out std_logic;		--LCD 数据输入使能
	lcd_rgb:out std_logic_vector(15 downto 0);		--LCD RGB565颜色数据
	lcd_bl:out std_logic;		--LCD 背光控制信号
	lcd_rst:out std_logic;		--LCD 复位信号
	lcd_pclk:buffer std_logic		--LCD 采样时钟

	);
end entity;

architecture behav of lcd_driver is
-- 4.3' 480*272
constant  H_SYNC_4342:	std_logic_vector(10 downto 0):="00000101001";		--11'd41;     //行同步
constant  H_BACK_4342:	std_logic_vector(10 downto 0):="00000000010";		--11'd2;      //行显示后沿
constant  H_DISP_4342:	std_logic_vector(10 downto 0):="00111100000";		--11'd480;    //行有效数据
constant  H_FRONT_4342:	std_logic_vector(10 downto 0):="00000000010";		--11'd2;      //行显示前沿
constant  H_TOTAL_4342:	std_logic_vector(10 downto 0):="01000001101";		--11'd525;    //行扫描周期
   
constant  V_SYNC_4342:	std_logic_vector(10 downto 0):="00000001010";		--11'd10;     //场同步
constant  V_BACK_4342:	std_logic_vector(10 downto 0):="00000000010";		--11'd2;      //场显示后沿
constant  V_DISP_4342:	std_logic_vector(10 downto 0):="00100010000";		--11'd272;    //场有效数据
constant  V_FRONT_4342:	std_logic_vector(10 downto 0):="00000000010";		--11'd2;      //场显示前沿
constant  V_TOTAL_4342:	std_logic_vector(10 downto 0):="00100011110";		--11'd286;    //场扫描周期      

-- 7' 1024*600   
constant  H_SYNC_7016:	std_logic_vector(10 downto 0):= "00000010100";		--11'd20;    //行同步
constant  H_BACK_7016:	std_logic_vector(10 downto 0):= "00010001100";		--11'd140;     //行显示后沿
constant  H_DISP_7016:	std_logic_vector(10 downto 0):= "10000000000";		--11'd1024;    //行有效数据
constant  H_FRONT_7016:	std_logic_vector(10 downto 0):= "00010100000";		--11'd160;     //行显示前沿
constant  H_TOTAL_7016:	std_logic_vector(10 downto 0):= "10101000000";		--11'd1344;   //行扫描周期

constant  V_SYNC_7016:	std_logic_vector(10 downto 0):= "00000000011";		--11'd3;      //场同步
constant  V_BACK_7016:	std_logic_vector(10 downto 0):= "00000010100";		--11'd20;     //场显示后沿
constant  V_DISP_7016:	std_logic_vector(10 downto 0):= "01001011000";		--11'd600;    //场有效数据
constant  V_FRONT_7016:	std_logic_vector(10 downto 0):= "00000001100";		--11'd12;     //场显示前沿
constant  V_TOTAL_7016:	std_logic_vector(10 downto 0):= "01001111011";		--11'd635;    //场扫描周期  

signal h_sync:std_logic_vector(10 downto 0);
signal h_back:std_logic_vector(10 downto 0);
signal h_total:std_logic_vector(10 downto 0);
signal v_sync:std_logic_vector(10 downto 0);
signal v_back:std_logic_vector(10 downto 0);
signal v_total:std_logic_vector(10 downto 0);
signal h_cnt:std_logic_vector(10 downto 0);
signal v_cnt:std_logic_vector(10 downto 0);

signal lcd_en:std_logic;

begin
lcd_bl <= '1';		--RGB LCD显示模块背光控制信号
lcd_rst <= '1';		--RGB LCD显示模块系统复位信号
lcd_pclk <= lcd_clk;		--RGB LCD显示模块采样时钟

--RGB LCD 采用数据输入使能信号同步时，行场同步信号需要拉高
lcd_hs <= '1';
lcd_vs <='1';

--使能RGB565数据输出
lcd_en <= '1' when ((h_cnt >= (h_sync + h_back)) and (h_cnt < (h_sync + h_back + h_disp)) and (v_cnt >= (v_sync +v_back)) and (v_cnt < (v_sync +v_back +v_disp))) else
			 '0';

--帧复位，高有效
out_vsync <= '1' when ((h_cnt <= "00001100100") and (v_cnt = "00000000001")) else
				 '0';

--请求像素点颜色数据输入
data_req <= '1' when ((h_cnt >= (h_sync + h_back - "00000000001")) and (h_cnt < (h_sync + h_back + h_disp - "00000000001")) 
						and (v_cnt >= (v_sync + v_back)) and (v_cnt < (v_sync + v_back + v_disp))) else
				'0';

--像素点坐标
pixel_xpos <= (h_cnt - (h_sync + h_back - "00000000001")) when data_req = '1' else
					"00000000000";
pixel_ypos <= (v_cnt - (v_sync + v_back - "00000000001")) when data_req = '1' else
					"00000000000";

					
--LCD输入的颜色数据采用数据输入使能信号同步
process(lcd_clk,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		lcd_de <= '0';
	elsif(rising_edge(lcd_clk)) then
		lcd_de <= lcd_en;
	end if;
end process;


--RGB565数据输出 
process(lcd_clk,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		lcd_rgb <= "0000000000000000";
	elsif(rising_edge(lcd_clk)) then
		if(lcd_en = '1') then
			lcd_rgb <= pixel_data;
		else
			lcd_rgb <= "0000000000000000";
		end if;
	end if;
end process;


--行场时序参数
process(lcd_clk)
begin
	if(rising_edge(lcd_clk)) then
		case lcd_id is
			when "0100001101000010" =>	h_sync  <= H_SYNC_4342; 
												h_back  <= H_BACK_4342; 
												h_disp  <= H_DISP_4342; 
												h_total <= H_TOTAL_4342;
												v_sync  <= V_SYNC_4342; 
												v_back  <= V_BACK_4342; 
												v_disp  <= V_DISP_4342; 
												v_total <= V_TOTAL_4342;
												
			when "0111000000010110" => h_sync  <= H_SYNC_7016; 
												h_back  <= H_BACK_7016; 
												h_disp  <= H_DISP_7016; 
												h_total <= H_TOTAL_7016;
												v_sync  <= V_SYNC_7016; 
												v_back  <= V_BACK_7016; 
												v_disp  <= V_DISP_7016; 
												v_total <= V_TOTAL_7016; 
												
			when others => 				h_sync  <= H_SYNC_4342; 
												h_back  <= H_BACK_4342; 
												h_disp  <= H_DISP_4342; 
												h_total <= H_TOTAL_4342;
												v_sync  <= V_SYNC_4342; 
												v_back  <= V_BACK_4342; 
												v_disp  <= V_DISP_4342; 
												v_total <= V_TOTAL_4342; 
		end case;
	end if;
end process;


--行计数器对像素时钟计数
process(lcd_pclk,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		h_cnt <= "00000000000";
	elsif(rising_edge(lcd_pclk)) then
		if(h_cnt = h_total - "00000000001") then
			h_cnt <= "00000000000";
		else
			h_cnt <= h_cnt + "00000000001";
		end if;
	end if;
end process;


--场计数器对行计数
process(lcd_clk,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		v_cnt <= "00000000000";
	elsif(rising_edge(lcd_clk)) then
		if(h_cnt = h_total - "00000000001") then
			if(v_cnt = v_total - "00000000001") then
				v_cnt <= "00000000000";
			else	
				v_cnt <= v_cnt + "00000000001";
			end if;
		end if;
	end if;
end process;

end behav;









