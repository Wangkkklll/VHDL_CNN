LIBRARY ieee;
   USE ieee.std_logic_1164.all;

	
ENTITY sdram_top IS
   PORT (
      ref_clk            : IN STD_LOGIC;									--sdram 控制器参考时钟
      out_clk            : IN STD_LOGIC;									--用于输出的相位偏移时钟
      rst_n              : IN STD_LOGIC;									--系统复位
      --用户写端口
      wr_clk             : IN STD_LOGIC;									--写端口FIFO: 写时钟
      wr_en              : IN STD_LOGIC;									--写端口FIFO: 写使能
      wr_data            : IN STD_LOGIC_VECTOR(15 DOWNTO 0);		--写端口FIFO: 写数据
      wr_min_addr        : IN STD_LOGIC_VECTOR(23 DOWNTO 0);		--写SDRAM的起始地址
      wr_max_addr        : IN STD_LOGIC_VECTOR(23 DOWNTO 0);		--写SDRAM的结束地址
      wr_len             : IN STD_LOGIC_VECTOR(9 DOWNTO 0);			--写SDRAM时的数据突发长度
      wr_load            : IN STD_LOGIC;									--写端口复位: 复位写地址,清空写FIFO
      --用户读端口
      rd_clk             : IN STD_LOGIC;									--读端口FIFO: 读时钟
      rd_en              : IN STD_LOGIC;									--读端口FIFO: 读使能
      rd_data            : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);		--读端口FIFO: 读数据
      rd_min_addr        : IN STD_LOGIC_VECTOR(23 DOWNTO 0);		--读SDRAM的起始地址
      rd_max_addr        : IN STD_LOGIC_VECTOR(23 DOWNTO 0);		--读SDRAM的结束地址
      rd_len             : IN STD_LOGIC_VECTOR(9 DOWNTO 0);			--从SDRAM中读数据时的突发长度
      rd_load            : IN STD_LOGIC;									--读端口复位: 复位读地址,清空读FIFO
      --用户控制端口
      sdram_read_valid   : IN STD_LOGIC;									--SDRAM 读使能
      sdram_pingpang_en  : IN STD_LOGIC;									--SDRAM 乒乓操作使能
      sdram_init_done    : OUT STD_LOGIC;									--SDRAM 初始化完成标志
      --SDRAM 芯片接口
      sdram_clk          : OUT STD_LOGIC;									--SDRAM 芯片时钟
      sdram_cke          : OUT STD_LOGIC;									--SDRAM 时钟有效
      sdram_cs_n         : OUT STD_LOGIC;									--SDRAM 片选
      sdram_ras_n        : OUT STD_LOGIC;									--SDRAM 行有效
      sdram_cas_n        : OUT STD_LOGIC;									--SDRAM 列有效
      sdram_we_n         : OUT STD_LOGIC;									--SDRAM 写有效
      sdram_ba           : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);		--SDRAM Bank地址
      sdram_addr         : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);		--SDRAM 行/列地址
      sdram_data         : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);	--SDRAM 数据
      sdram_dqm          : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)			--SDRAM 数据掩码
   );
END sdram_top;

ARCHITECTURE structure OF sdram_top IS
  component sdram_controller is
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
end component;

component sdram_fifo_ctrl is
	PORT (
      clk_ref            : IN STD_LOGIC;								--SDRAM控制器时钟
      rst_n              : IN STD_LOGIC;								--系统复位
      --用户写端口
      clk_write          : IN STD_LOGIC;								--写端口FIFO: 写时钟 
      wrf_wrreq          : IN STD_LOGIC;								--写端口FIFO: 写请求
      wrf_din            : IN STD_LOGIC_VECTOR(15 DOWNTO 0);	--写端口FIFO: 写数据
      wr_min_addr        : IN STD_LOGIC_VECTOR(23 DOWNTO 0);	--写SDRAM的起始地址
      wr_max_addr        : IN STD_LOGIC_VECTOR(23 DOWNTO 0);	--写SDRAM的结束地址
      wr_length          : IN STD_LOGIC_VECTOR(9 DOWNTO 0);		--写SDRAM时的数据突发长度 
      wr_load            : IN STD_LOGIC;								--写端口复位: 复位写地址,清空写FIFO 
      --用户读端口
      clk_read           : IN STD_LOGIC;								--读端口FIFO: 读时钟
      rdf_rdreq          : IN STD_LOGIC;								--读端口FIFO: 读请求
      rdf_dout           : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);	--读端口FIFO: 读数据
      rd_min_addr        : IN STD_LOGIC_VECTOR(23 DOWNTO 0);	--读SDRAM的起始地址
      rd_max_addr        : IN STD_LOGIC_VECTOR(23 DOWNTO 0);	--读SDRAM的结束地址
      rd_length          : IN STD_LOGIC_VECTOR(9 DOWNTO 0);		--从SDRAM中读数据时的突发长度
      rd_load            : IN STD_LOGIC;								--读端口复位: 复位读地址,清空读FIFO
      --用户控制端口 
      sdram_read_valid   : IN STD_LOGIC;								--SDRAM 读使能
      sdram_init_done    : IN STD_LOGIC;								--SDRAM 初始化完成标志
      sdram_pingpang_en  : IN STD_LOGIC;								--SDRAM 乒乓操作使能
      --SDRAM 控制器写端口
      sdram_wr_req       : OUT STD_LOGIC;								--sdram 写请求
      sdram_wr_ack       : IN STD_LOGIC;								--sdram 写响应
      sdram_wr_addr      : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);	--sdram 写地址
      sdram_din          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);	--写入SDRAM中的数据 
      --SDRAM 控制器读端口
      sdram_rd_req       : OUT STD_LOGIC;								--sdram 读请求
      sdram_rd_ack       : IN STD_LOGIC;								--sdram 读响应
      sdram_rd_addr      : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);	--sdram 读地址
      sdram_dout         : IN STD_LOGIC_VECTOR(15 DOWNTO 0)		--从SDRAM中读出的数据 
   );
end component;

   SIGNAL sdram_wr_req          : STD_LOGIC;								--sdram 写请求
   SIGNAL sdram_wr_ack          : STD_LOGIC;								--sdram 写响应
   SIGNAL sdram_wr_addr         : STD_LOGIC_VECTOR(23 DOWNTO 0);	--sdram 写地址
   SIGNAL sdram_din             : STD_LOGIC_VECTOR(15 DOWNTO 0);	--写入sdram中的数据
   
   SIGNAL sdram_rd_req          : STD_LOGIC;								--sdram 读请求
   SIGNAL sdram_rd_ack          : STD_LOGIC;								--sdram 读响应
   SIGNAL sdram_rd_addr         : STD_LOGIC_VECTOR(23 DOWNTO 0);	--sdram 读地址
   SIGNAL sdram_dout            : STD_LOGIC_VECTOR(15 DOWNTO 0);	--从sdram中读出的数据
   
   SIGNAL rd_data_signal         : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL sdram_init_done_signal : STD_LOGIC;
   SIGNAL sdram_cke_signal       : STD_LOGIC;
   SIGNAL sdram_cs_n_signal      : STD_LOGIC;
   SIGNAL sdram_ras_n_signal     : STD_LOGIC;
   SIGNAL sdram_cas_n_signal     : STD_LOGIC;
   SIGNAL sdram_we_n_signal      : STD_LOGIC;
   SIGNAL sdram_ba_signal        : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL sdram_addr_signal      : STD_LOGIC_VECTOR(12 DOWNTO 0);
BEGIN
   rd_data <= rd_data_signal;
   sdram_init_done <= sdram_init_done_signal;
   sdram_cke <= sdram_cke_signal;
   sdram_cs_n <= sdram_cs_n_signal;
   sdram_ras_n <= sdram_ras_n_signal;
   sdram_cas_n <= sdram_cas_n_signal;
   sdram_we_n <= sdram_we_n_signal;
   sdram_ba <= sdram_ba_signal;
   sdram_addr <= sdram_addr_signal;
   
   sdram_clk <= out_clk;	--将相位偏移时钟输出给sdram芯片
   sdram_dqm <= "00";		--读写过程中均不屏蔽数据线
   
   
   --SDRAM 读写端口FIFO控制模块
   u_sdram_fifo_ctrl : sdram_fifo_ctrl
      PORT MAP (
         clk_ref            => ref_clk,						--SDRAM控制器时钟
         rst_n              => rst_n,							--系统复位
         --用户写端口
         clk_write          => wr_clk,							--写端口FIFO: 写时钟
         wrf_wrreq          => wr_en,							--写端口FIFO: 写请求
         wrf_din            => wr_data,						--写端口FIFO: 写数据  
         wr_min_addr        => wr_min_addr,					--写SDRAM的起始地址
         wr_max_addr        => wr_max_addr,					--写SDRAM的结束地址
         wr_length          => wr_len,							--写SDRAM时的数据突发长度
         wr_load            => wr_load,						--写端口复位: 复位写地址,清空写FIFO
         --用户读端口
         clk_read           => rd_clk,							--读端口FIFO: 读时钟
         rdf_rdreq          => rd_en,							--读端口FIFO: 读请求
         rdf_dout           => rd_data_signal,				--读端口FIFO: 读数据
         rd_min_addr        => rd_min_addr,					--读SDRAM的起始地址
         rd_max_addr        => rd_max_addr,					--读SDRAM的结束地址
         rd_length          => rd_len,							--从SDRAM中读数据时的突发长度
         rd_load            => rd_load,						--读端口复位: 复位读地址,清空读FIFO
         --用户控制端口    
         sdram_read_valid   => sdram_read_valid,			--sdram 读使能
         sdram_init_done    => sdram_init_done_signal,	--sdram 初始化完成标志
         sdram_pingpang_en  => sdram_pingpang_en,			--sdram 乒乓操作使能
         --SDRAM 控制器写端口
         sdram_wr_req       => sdram_wr_req,					--sdram 写请求
         sdram_wr_ack       => sdram_wr_ack,					--sdram 写响应
         sdram_wr_addr      => sdram_wr_addr,				--sdram 写地址
         sdram_din          => sdram_din,						--写入sdram中的数据
         --SDRAM 控制器读端口
         sdram_rd_req       => sdram_rd_req,					--sdram 读请求
         sdram_rd_ack       => sdram_rd_ack,					--sdram 读响应
         sdram_rd_addr      => sdram_rd_addr,				--sdram 读地址
         sdram_dout         => sdram_dout						--从sdram中读出的数据
      );
   
   
   --SDRAM控制器
   u_sdram_controller : sdram_controller
      PORT MAP (
         clk              => ref_clk,							--sdram 控制器时钟
         rst_n            => rst_n,								--系统复位
         --SDRAM 控制器写端口 
         sdram_wr_req     => sdram_wr_req,					--sdram 写请求
         sdram_wr_ack     => sdram_wr_ack,					--sdram 写响应
         sdram_wr_addr    => sdram_wr_addr,					--sdram 写地址
         sdram_wr_burst   => wr_len,							--写sdram时数据突发长度
         sdram_din        => sdram_din,						--写入sdram中的数据
         --SDRAM 控制器读端口
         sdram_rd_req     => sdram_rd_req,					--sdram 读请求
         sdram_rd_ack     => sdram_rd_ack,					--sdram 读响应
         sdram_rd_addr    => sdram_rd_addr,					--sdram 读地址
         sdram_rd_burst   => rd_len,							--读sdram时数据突发长度
         sdram_dout       => sdram_dout,						--从sdram中读出的数据
         
         sdram_init_done  => sdram_init_done_signal,		--sdram 初始化完成标志
         
			--SDRAM 芯片接口
         sdram_cke        => sdram_cke_signal,				--SDRAM 时钟有效
         sdram_cs_n       => sdram_cs_n_signal,				--SDRAM 片选
         sdram_ras_n      => sdram_ras_n_signal,			--SDRAM 行有效
         sdram_cas_n      => sdram_cas_n_signal,			--SDRAM 列有效
         sdram_we_n       => sdram_we_n_signal,				--SDRAM 写有效
         sdram_ba         => sdram_ba_signal,				--SDRAM Bank地址
         sdram_addr       => sdram_addr_signal,				--SDRAM 行/列地址
         sdram_data       => sdram_data						--SDRAM 数据
      );
   
END structure;



