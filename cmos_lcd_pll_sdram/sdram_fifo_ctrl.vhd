LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
	
ENTITY sdram_fifo_ctrl IS
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
END sdram_fifo_ctrl;

ARCHITECTURE behav OF sdram_fifo_ctrl IS
component rdfifo is
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		wrusedw		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
end component;

component wrfifo is
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdusedw		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
end component; 
   SIGNAL wr_ack_r1           : STD_LOGIC;							--sdram写响应寄存器
   SIGNAL wr_ack_r2           : STD_LOGIC;
   SIGNAL rd_ack_r1           : STD_LOGIC;							--sdram读响应寄存器
   SIGNAL rd_ack_r2           : STD_LOGIC;
   SIGNAL wr_load_r1          : STD_LOGIC;							--写端口复位寄存器
   SIGNAL wr_load_r2          : STD_LOGIC;
   SIGNAL rd_load_r1          : STD_LOGIC;							--读端口复位寄存器
   SIGNAL rd_load_r2          : STD_LOGIC;
   SIGNAL read_valid_r1       : STD_LOGIC;							--sdram读使能寄存器
   SIGNAL read_valid_r2       : STD_LOGIC;
   SIGNAL sw_bank_en          : STD_LOGIC;							--切换BANK使能信号
   SIGNAL rw_bank_flag        : STD_LOGIC;							--读写bank的标志
   
   SIGNAL write_done_flag     : STD_LOGIC;							--sdram_wr_ack 下降沿标志位
   SIGNAL read_done_flag      : STD_LOGIC;							--sdram_rd_ack 下降沿标志位
   SIGNAL wr_load_flag        : STD_LOGIC;							--wr_load      上升沿标志位 
   SIGNAL rd_load_flag        : STD_LOGIC;							--rd_load      上升沿标志位
   SIGNAL wrf_use             : STD_LOGIC_VECTOR(9 DOWNTO 0);	--写端口FIFO中的数据量
   SIGNAL rdf_use             : STD_LOGIC_VECTOR(9 DOWNTO 0);	--读端口FIFO中的数据量
   
   SIGNAL sig1  : STD_LOGIC;
   SIGNAL sig2  : STD_LOGIC;
   
   SIGNAL rdf_dout_signal      : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL sdram_wr_addr_signal : STD_LOGIC_VECTOR(23 DOWNTO 0);
   SIGNAL sdram_din_signal     : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL sdram_rd_addr_signal : STD_LOGIC_VECTOR(23 DOWNTO 0);
BEGIN
   rdf_dout <= rdf_dout_signal;
   sdram_wr_addr <= sdram_wr_addr_signal;
   sdram_din <= sdram_din_signal;
   sdram_rd_addr <= sdram_rd_addr_signal;
   --检测下降沿
   write_done_flag <= wr_ack_r2 AND NOT(wr_ack_r1);
   read_done_flag <= rd_ack_r2 AND NOT(rd_ack_r1);
   --检测上升沿
   wr_load_flag <= NOT(wr_load_r2) AND wr_load_r1;
   rd_load_flag <= NOT(rd_load_r2) AND rd_load_r1;
   --寄存sdram写响应信号,用于捕获sdram_wr_ack下降沿
   PROCESS (clk_ref, rst_n)
   BEGIN
      IF (rst_n = '0') THEN
         wr_ack_r1 <= '0';
         wr_ack_r2 <= '0';
      ELSIF (clk_ref'EVENT AND clk_ref = '1') THEN
         wr_ack_r1 <= sdram_wr_ack;
         wr_ack_r2 <= wr_ack_r1;
      END IF;
   END PROCESS;
   
   --寄存sdram读响应信号,用于捕获sdram_rd_ack下降沿
   PROCESS (clk_ref, rst_n)
   BEGIN
      IF (rst_n = '0') THEN
         rd_ack_r1 <= '0';
         rd_ack_r2 <= '0';
      ELSIF (clk_ref'EVENT AND clk_ref = '1') THEN
         rd_ack_r1 <= sdram_rd_ack;
         rd_ack_r2 <= rd_ack_r1;
      END IF;
   END PROCESS;
   
   --同步写端口复位信号，用于捕获wr_load上升沿
   PROCESS (clk_ref, rst_n)
   BEGIN
      IF (rst_n = '0') THEN
         wr_load_r1 <= '0';
         wr_load_r2 <= '0';
      ELSIF (clk_ref'EVENT AND clk_ref = '1') THEN
         wr_load_r1 <= wr_load;
         wr_load_r2 <= wr_load_r1;
      END IF;
   END PROCESS;
   
   --同步读端口复位信号，同时用于捕获rd_load上升沿
   PROCESS (clk_ref, rst_n)
   BEGIN
      IF (rst_n = '0') THEN
         rd_load_r1 <= '0';
         rd_load_r2 <= '0';
      ELSIF (clk_ref'EVENT AND clk_ref = '1') THEN
         rd_load_r1 <= rd_load;
         rd_load_r2 <= rd_load_r1;
      END IF;
   END PROCESS;
   
   --同步sdram读使能信号
   PROCESS (clk_ref, rst_n)
   BEGIN
      IF (rst_n = '0') THEN
         read_valid_r1 <= '0';
         read_valid_r2 <= '0';
      ELSIF (clk_ref'EVENT AND clk_ref = '1') THEN
         read_valid_r1 <= sdram_read_valid;
         read_valid_r2 <= read_valid_r1;
      END IF;
   END PROCESS;
   
   --sdram写地址产生模块
   PROCESS (clk_ref, rst_n)
   BEGIN
      IF (rst_n = '0') THEN
         sdram_wr_addr_signal <= "000000000000000000000000";
         sw_bank_en <= '0';
         rw_bank_flag <= '0';
      ELSIF (clk_ref'EVENT AND clk_ref = '1') THEN
         IF (wr_load_flag = '1') THEN							--检测到写端口复位信号时，写地址复位
            sdram_wr_addr_signal <= wr_min_addr;
            sw_bank_en <= '0';
            rw_bank_flag <= '0';
         ELSIF (write_done_flag = '1') THEN					--若突发写SDRAM结束，更改写地址
																			--若未到达写SDRAM的结束地址，则写地址累加
            IF (sdram_pingpang_en = '1') THEN				--SDRAM 读写乒乓使能
               IF ((sdram_wr_addr_signal(22 DOWNTO 0))  < (wr_max_addr  - wr_length)) THEN
                  sdram_wr_addr_signal <= sdram_wr_addr_signal + ("00000000000000" & wr_length);
               ELSE													--切换BANK
                  rw_bank_flag <= NOT(rw_bank_flag);
                  sw_bank_en <= '1';							--拉高切换BANK使能信号
               END IF;
																			--若突发写SDRAM结束，更改写地址
            ELSIF (sdram_wr_addr_signal < (wr_max_addr - wr_length)) THEN
               sdram_wr_addr_signal <= sdram_wr_addr_signal + ("00000000000000" & wr_length);
            ELSE														--到达写SDRAM的结束地址，回到写起始地址
               sdram_wr_addr_signal <= wr_min_addr;
            END IF;
         ELSIF (sw_bank_en = '1') THEN							--到达写SDRAM的结束地址，回到写起始地址
            sw_bank_en <= '0';
            IF (rw_bank_flag = '0') THEN						--切换BANK
               sdram_wr_addr_signal <= ('0' & wr_min_addr(22 DOWNTO 0));
            ELSE
               sdram_wr_addr_signal <= ('1' & wr_min_addr(22 DOWNTO 0));
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   --sdram读地址产生模块
   PROCESS (clk_ref, rst_n)
   BEGIN
      IF (rst_n = '0') THEN
         sdram_rd_addr_signal <= "000000000000000000000000";
      ELSIF (clk_ref'EVENT AND clk_ref = '1') THEN
         IF (rd_load_flag = '1') THEN							--检测到读端口复位信号时，读地址复位
            sdram_rd_addr_signal <= rd_min_addr;
         ELSIF (read_done_flag = '1') THEN					--突发读SDRAM结束，更改读地址
																			--若未到达读SDRAM的结束地址，则读地址累加
            IF (sdram_pingpang_en = '1') THEN				--SDRAM 读写乒乓使能
               IF ((sdram_rd_addr_signal(22 DOWNTO 0)) < (rd_max_addr - rd_length)) THEN
                  sdram_rd_addr_signal <= sdram_rd_addr_signal + ("00000000000000" & rd_length);
               ELSE													--到达读SDRAM的结束地址，回到读起始地址
																			--读取没有在写数据的bank地址
                  IF (rw_bank_flag = '0') THEN				--根据rw_bank_flag的值切换读BANK地址
                     sdram_rd_addr_signal <= ('1' & rd_min_addr(22 DOWNTO 0));
                  ELSE
                     sdram_rd_addr_signal <= ('0' & rd_min_addr(22 DOWNTO 0));
                  END IF;
               END IF;
																			--若突发写SDRAM结束，更改写地址
            ELSIF (sdram_rd_addr_signal < (rd_max_addr - rd_length)) THEN
               sdram_rd_addr_signal <= sdram_rd_addr_signal + ("00000000000000" & rd_length);
            ELSE														--到达写SDRAM的结束地址，回到写起始地址
               sdram_rd_addr_signal <= rd_min_addr;
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   --sdram 读写请求信号产生模块
   PROCESS (clk_ref, rst_n)
   BEGIN
      IF (rst_n = '0') THEN
         sdram_wr_req <= '0';
         sdram_rd_req <= '0';
      ELSIF (clk_ref'EVENT AND clk_ref = '1') THEN
         IF (sdram_init_done = '1') THEN					--SDRAM初始化完成后才能响应读写请求
																		--优先执行写操作，防止写入SDRAM中的数据丢失
            IF (wrf_use >= wr_length) THEN				--若写端口FIFO中的数据量达到了写突发长度
               sdram_wr_req <= '1';							--发出写sdarm请求
               sdram_rd_req <= '0';
            ELSIF ((rdf_use < rd_length) AND read_valid_r2 = '1') THEN	--若读端口FIFO中的数据量小于读突发长度，同时sdram读使能信号为高
               sdram_wr_req <= '0';
               sdram_rd_req <= '1';							--发出读sdarm请求
            ELSE
               sdram_wr_req <= '0';
               sdram_rd_req <= '0';
            END IF;
         ELSE
            sdram_wr_req <= '0';
            sdram_rd_req <= '0';
         END IF;
      END IF;
   END PROCESS;
   
   
   --例化写端口FIFO
   sig1 <= NOT(rst_n) OR wr_load_flag;
   u_wrfifo : wrfifo
      PORT MAP (
			--用户接口
         wrclk    => clk_write,				--写时钟
         wrreq    => wrf_wrreq,				--写请求
         data     => wrf_din,					--写数据
         --sdram接口
			rdclk    => clk_ref,					--读时钟
         rdreq    => sdram_wr_ack,			--读请求
         q        => sdram_din_signal,		--读数据
         
			rdusedw  => wrf_use,					--FIFO中的数据量
         aclr     => sig1						--异步清零信号
      );
   
   
   --例化读端口FIFO
   sig2 <= NOT(rst_n) OR rd_load_flag;
   u_rdfifo : rdfifo
      PORT MAP (
			--sdram接口
         wrclk    => clk_ref,					--写时钟
         wrreq    => sdram_rd_ack,			--写请求
         data     => sdram_dout,				--写数据
         --用户接口
			rdclk    => clk_read,				--读时钟
         rdreq    => rdf_rdreq,				--读请求
         q        => rdf_dout_signal,		--读数据
         
			wrusedw  => rdf_use,					--FIFO中的数据量
         aclr     => sig2						--异步清零信号
      );
   
END behav;



