LIBRARY ieee;
   USE ieee.std_logic_1164.all;

ENTITY sdram_controller IS
   PORT (
      clk              : IN STD_LOGIC;								--SDRAM控制器时钟，100MHz
      rst_n            : IN STD_LOGIC;								--系统复位信号，低电平有效
      --SDRAM 控制器写端口
      sdram_wr_req     : IN STD_LOGIC;								--写SDRAM请求信号
      sdram_wr_ack     : OUT STD_LOGIC;							--写SDRAM响应信号
      sdram_wr_addr    : IN STD_LOGIC_VECTOR(23 DOWNTO 0);	--SDRAM写操作的地址
      sdram_wr_burst   : IN STD_LOGIC_VECTOR(9 DOWNTO 0);	--写sdram时数据突发长度
      sdram_din        : IN STD_LOGIC_VECTOR(15 DOWNTO 0);	--写入SDRAM的数据
      --SDRAM 控制器读端口
      sdram_rd_req     : IN STD_LOGIC;								--读SDRAM请求信号
      sdram_rd_ack     : OUT STD_LOGIC;							--读SDRAM响应信号
      sdram_rd_addr    : IN STD_LOGIC_VECTOR(23 DOWNTO 0);	--SDRAM写操作的地址
      sdram_rd_burst   : IN STD_LOGIC_VECTOR(9 DOWNTO 0);	--读sdram时数据突发长度
      sdram_dout       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);	--从SDRAM读出的数据
      
      sdram_init_done  : OUT STD_LOGIC;							--SDRAM 初始化完成标志
      --FPGA与SDRAM硬件接口
      sdram_cke        : OUT STD_LOGIC;							--SDRAM 时钟有效信号
      sdram_cs_n       : OUT STD_LOGIC;							--SDRAM 片选信号
      sdram_ras_n      : OUT STD_LOGIC;							--SDRAM 行地址选通脉冲
      sdram_cas_n      : OUT STD_LOGIC;							--SDRAM 列地址选通脉冲
      sdram_we_n       : OUT STD_LOGIC;							--SDRAM 写允许位
      sdram_ba         : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);	--SDRAM L-Bank地址线
      sdram_addr       : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);	--SDRAM 地址总线
      sdram_data       : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)--SDRAM 数据总线
   );
END sdram_controller;

ARCHITECTURE structure OF sdram_controller IS
component sdram_ctrl is
	PORT (
      clk              : IN STD_LOGIC;								--系统时钟
      rst_n            : IN STD_LOGIC;								--复位信号，低电平有效
      sdram_wr_req     : IN STD_LOGIC;								--写SDRAM请求信号
      sdram_rd_req     : IN STD_LOGIC;								--读SDRAM请求信号
      sdram_wr_ack     : OUT STD_LOGIC;							--写SDRAM响应信号
      sdram_rd_ack     : OUT STD_LOGIC;							--读SDRAM响应信号
      sdram_wr_burst   : IN STD_LOGIC_VECTOR(9 DOWNTO 0);	--突发写SDRAM字节数（1-512个）
      sdram_rd_burst   : IN STD_LOGIC_VECTOR(9 DOWNTO 0);	--突发读SDRAM字节数（1-256个）
      sdram_init_done  : OUT STD_LOGIC;							--SDRAM系统初始化完毕信号
      init_state       : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);	--SDRAM初始化状态
      work_state       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);	--SDRAM工作状态
      cnt_clk          : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);	--时钟计数器
      sdram_rd_wr      : OUT STD_LOGIC								--SDRAM读/写控制信号，低电平为写，高电平为读
   );
end component;

component sdram_cmd is
   PORT (
      clk             : IN STD_LOGIC;							--系统时钟
      rst_n           : IN STD_LOGIC;							--低电平复位信号
      
      sys_wraddr      : IN STD_LOGIC_VECTOR(23 DOWNTO 0);--写SDRAM时地址
      sys_rdaddr      : IN STD_LOGIC_VECTOR(23 DOWNTO 0);--读SDRAM时地址
      sdram_wr_burst  : IN STD_LOGIC_VECTOR(9 DOWNTO 0);	--突发写SDRAM字节数
      sdram_rd_burst  : IN STD_LOGIC_VECTOR(9 DOWNTO 0);	--突发读SDRAM字节数
      
      init_state      : IN STD_LOGIC_VECTOR(4 DOWNTO 0);	--SDRAM初始化状态
      work_state      : IN STD_LOGIC_VECTOR(3 DOWNTO 0);	--SDRAM工作状态
      cnt_clk         : IN STD_LOGIC_VECTOR(9 DOWNTO 0);	--延时计数器 
      sdram_rd_wr     : IN STD_LOGIC;							--SDRAM读/写控制信号，低电平为写
      
      sdram_cke       : OUT STD_LOGIC;							--SDRAM时钟有效信号
      sdram_cs_n      : OUT STD_LOGIC;							--SDRAM片选信号
      sdram_ras_n     : OUT STD_LOGIC;							--SDRAM行地址选通脉冲
      sdram_cas_n     : OUT STD_LOGIC;							--SDRAM列地址选通脉冲
      sdram_we_n      : OUT STD_LOGIC;							--SDRAM写允许位
      sdram_ba        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);--SDRAM的L-Bank地址线
      sdram_addr      : OUT STD_LOGIC_VECTOR(12 DOWNTO 0)--SDRAM地址总线
   );
end component;

component sdram_datas is
   PORT (
      clk             : IN STD_LOGIC;								--系统时钟
      rst_n           : IN STD_LOGIC;								--低电平复位信号
      
      sdram_data_in   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);	--写入SDRAM中的数据
      sdram_data_out  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);	--从SDRAM中读取的数据
      work_state      : IN STD_LOGIC_VECTOR(3 DOWNTO 0);		--SDRAM工作状态寄存器
      cnt_clk         : IN STD_LOGIC_VECTOR(9 DOWNTO 0);		--时钟计数
      
      sdram_data      : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)	--SDRAM数据总线
   );
end component;
   SIGNAL init_state            : STD_LOGIC_VECTOR(4 DOWNTO 0);		--SDRAM初始化状态
   SIGNAL work_state            : STD_LOGIC_VECTOR(3 DOWNTO 0);		--SDRAM工作状态
   SIGNAL cnt_clk               : STD_LOGIC_VECTOR(9 DOWNTO 0);		--延时计数器
   SIGNAL sdram_rd_wr           : STD_LOGIC;									--SDRAM读/写控制信号,低电平为写，高电平为读
   
   SIGNAL sdram_wr_ack_signal   : STD_LOGIC;
   SIGNAL sdram_rd_ack_signal    : STD_LOGIC;
   SIGNAL sdram_dout_signal      : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL sdram_init_done_signal : STD_LOGIC;
   SIGNAL sdram_cke_signal       : STD_LOGIC;
   SIGNAL sdram_cs_n_signal      : STD_LOGIC;
   SIGNAL sdram_ras_n_signal     : STD_LOGIC;
   SIGNAL sdram_cas_n_signal     : STD_LOGIC;
   SIGNAL sdram_we_n_signal      : STD_LOGIC;
   SIGNAL sdram_ba_signal        : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL sdram_addr_signal      : STD_LOGIC_VECTOR(12 DOWNTO 0);
BEGIN
   sdram_wr_ack <= sdram_wr_ack_signal;
   sdram_rd_ack <= sdram_rd_ack_signal;
   sdram_dout <= sdram_dout_signal;
   sdram_init_done <= sdram_init_done_signal;
   sdram_cke <= sdram_cke_signal;
   sdram_cs_n <= sdram_cs_n_signal;
   sdram_ras_n <= sdram_ras_n_signal;
   sdram_cas_n <= sdram_cas_n_signal;
   sdram_we_n <= sdram_we_n_signal;
   sdram_ba <= sdram_ba_signal;
   sdram_addr <= sdram_addr_signal;
   
   --SDRAM 状态控制模块
   u_sdram_ctrl : sdram_ctrl
      PORT MAP (
         clk              => clk,
         rst_n            => rst_n,
         
         sdram_wr_req     => sdram_wr_req,
         sdram_rd_req     => sdram_rd_req,
         sdram_wr_ack     => sdram_wr_ack_signal,
         sdram_rd_ack     => sdram_rd_ack_signal,
         sdram_wr_burst   => sdram_wr_burst,
         sdram_rd_burst   => sdram_rd_burst,
         sdram_init_done  => sdram_init_done_signal,
         
         init_state       => init_state,
         work_state       => work_state,
         cnt_clk          => cnt_clk,
         sdram_rd_wr      => sdram_rd_wr
      );
   
   --SDRAM 命令控制模块
   u_sdram_cmd : sdram_cmd
      PORT MAP (
         clk             => clk,
         rst_n           => rst_n,
         
         sys_wraddr      => sdram_wr_addr,
         sys_rdaddr      => sdram_rd_addr,
         sdram_wr_burst  => sdram_wr_burst,
         sdram_rd_burst  => sdram_rd_burst,
         
         init_state      => init_state,
         work_state      => work_state,
         cnt_clk         => cnt_clk,
         sdram_rd_wr     => sdram_rd_wr,
         
         sdram_cke       => sdram_cke_signal,
         sdram_cs_n      => sdram_cs_n_signal,
         sdram_ras_n     => sdram_ras_n_signal,
         sdram_cas_n     => sdram_cas_n_signal,
         sdram_we_n      => sdram_we_n_signal,
         sdram_ba        => sdram_ba_signal,
         sdram_addr      => sdram_addr_signal
      );
   
   --SDRAM 数据读写模块
   u_sdram_datas : sdram_datas
      PORT MAP (
         clk             => clk,
         rst_n           => rst_n,
         
         sdram_data_in   => sdram_din,
         sdram_data_out  => sdram_dout_signal,
         work_state      => work_state,
         cnt_clk         => cnt_clk,
         
         sdram_data      => sdram_data
      );
   
END structure;



