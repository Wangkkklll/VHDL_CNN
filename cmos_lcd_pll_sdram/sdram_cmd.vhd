LIBRARY ieee;
   USE ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	
ENTITY sdram_cmd IS
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
END sdram_cmd;

ARCHITECTURE behav OF sdram_cmd IS
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
	SIGNAL end_rdburst       : STD_LOGIC;   
   SIGNAL end_wrburst       : STD_LOGIC;
	------------------------------------------------------------
	
   SIGNAL cmd_r             : STD_LOGIC_VECTOR(4 DOWNTO 0);		--SDRAM操作指令
   SIGNAL sys_addr          : STD_LOGIC_VECTOR(23 DOWNTO 0);	--SDRAM读写地址
   
   SIGNAL sdram_cke_signal   : STD_LOGIC;
   SIGNAL sdram_cs_n_signal  : STD_LOGIC;
   SIGNAL sdram_ras_n_signal : STD_LOGIC;
   SIGNAL sdram_cas_n_signal : STD_LOGIC;
   SIGNAL sdram_we_n_signal  : STD_LOGIC;
BEGIN
	------------------------------------------------------
	end_rdburst <= '1' WHEN (cnt_clk = (sdram_rd_burst - "0000000100")) ELSE '0';		--读突发终止
	end_wrburst <= '1' WHEN (cnt_clk = (sdram_wr_burst - "0000000001")) ELSE '0';		--写突发终止
	-------------------------------------------------------
	
   sdram_cke <= sdram_cke_signal;
   sdram_cs_n <= sdram_cs_n_signal;
   sdram_ras_n <= sdram_ras_n_signal;
   sdram_cas_n <= sdram_cas_n_signal;
   sdram_we_n <= sdram_we_n_signal;
   
	--SDRAM 控制信号线赋值
   (sdram_cke_signal, sdram_cs_n_signal, sdram_ras_n_signal, sdram_cas_n_signal, sdram_we_n_signal) <= cmd_r;
	--SDRAM 读/写地址总线控制
   sys_addr <= sys_rdaddr WHEN (sdram_rd_wr = '1') ELSE
               sys_wraddr;
   
	--SDRAM 操作指令控制
   PROCESS (clk, rst_n)
   BEGIN
      IF (rst_n = '0') THEN
         cmd_r <= CMD_INIT;
         sdram_ba <= "11";
         sdram_addr <= "1111111111111";
      ELSIF (clk'EVENT AND clk = '1') THEN
         CASE init_state IS
																	--初始化过程中,以下状态不执行任何指令
            WHEN (I_NOP OR I_TRP OR I_TRF OR I_TRSC) =>
               cmd_r <= CMD_NOP;
               sdram_ba <= "11";
               sdram_addr <= "1111111111111";
            WHEN I_PRE =>									--预充电指令
               cmd_r <= CMD_PRGE;
               sdram_ba <= "11";
               sdram_addr <= "1111111111111";
            WHEN I_AR =>									--自动刷新指令
               cmd_r <= CMD_A_REF;
               sdram_ba <= "11";
               sdram_addr <= "1111111111111";
            WHEN I_MRS =>									--模式寄存器设置指令
               cmd_r <= CMD_LMR;
               sdram_ba <= "00";
               sdram_addr <= "0000000110111";
            WHEN I_DONE =>									--SDRAM初始化完成
               CASE work_state IS						--以下工作状态不执行任何指令
                  WHEN (W_IDLE OR W_TRCD OR W_CL OR W_TWR OR W_TRP OR W_TRFC) =>
                     cmd_r <= CMD_NOP;
                     sdram_ba <= "11";
                     sdram_addr <= "1111111111111";
                  WHEN W_ACTIVE =>						--行有效指令
                     cmd_r <= CMD_ACTIVE;
                     sdram_ba <= sys_addr(23 DOWNTO 22);
                     sdram_addr <= sys_addr(21 DOWNTO 9);
                  WHEN W_READ =>							--读操作指令
                     cmd_r <= CMD_READ;
                     sdram_ba <= sys_addr(23 DOWNTO 22);
                     sdram_addr <= ("0000" & sys_addr(8 DOWNTO 0));
                  WHEN W_RD =>							--突发传输终止指令
                     IF (end_rdburst = '1') THEN
                        cmd_r <= CMD_B_STOP;
                     ELSE
                        cmd_r <= CMD_NOP;
                        sdram_ba <= "11";
                        sdram_addr <= "1111111111111";
                     END IF;
                  WHEN W_WRITE =>						--写操作指令
                     cmd_r <= CMD_WRITE;
                     sdram_ba <= sys_addr(23 DOWNTO 22);
                     sdram_addr <= ("0000" & sys_addr(8 DOWNTO 0));
                  WHEN W_WD =>							--突发传输终止指令
                     IF (end_wrburst = '1') THEN
                        cmd_r <= CMD_B_STOP;
                     ELSE
                        cmd_r <= CMD_NOP;
                        sdram_ba <= "11";
                        sdram_addr <= "1111111111111";
                     END IF;
                  WHEN W_PRE =>							--预充电指令
                     cmd_r <= CMD_PRGE;
                     sdram_ba <= sys_addr(23 DOWNTO 22);
                     sdram_addr <= "0010000000000";
                  WHEN  W_AR =>							--自动刷新指令
                     cmd_r <= CMD_A_REF;
                     sdram_ba <= "11";
                     sdram_addr <= "1111111111111";
                  WHEN OTHERS =>
                     cmd_r <= CMD_NOP;
                     sdram_ba <= "11";
                     sdram_addr <= "1111111111111";
               END CASE;
            WHEN OTHERS =>
               cmd_r <= CMD_NOP;
               sdram_ba <= "11";
               sdram_addr <= "1111111111111";
         END CASE;
      END IF;
   END PROCESS;
   
   
END behav;


