library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity cnn is
	port(
		clk:in std_logic;
		rst_n:in std_logic;
		data_req:in std_logic;
		end_pre:in std_logic;
		data_in:in std_logic_vector(10 downto 0);
		cnn_finish:out std_logic; --识别完成信号
		result:out std_logic_vector(3 downto 0)--识别结果
	);
end entity;

architecture behav of cnn is

COMPONENT rd_data
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
end COMPONENT;

COMPONENT top_control
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
end COMPONENT;


COMPONENT ram_pixel
	port(
	clk:in std_logic;
	layer:in std_logic_vector(3 DOWNTO 0);
	rd_addr:in std_logic_vector(9 DOWNTO 0);
	group1_en, group2_en, group3_en:in std_logic;
	q_out_a, q_out_b, q_out_c, q_out_d:out std_logic_vector(7 DOWNTO 0);
	wr_en_ain,wr_en_bin,wr_en_cin,wr_en_din:in std_logic;
	wr_en_aout1,wr_en_bout1,wr_en_cout1,wr_en_dout1:in std_logic;
	wr_en_aout2,wr_en_bout2,wr_en_cout2,wr_en_dout2:in std_logic;
	wr_addr:in std_logic_vector(9 DOWNTO 0);
	wr_data_a, wr_data_b, wr_data_c, wr_data_d:in  std_logic_vector (7 downto 0)
	);
end COMPONENT;

signal group1_en, group2_en, group3_en:std_logic;
signal rd_addr:std_logic_vector(9 DOWNTO 0);
signal q_out_a, q_out_b, q_out_c, q_out_d:std_logic_vector(7 DOWNTO 0);signal wr_addr:std_logic_vector(9 DOWNTO 0);
signal wr_data_a, wr_data_b, wr_data_c, wr_data_d:std_logic_vector (7 downto 0);
signal wr_en_ain,wr_en_bin,wr_en_cin,wr_en_din, wr_en_aout1,wr_en_bout1,wr_en_cout1,wr_en_dout1, wr_en_aout2,wr_en_bout2,wr_en_cout2,wr_en_dout2:std_logic;
signal gray_ready:std_logic;

signal once_finish, layer_done, is_onetofour, pool_ready, gobal_ready, weight_ready:std_logic;
signal w_start_addr:std_logic_vector(11 downto 0);
signal pix_start_addr:std_logic_vector(9 downto 0);
signal current_layer:std_logic_vector(3 downto 0);
begin
U0:rd_data
	port map(clk, rst_n, data_req, end_pre, data_in, weight_ready, pool_ready, gobal_ready, is_onetofour, current_layer, w_start_addr, pix_start_addr, q_out_a, q_out_b, q_out_c, q_out_d,
			rd_addr, group1_en, group2_en, group3_en, wr_en_ain,wr_en_bin,wr_en_cin,wr_en_din, wr_en_aout1,wr_en_bout1,wr_en_cout1,wr_en_dout1, 
			wr_en_aout2,wr_en_bout2,wr_en_cout2,wr_en_dout2, wr_addr, wr_data_a, wr_data_b, wr_data_c, wr_data_d, gray_ready, once_finish, layer_done, cnn_finish, result);
U1:top_control
	port map(clk, rst_n, gray_ready, once_finish, layer_done, current_layer, w_start_addr, pix_start_addr, is_onetofour, pool_ready, gobal_ready, weight_ready);
U2:ram_pixel
	port map(clk, current_layer, rd_addr, group1_en, group2_en, group3_en, q_out_a, q_out_b, q_out_c, q_out_d,
	wr_en_ain,wr_en_bin,wr_en_cin,wr_en_din, wr_en_aout1,wr_en_bout1,wr_en_cout1,wr_en_dout1, wr_en_aout2,wr_en_bout2,wr_en_cout2,wr_en_dout2,
	 wr_addr, wr_data_a, wr_data_b, wr_data_c, wr_data_d);
end behav;