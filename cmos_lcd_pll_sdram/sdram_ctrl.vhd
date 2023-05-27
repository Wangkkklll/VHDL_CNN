LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;

ENTITY sdram_ctrl IS
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
END sdram_ctrl;

ARCHITECTURE behav OF sdram_ctrl IS
   ----------------------------------------------------------------
   --SDRAM 初始化过程各个状态
	CONSTANT	I_NOP		: STD_LOGIC_VECTOR(4 DOWNTO 0):="00000";		--等待上电200us稳定期结束
	CONSTANT	I_PRE		: STD_LOGIC_VECTOR(4 DOWNTO 0):="00001";		--预充电状态
	CONSTANT	I_TRP		: STD_LOGIC_VECTOR(4 DOWNTO 0):="00010";		--等待预充电完成       tRP
	CONSTANT	I_AR		: STD_LOGIC_VECTOR(4 DOWNTO 0):="00011";		--自动刷新
	CONSTANT	I_TRF		: STD_LOGIC_VECTOR(4 DOWNTO 0):="00100";		--等待自动刷新结束    tRC
	CONSTANT	I_MRS		: STD_LOGIC_VECTOR(4 DOWNTO 0):="00101";		--模式寄存器设置
	CONSTANT	I_TRSC	: STD_LOGIC_VECTOR(4 DOWNTO 0):="00110";		--等待模式寄存器设置完成 tRSC
	CONSTANT	I_DONE	: STD_LOGIC_VECTOR(4 DOWNTO 0):="00111";		--初始化完成
	--SDRAM 工作过程各个状态
	CONSTANT	W_IDLE	: STD_LOGIC_VECTOR(3 DOWNTO 0):="0000";		--空闲
	CONSTANT	W_ACTIVE	: STD_LOGIC_VECTOR(3 DOWNTO 0):="0001";		--行有效
	CONSTANT	W_TRCD	: STD_LOGIC_VECTOR(3 DOWNTO 0):="0010";		--行有效等待
	CONSTANT	W_READ	: STD_LOGIC_VECTOR(3 DOWNTO 0):="0011";		--读操作
	CONSTANT	W_CL		: STD_LOGIC_VECTOR(3 DOWNTO 0):="0100";		--潜伏期
	CONSTANT	W_RD		: STD_LOGIC_VECTOR(3 DOWNTO 0):="0101";		--读数据
	CONSTANT	W_WRITE	: STD_LOGIC_VECTOR(3 DOWNTO 0):="0110";		--写操作
	CONSTANT	W_WD		: STD_LOGIC_VECTOR(3 DOWNTO 0):="0111";		--写数据
	CONSTANT	W_TWR		: STD_LOGIC_VECTOR(3 DOWNTO 0):="1000";		--写回
	CONSTANT	W_PRE		: STD_LOGIC_VECTOR(3 DOWNTO 0):="1001";		--预充电
	CONSTANT	W_TRP		: STD_LOGIC_VECTOR(3 DOWNTO 0):="1010";		--预充电等待
	CONSTANT	W_AR		: STD_LOGIC_VECTOR(3 DOWNTO 0):="1011";		--自动刷新
	CONSTANT	W_TRFC 	: STD_LOGIC_VECTOR(3 DOWNTO 0):="1100";		--自动刷新等待
	--SDRAM控制信号命令
	CONSTANT	CMD_INIT		: STD_LOGIC_VECTOR(4 DOWNTO 0):="01111";	--INITIATE
	CONSTANT	CMD_NOP		: STD_LOGIC_VECTOR(4 DOWNTO 0):="10111";	--NOP COMMAND
	CONSTANT	CMD_ACTIVE	: STD_LOGIC_VECTOR(4 DOWNTO 0):="10011";	--ACTIVE COMMAND
	CONSTANT	CMD_READ		: STD_LOGIC_VECTOR(4 DOWNTO 0):="10101";	--READ COMMADN
	CONSTANT	CMD_WRITE	: STD_LOGIC_VECTOR(4 DOWNTO 0):="10100";	--WRITE COMMAND
	CONSTANT	CMD_B_STOP	: STD_LOGIC_VECTOR(4 DOWNTO 0):="10110";	--BURST STOP
	CONSTANT	CMD_PRGE		: STD_LOGIC_VECTOR(4 DOWNTO 0):="10010";	--PRECHARGE
	CONSTANT	CMD_A_REF	: STD_LOGIC_VECTOR(4 DOWNTO 0):="10001";	--AOTO REFRESH
	CONSTANT	CMD_LMR		: STD_LOGIC_VECTOR(4 DOWNTO 0):="10000";	--LODE MODE REGISTER
	
	--延时参数
	SIGNAL end_trp       : STD_LOGIC; 
	SIGNAL end_trfc      : STD_LOGIC; 
	SIGNAL end_trsc      : STD_LOGIC; 
	SIGNAL end_trcd      : STD_LOGIC; 
	SIGNAL end_tcl       : STD_LOGIC;
	SIGNAL end_tread     : STD_LOGIC;
	SIGNAL end_twrite    : STD_LOGIC;
	SIGNAL end_twr			: STD_LOGIC;
	------------------------------------------------------------
	
	CONSTANT TRP_CLK	: STD_LOGIC_VECTOR(9 DOWNTO 0):="0000000100";	--预充电有效周期
	CONSTANT TRC_CLK	: STD_LOGIC_VECTOR(9 DOWNTO 0):="0000000110";	--自动刷新周期
	CONSTANT TRSC_CLK	: STD_LOGIC_VECTOR(9 DOWNTO 0):="0000000110";	--模式寄存器设置时钟周期
	CONSTANT TRCD_CLK	: STD_LOGIC_VECTOR(9 DOWNTO 0):="0000000010";	--行选通周期
	CONSTANT TCL_CLK	: STD_LOGIC_VECTOR(9 DOWNTO 0):="0000000011";	--列潜伏期
	CONSTANT TWR_CLK	: STD_LOGIC_VECTOR(9 DOWNTO 0):="0000000010";	--写入校正
	
	
   SIGNAL cnt_200us             : STD_LOGIC_VECTOR(14 DOWNTO 0);		--SDRAM 上电稳定期200us计数器
   SIGNAL cnt_refresh           : STD_LOGIC_VECTOR(10 DOWNTO 0);		--刷新计数寄存器
   SIGNAL sdram_ref_req         : STD_LOGIC;									--SDRAM 自动刷新请求信号
   SIGNAL cnt_rst_n             : STD_LOGIC;									--延时计数器复位信号，低有效
   SIGNAL init_ar_cnt           : STD_LOGIC_VECTOR(3 DOWNTO 0);		--初始化过程自动刷新计数器
   
   SIGNAL done_200us            : STD_LOGIC;									--上电后200us输入稳定期结束标志位
   SIGNAL sdram_ref_ack         : STD_LOGIC;									--SDRAM自动刷新请求应答信号	
  
   SIGNAL sig1 : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL sig2 : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL sig3 : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL sig4 : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL sig5 : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL sig6 : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL sig7 : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL sig8 : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL sig9 : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL sig10 : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL sig11 : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL sig12 : STD_LOGIC;
   SIGNAL sig13 : STD_LOGIC;
   SIGNAL sig14 : STD_LOGIC;
   SIGNAL sig15 : STD_LOGIC;
   SIGNAL sig16 : STD_LOGIC;
   SIGNAL sig17 : STD_LOGIC;
   SIGNAL sig18 : STD_LOGIC;
   SIGNAL sig19 : STD_LOGIC;
   SIGNAL sig20 : STD_LOGIC;
   SIGNAL sig21 : STD_LOGIC;
   
   SIGNAL sdram_init_done_signal : STD_LOGIC;
   SIGNAL init_state_signal      : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL work_state_signal      : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL cnt_clk_signal         : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL sdram_rd_wr_signal     : STD_LOGIC;
BEGIN
-------------------------------------------------------------------------
	end_trp <= '1' WHEN (cnt_clk_signal = TRP_CLK) ELSE '0';									--预充电有效周期结束
	end_trfc <= '1' WHEN (cnt_clk_signal = TRC_CLK) ELSE '0';								--自动刷新周期结束
	end_trsc <= '1' WHEN (cnt_clk_signal = TRSC_CLK) ELSE '0';								--模式寄存器设置时钟周期结束
	end_trcd <= '1' WHEN (cnt_clk_signal = TRCD_CLK - "0000000001") ELSE '0';			--行选通周期结束
	end_tcl <= '1' WHEN (cnt_clk_signal = TCL_CLK - "0000000001") ELSE '0';				--潜伏期结束
	end_tread <= '1' WHEN (cnt_clk_signal = sdram_rd_burst + "0000000010") ELSE '0';	--突发读结束
	end_twrite <= '1' WHEN (cnt_clk_signal = sdram_wr_burst - "0000000001") ELSE '0';--突发写结束
	end_twr <= '1' WHEN (cnt_clk_signal = TWR_CLK) ELSE '0';									--写回周期结束
-------------------------------------------------------------------------

   sdram_init_done <= sdram_init_done_signal;
   init_state <= init_state_signal;
   work_state <= work_state_signal;
   cnt_clk <= cnt_clk_signal;
   sdram_rd_wr <= sdram_rd_wr_signal;
   
	--SDRAM上电后200us稳定期结束后,将标志信号拉高
   done_200us <= '1' WHEN(cnt_200us = "100111000100000") ELSE '0';
   --SDRAM初始化完成标志
   sdram_init_done_signal <= '1' WHEN (init_state_signal = I_DONE) ELSE '0';
   --SDRAM 自动刷新应答信号
   sdram_ref_ack <= '1' WHEN (work_state_signal = W_AR) ELSE '0';
   --写SDRAM响应信号
   sdram_wr_ack <= '1' WHEN (((work_state_signal = W_TRCD) AND (sdram_rd_wr_signal = '0')) OR (work_state_signal = W_WRITE) OR ((work_state_signal = W_WD) AND (cnt_clk_signal < sdram_wr_burst - "0000000010"))) ELSE '0';
   --读SDRAM响应信号
   sdram_rd_ack <= '1' WHEN ((work_state_signal = W_RD) AND (cnt_clk_signal >= "0000000001") AND (cnt_clk_signal < sdram_rd_burst + "0000000001")) ELSE '0';
   --上电后计时200us,等待SDRAM状态稳定
   PROCESS (clk, rst_n)
   BEGIN
      IF (rst_n = '0') THEN
         cnt_200us <= "000000000000000";
      ELSIF (clk'EVENT AND clk = '1') THEN
         IF (cnt_200us < "100111000100000") THEN
            cnt_200us <= cnt_200us + "000000000000001";
         ELSE
            cnt_200us <= cnt_200us;
         END IF;
      END IF;
   END PROCESS;
   
   --刷新计数器循环计数7812ns (60ms内完成全部8192行刷新操作)
   PROCESS (clk, rst_n)
   BEGIN
      IF (rst_n = '0') THEN
         cnt_refresh <= "00000000000";
      ELSIF (clk'EVENT AND clk = '1') THEN
         IF (cnt_refresh < "01100001101") THEN
            cnt_refresh <= cnt_refresh + "00000000001";
         ELSE
            cnt_refresh <= "00000000000";
         END IF;
      END IF;
   END PROCESS;
   
   --SDRAM 刷新请求
   PROCESS (clk, rst_n)
   BEGIN
      IF (rst_n = '0') THEN
         sdram_ref_req <= '0';
      ELSIF (clk'EVENT AND clk = '1') THEN
         IF (cnt_refresh = "01100001100") THEN
            sdram_ref_req <= '1';					--刷新计数器计时达7812ns时产生刷新请求
         ELSIF (sdram_ref_ack = '1') THEN
            sdram_ref_req <= '0';					--收到刷新请求响应信号后取消刷新请求
         END IF;
      END IF;
   END PROCESS;
   
   --延时计数器对时钟计数
   PROCESS (clk, rst_n)
   BEGIN
      IF (rst_n = '0') THEN
         cnt_clk_signal <= "0000000000";
      ELSIF (clk'EVENT AND clk = '1') THEN
         IF (cnt_rst_n = '0') THEN					--在cnt_rst_n为低电平时延时计数器清零
            cnt_clk_signal <= "0000000000";
         ELSE
            cnt_clk_signal <= cnt_clk_signal + "0000000001";
         END IF;
      END IF;
   END PROCESS;
   
   --初始化过程中对自动刷新操作计数
   PROCESS (clk, rst_n)
   BEGIN
      IF (rst_n = '0') THEN
         init_ar_cnt <= "0000";
      ELSIF (clk'EVENT AND clk = '1') THEN
         IF (init_state_signal = I_NOP) THEN
            init_ar_cnt <= "0000";
         ELSIF (init_state_signal = I_AR) THEN
            init_ar_cnt <= init_ar_cnt + "0001";
         ELSE
            init_ar_cnt <= init_ar_cnt;
         END IF;
      END IF;
   END PROCESS;
   
   
   --SDRAM的初始化状态机
   sig1 <= I_PRE WHEN (done_200us = '1') ELSE I_NOP;
   sig2 <= I_AR WHEN (end_trp = '1') ELSE I_TRP;
   sig3 <= I_MRS WHEN (init_ar_cnt = "1000") ELSE I_AR;
   sig4 <= (sig3) WHEN (end_trfc = '1') ELSE I_TRF;
   sig5 <= I_DONE WHEN (end_trsc = '1') ELSE I_TRSC;
   PROCESS (clk, rst_n)
   BEGIN
      IF (rst_n = '0') THEN
         init_state_signal <= I_NOP;
      ELSIF (clk'EVENT AND clk = '1') THEN
         CASE init_state_signal IS
            WHEN I_NOP =>							--上电复位后200us结束则进入下一状态
               init_state_signal <= sig1;
            WHEN I_PRE =>							--预充电状态
               init_state_signal <= I_TRP;
            WHEN I_TRP =>							--预充电等待，TRP_CLK个时钟周期
               init_state_signal <= sig2;
            WHEN I_AR =>							--自动刷新
               init_state_signal <= I_TRF;
            WHEN I_TRF =>							--等待自动刷新结束,TRC_CLK个时钟周期
               init_state_signal <= sig4;		--连续8次自动刷新操作
            WHEN I_MRS =>							--模式寄存器设置
               init_state_signal <= I_TRSC;
            WHEN I_TRSC =>							--等待模式寄存器设置完成，TRSC_CLK个时钟周期
               init_state_signal <= sig5;
            WHEN I_DONE =>							--SDRAM的初始化设置完成标志
               init_state_signal <= I_DONE;
            WHEN OTHERS =>
               init_state_signal <= I_NOP;
         END CASE;
      END IF;
   END PROCESS;
   
   
   --SDRAM的工作状态机,工作包括读、写以及自动刷新操作
   sig6 <= W_RD WHEN (end_tcl = '1') ELSE W_CL;
   sig7 <= W_PRE WHEN (end_tread = '1') ELSE W_RD;
   sig8 <= W_TWR WHEN (end_twrite = '1') ELSE W_WD;
   sig9 <= W_PRE WHEN (end_twr = '1') ELSE W_TWR;
   sig10 <= W_IDLE WHEN (end_trp = '1') ELSE W_TRP;
   sig11 <= W_IDLE WHEN (end_trfc = '1') ELSE W_TRFC;
   PROCESS (clk, rst_n)
   BEGIN
      IF (rst_n = '0') THEN
         work_state_signal <= W_IDLE;			--空闲状态
      ELSIF (clk'EVENT AND clk = '1') THEN
         CASE work_state_signal IS
            WHEN W_IDLE =>							
               IF (sdram_ref_req = '1' AND sdram_init_done_signal = '1') THEN		--定时自动刷新请求，跳转到自动刷新状态
                  work_state_signal <= W_AR;
                  sdram_rd_wr_signal <= '1';
               ELSIF (sdram_wr_req = '1' AND sdram_init_done_signal = '1') THEN	--写SDRAM请求，跳转到行有效状态
                  work_state_signal <= W_ACTIVE;
                  sdram_rd_wr_signal <= '0';
               ELSIF (sdram_rd_req = '1' AND sdram_init_done_signal = '1') THEN	--读SDRAM请求，跳转到行有效状态
                  work_state_signal <= W_ACTIVE;
                  sdram_rd_wr_signal <= '1';
               ELSE																					--无操作请求，保持空闲状态
                  work_state_signal <= W_IDLE;
                  sdram_rd_wr_signal <= '1';
               END IF;
            WHEN W_ACTIVE =>									--行有效，跳转到行有效等待状态
               work_state_signal <= W_TRCD;
            WHEN  W_TRCD =>
               IF (end_trcd = '1') THEN					--行有效等待结束，判断当前是读还是写
                  IF (sdram_rd_wr_signal = '1') THEN	--读：进入读操作状态
                     work_state_signal <= W_READ;
                  ELSE											--写：进入写操作状态
                     work_state_signal <= W_WRITE;
                  END IF;
               ELSE
                  work_state_signal <= W_TRCD;
               END IF;
            WHEN W_READ =>							--读操作，跳转到潜伏期
               work_state_signal <= W_CL;
            WHEN W_CL =>							--潜伏期：等待潜伏期结束，跳转到读数据状态
               work_state_signal <= sig6;
            WHEN W_RD =>							--读数据：等待读数据结束，跳转到预充电状态
               work_state_signal <= sig7;
            WHEN W_WRITE =>						--写操作：跳转到写数据状态
               work_state_signal <= W_WD;
            WHEN W_WD =>							--写数据：等待写数据结束，跳转到写回周期状态
               work_state_signal <= sig8;
            WHEN W_TWR =>							--写回周期：写回周期结束，跳转到预充电状态
               work_state_signal <= sig9;
            WHEN W_PRE =>							--预充电：跳转到预充电等待状态
               work_state_signal <= W_TRP;
            WHEN W_TRP =>							--预充电等待：预充电等待结束，进入空闲状态
               work_state_signal <= sig10;
            WHEN W_AR =>							--自动刷新操作，跳转到自动刷新等待
               work_state_signal <= W_TRFC;
            WHEN W_TRFC =>							--自动刷新等待：自动刷新等待结束，进入空闲状态
               work_state_signal <= sig11;
            WHEN OTHERS =>
               work_state_signal <= W_IDLE;
         END CASE;
      END IF;
   END PROCESS;
   
   
   --计数器控制逻辑
   sig12 <= '0' WHEN (end_trp = '1') ELSE '1';
   sig13 <= '0' WHEN (end_trfc = '1') ELSE '1';
   sig14 <= '0' WHEN (end_trsc = '1') ELSE '1';
   sig15 <= '0' WHEN (end_trcd = '1') ELSE '1';
   sig16 <= '0' WHEN (end_tcl = '1') ELSE '1';
   sig17 <= '0' WHEN (end_tread = '1') ELSE '1';
   sig18 <= '0' WHEN (end_twrite = '1') ELSE '1';
   sig19 <= '0' WHEN (end_twr = '1') ELSE '1';
   sig20 <= '0' WHEN (end_trp = '1') ELSE '1';
   sig21 <= '0' WHEN (end_trfc = '1') ELSE '1';
   PROCESS (init_state_signal,  work_state_signal)
   BEGIN
      CASE init_state_signal IS
         WHEN I_NOP =>						--延时计数器清零(cnt_rst_n低电平复位)
            cnt_rst_n <= '0';
         WHEN I_PRE =>						--预充电：延时计数器启动(cnt_rst_n高电平启动)
            cnt_rst_n <= '1';
         WHEN I_TRP =>						--等待预充电延时计数结束后，清零计数器
            cnt_rst_n <= sig12;
         WHEN I_AR =>						--自动刷新：延时计数器启动
            cnt_rst_n <= '1';
         WHEN I_TRF =>						--等待自动刷新延时计数结束后，清零计数器
            cnt_rst_n <= sig13;
         WHEN I_MRS =>						--模式寄存器设置：延时计数器启动
            cnt_rst_n <= '1';
         WHEN I_TRSC =>						--等待模式寄存器设置延时计数结束后，清零计数器
            cnt_rst_n <= sig14;
         WHEN I_DONE =>						--初始化完成后,判断工作状态
            CASE work_state_signal IS
               WHEN W_IDLE =>
                  cnt_rst_n <= '0';
               WHEN W_ACTIVE =>			--行有效：延时计数器启动
                  cnt_rst_n <= '1';
               WHEN W_TRCD =>				--行有效延时计数结束后，清零计数器
                  cnt_rst_n <= sig15;
               WHEN W_CL =>				--潜伏期延时计数结束后，清零计数器
                  cnt_rst_n <= sig16;
               WHEN W_RD =>				--读数据延时计数结束后，清零计数器
                  cnt_rst_n <= sig17;
               WHEN W_WD =>				--写数据延时计数结束后，清零计数器
                  cnt_rst_n <= sig18;
               WHEN W_TWR =>				--写数据延时计数结束后，清零计数器
                  cnt_rst_n <= sig19;
               WHEN W_TRP =>				--预充电等待延时计数结束后，清零计数器
                  cnt_rst_n <= sig20;
               WHEN W_TRFC =>				--自动刷新等待延时计数结束后，清零计数器
                  cnt_rst_n <= sig21;
               WHEN OTHERS =>
                  cnt_rst_n <= '0';
            END CASE;
         WHEN OTHERS =>
            cnt_rst_n <= '0';
      END CASE;
   END PROCESS;
   
   
END behav;


