----------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;

entity rd_data is
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	data_req:in std_logic;
	end_pre:in std_logic;
	data_in:in std_logic_vector(10 downto 0);
	weight_ready:in std_logic;
	pool_ready:in std_logic;
	gobal_ready:in std_logic;
	is_onetofour:in std_logic;
	current_layer:in std_logic_vector(3 DOWNTO 0);
	w_start_addr:in std_logic_vector(11 downto 0);
	pix_start_addr:in std_logic_vector(9 downto 0);
	q_out_a, q_out_b, q_out_c, q_out_d:in std_logic_vector(7 DOWNTO 0);
	rd_addr:out std_logic_vector(9 DOWNTO 0);
	group1_en, group2_en, group3_en:out std_logic;
	wr_en_ain,wr_en_bin,wr_en_cin,wr_en_din:out std_logic;
	wr_en_aout1,wr_en_bout1,wr_en_cout1,wr_en_dout1:out std_logic;
	wr_en_aout2,wr_en_bout2,wr_en_cout2,wr_en_dout2:out std_logic;
	wr_addr:out std_logic_vector(9 DOWNTO 0);
	wr_data_a, wr_data_b, wr_data_c, wr_data_d:out  std_logic_vector (7 downto 0);
	gray_ready:out std_logic;
	once_finish:out std_logic;
	layer_done:out std_logic;
	cnn_finish:out std_logic; --识别完成信号
	result:out std_logic_vector(3 downto 0)--识别结果
	);
end entity;

architecture structure of rd_data is

COMPONENT gray_in
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	data_req:in std_logic;
	end_pre:in std_logic;
	data_in:in std_logic_vector(10 downto 0);
	gray_ready:out std_logic;
	gray_en:out std_logic;
	data_out:out std_logic_vector(7 downto 0);
	gray_addr:out std_logic_vector(9 downto 0)
	);
end COMPONENT;

COMPONENT rom_weight
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
end COMPONENT;

COMPONENT rd_control
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	w_pre_ready:in std_logic;
	pool_ready:in std_logic;
	gobal_ready:in std_logic;
	layer:in std_logic_vector(3 DOWNTO 0);
	pix_start_addr:in std_logic_vector(9 DOWNTO 0);
	rd_addr:out std_logic_vector(9 DOWNTO 0);
	group1_en, group2_en, group3_en:out std_logic;
	position_out:out std_logic_vector(3 DOWNTO 0);
	conv_over:out std_logic;
	maxpool_over:out std_logic;
	pool_start:out std_logic;
	conv_stop:out std_logic
	);
end COMPONENT;

COMPONENT conv_maxpool
	port(
	clk:in std_logic;
	rst_n:in std_logic;
	conv_stop:in std_logic;
	maxpool_over:in std_logic;
	pool_start:in std_logic;
	position:in std_logic_vector(3 DOWNTO 0);
	q_out_a:in std_logic_vector(7 DOWNTO 0);
	q_out_b:in std_logic_vector(7 DOWNTO 0);
	q_out_c:in std_logic_vector(7 DOWNTO 0);
	q_out_d:in std_logic_vector(7 DOWNTO 0);
	--w1, w2 ,w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18:in std_logic_vector(1 DOWNTO 0);
	--w19, w20 ,w21, w22, w23, w24, w25, w26, w27, w28, w29, w30, w31, w32, w33, w34, w35, w36:in std_logic_vector(1 DOWNTO 0);
	weight_out:in std_logic_vector(71 downto 0);
	conv_over:in std_logic;
	layer:in std_logic_vector(3 DOWNTO 0);
	is_onetofour:in std_logic; --是前四个通道还是后四个通道
	once_finish:out std_logic;
	finish:out std_logic;
	data_out:out std_logic_vector(7 downto 0);
	data_out1:out std_logic_vector(7 downto 0);
	data_out2:out std_logic_vector(7 downto 0);
	data_out3:out std_logic_vector(7 downto 0);
	data_out4:out std_logic_vector(7 downto 0)
	);
end COMPONENT;

COMPONENT wr_control
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
end COMPONENT;

COMPONENT full_connect
	port(
		clk:in std_logic;
		rst_n:in std_logic;
		data_en:in std_logic;  --输入数据ready
		data1,data2,data3,data4:in std_logic_vector(7 downto 0); --并行输入的四个数据
		cnn_finish:out std_logic; --识别完成信号
		result:out std_logic_vector(3 downto 0)--识别结果
	);
end COMPONENT;

--signal w1, w2 ,w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18:std_logic_vector(1 DOWNTO 0);
--signal w19, w20 ,w21, w22, w23, w24, w25, w26, w27, w28, w29, w30, w31, w32, w33, w34, w35, w36:std_logic_vector(1 DOWNTO 0);
signal weight_out:std_logic_vector(71 downto 0);
signal w_pre_ready, pool_start, data_ready, data_buffer:std_logic;
signal position_out:std_logic_vector(3 DOWNTO 0);
signal conv_over:std_logic;
signal data_out, data_out1, data_out2, data_out3, data_out4:std_logic_vector(7 downto 0);
signal data1, data2, data3, data4:std_logic_vector(7 downto 0);
signal conv_maxpool_finish, gobal_finish, conv_stop:std_logic;
signal maxpool_over, channel_done:std_logic;
signal gray_en, wr_en_a, wr_en_b, wr_en_c, wr_en_d:std_logic;
signal gray_data, wr_data:std_logic_vector(7 downto 0);
signal gray_addr, wr_address:std_logic_vector(9 downto 0);
begin
U0:rom_weight
	port map(clk, rst_n, weight_ready, w_start_addr, weight_out, w_pre_ready);
U1:rd_control
	port map(clk, rst_n, w_pre_ready, pool_ready, gobal_ready, current_layer, pix_start_addr, 
	rd_addr, group1_en, group2_en, group3_en, position_out, conv_over, maxpool_over, pool_start, conv_stop);
U2:gray_in
	port map(clk, rst_n, data_req, end_pre, data_in, gray_ready, gray_en, gray_data, gray_addr);
U3:conv_maxpool
	port map(clk, rst_n, conv_stop, maxpool_over, pool_start, position_out, q_out_a, q_out_b, q_out_c, q_out_d, weight_out, conv_over, current_layer, is_onetofour, 
	 once_finish, conv_maxpool_finish, data_out, data_out1, data_out2, data_out3, data_out4);
U4:wr_control
	port map(clk, rst_n, conv_maxpool_finish, current_layer, data_out, data_out1, data_out2, data_out3, data_out4, 
	wr_address, wr_data, wr_data_b, wr_data_c, wr_data_d, wr_en_a, wr_en_b, wr_en_c, wr_en_d, wr_en_aout1, wr_en_bout1, wr_en_cout1, wr_en_dout1, 
	wr_en_aout2, wr_en_bout2, wr_en_cout2, wr_en_dout2, layer_done);
U5:full_connect
	port map(clk, rst_n, gobal_finish, data1, data2, data3, data4, cnn_finish, result);

--------------gobal_maxpool and full_connnect----------------
process(current_layer, conv_maxpool_finish, data_out1, data_out2, data_out3, data_out4)
begin
if(current_layer="1000") then
	gobal_finish <= conv_maxpool_finish;
	data1 <= data_out1;
	data2 <= data_out2;
	data3 <= data_out3;
	data4 <= data_out4;
else gobal_finish <= '0';
	 data1 <= (others=>'0');
	 data2 <= (others=>'0');
	 data3 <= (others=>'0');
	 data4 <= (others=>'0');
end if;
end process;
-----------------------------------------------------------
process(current_layer, wr_en_a, wr_en_b, wr_en_c, wr_en_d, gray_en, wr_address, gray_addr, gray_data, wr_data)
begin
if(current_layer="0000") then
	wr_en_ain <= gray_en;
	wr_en_bin <= gray_en;
	wr_en_cin <= gray_en;
	wr_en_din <= gray_en;
	wr_addr <= gray_addr;
	wr_data_a <= gray_data;
else 
	wr_en_ain <= wr_en_a;
	wr_en_bin <= wr_en_b;
	wr_en_cin <= wr_en_c;
	wr_en_din <= wr_en_d;
	wr_addr <= wr_address;
	wr_data_a <= wr_data;
end if;
end process;
end structure;


