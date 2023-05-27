LIBRARY ieee;
   USE ieee.std_logic_1164.all;

ENTITY sdram_datas IS
   PORT (
      clk             : IN STD_LOGIC;								--系统时钟
      rst_n           : IN STD_LOGIC;								--低电平复位信号
      
      sdram_data_in   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);	--写入SDRAM中的数据
      sdram_data_out  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);	--从SDRAM中读取的数据
      work_state      : IN STD_LOGIC_VECTOR(3 DOWNTO 0);		--SDRAM工作状态寄存器
      cnt_clk         : IN STD_LOGIC_VECTOR(9 DOWNTO 0);		--时钟计数
      
      sdram_data      : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)	--SDRAM数据总线
   );
END sdram_datas;

ARCHITECTURE behav OF sdram_datas IS
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
	
	------------------------------------------------------------
   SIGNAL sdram_out_en : STD_LOGIC;											--SDRAM数据总线输出使能
   SIGNAL sdram_din_r  : STD_LOGIC_VECTOR(15 DOWNTO 0);				--寄存写入SDRAM中的数据
   SIGNAL sdram_dout_r : STD_LOGIC_VECTOR(15 DOWNTO 0);				--寄存从SDRAM中读取的数据
BEGIN
   --SDRAM 双向数据线作为输入时保持高阻态
   sdram_data <= sdram_din_r WHEN (sdram_out_en = '1') ELSE
                 "ZZZZZZZZZZZZZZZZ";
   --输出SDRAM中读取的数据
   sdram_data_out <= sdram_dout_r;
   --SDRAM 数据总线输出使能
   PROCESS (clk, rst_n)
   BEGIN
      IF (rst_n = '0') THEN
         sdram_out_en <= '0';
      ELSIF (clk'EVENT AND clk = '1') THEN
         IF ((work_state = W_WRITE) OR (work_state = W_WD)) THEN
            sdram_out_en <= '1';							--向SDRAM中写数据时,输出使能拉高
         ELSE
            sdram_out_en <= '0';
         END IF;
      END IF;
   END PROCESS;
   
   --将待写入数据送到SDRAM数据总线上
   PROCESS (clk, rst_n)
   BEGIN
      IF (rst_n = '0') THEN
         sdram_din_r <= "0000000000000000";
      ELSIF (clk'EVENT AND clk = '1') THEN
         IF ((work_state = W_WRITE) OR (work_state = W_WD)) THEN
            sdram_din_r <= sdram_data_in;				--寄存写入SDRAM中的数据
         END IF;
      END IF;
   END PROCESS;
   
   --读数据时,寄存SDRAM数据线上的数据
   PROCESS (clk, rst_n)
   BEGIN
      IF ((NOT(rst_n)) = '1') THEN
         sdram_dout_r <= "0000000000000000";
      ELSIF (clk'EVENT AND clk = '1') THEN
         IF (work_state = W_RD) THEN
            sdram_dout_r <= sdram_data;				--寄存从SDRAM中读取的数据
         END IF;
      END IF;
   END PROCESS;
   
   
END behav;


