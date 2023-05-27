LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;

ENTITY i2c_dri IS
   PORT (
      clk         : IN STD_LOGIC;
      rst_n       : IN STD_LOGIC;
      i2c_exec    : IN STD_LOGIC;
      bit_ctrl    : IN STD_LOGIC;
      i2c_rh_wl   : IN STD_LOGIC;
      i2c_addr    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      i2c_data_w  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      i2c_data_r  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      i2c_done    : OUT STD_LOGIC;
      i2c_ack     : OUT STD_LOGIC;
      scl         : OUT STD_LOGIC;
      sda         : INOUT STD_LOGIC;
      dri_clk     : buffer STD_LOGIC
   );
END i2c_dri;

ARCHITECTURE behav OF i2c_dri IS

constant slave_addr: 	std_logic_vector(6 downto 0):="0100001";	--ov7725从机地址
constant clk_freq	:	STD_LOGIC_VECTOR(25 DOWNTO 0):= "10111110101111000010000000";--模块输入的时钟频率
constant i2c_freq	:	STD_LOGIC_VECTOR(17 DOWNTO 0):= "111101000010010000";--IIC_SCL的时钟频率
constant st_idle:		std_logic_vector(7 downto 0):="00000001";		--空闲状态
constant st_sladdr:	std_logic_vector(7 downto 0):="00000010";		--发送器件地址(slave address)
constant st_addr16:	std_logic_vector(7 downto 0):="00000100";		--发送16位字地址
constant st_addr8:	std_logic_vector(7 downto 0):="00001000";		--发送8位字地址
constant st_data_wr:	std_logic_vector(7 downto 0):="00010000";		--写数据(8 bit)
constant st_addr_rd:	std_logic_vector(7 downto 0):="00100000";		--发送器件地址读
constant st_data_rd:	std_logic_vector(7 downto 0):="01000000";		--读数据(8 bit)
constant st_stop:		std_logic_vector(7 downto 0):="10000000";		--结束I2C操作
   
   SIGNAL sda_dir       : STD_LOGIC;
   SIGNAL sda_out       : STD_LOGIC;
   SIGNAL st_done       : STD_LOGIC;
   SIGNAL wr_flag       : STD_LOGIC;
   SIGNAL cnt           : STD_LOGIC_VECTOR(6 DOWNTO 0);
   SIGNAL cur_state     : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL next_state    : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL addr_t        : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL data_r        : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL data_wr_t     : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL clk_cnt       : STD_LOGIC_VECTOR(9 DOWNTO 0);
   
   SIGNAL sda_in        : STD_LOGIC;
   SIGNAL clk_divide    : STD_LOGIC_VECTOR(8 DOWNTO 0);
   
BEGIN
   sda <= sda_out WHEN (sda_dir = '1') ELSE
          'Z';
   sda_in <= sda;
   clk_divide <= "000110010";
   
   PROCESS (clk, rst_n)
   BEGIN
      IF ((NOT(rst_n)) = '1') THEN
         dri_clk  <= '0';
         clk_cnt <= "0000000000";
      ELSIF (clk'EVENT AND clk = '1') THEN
         IF (clk_cnt = ("00" & clk_divide(8 DOWNTO 1) - "00000001")) THEN
            clk_cnt <= "0000000000";
            dri_clk  <= NOT(dri_clk );
         ELSE
            clk_cnt <= clk_cnt + "0000000001";
         END IF;
      END IF;
   END PROCESS;
   
   
   PROCESS (dri_clk , rst_n)
   BEGIN
      IF ((NOT(rst_n)) = '1') THEN
         cur_state <= st_idle;
      ELSIF (dri_clk 'EVENT AND dri_clk  = '1') THEN
         cur_state <= next_state;
      END IF;
   END PROCESS;
   
   
   PROCESS (cur_state, i2c_exec, st_done, bit_ctrl, wr_flag)
   BEGIN
      next_state <= st_idle;
      CASE cur_state IS
         WHEN st_idle =>
            IF (i2c_exec = '1') THEN
               next_state <= st_sladdr;
            ELSE
               next_state <= st_idle;
            END IF;
         WHEN st_sladdr=>
            IF (st_done = '1') THEN
               IF (bit_ctrl = '1') THEN
                  next_state <= st_addr16;
               ELSE
                  next_state <= st_addr8;
               END IF;
            ELSE
               next_state <= st_sladdr;
            END IF;
         WHEN st_addr16 =>
            IF (st_done = '1') THEN
               next_state <= st_addr8;
            ELSE
               next_state <= st_addr16;
            END IF;
         WHEN st_addr8 =>
            IF (st_done = '1') THEN
               IF (wr_flag = '0') THEN
                  next_state <= st_data_wr;
               ELSE
                  next_state <= st_addr_rd;
               END IF;
            ELSE
               next_state <= st_addr8;
            END IF;
         WHEN st_data_wr =>
            IF (st_done = '1') THEN
               next_state <= st_stop;
            ELSE
               next_state <= st_data_wr;
            END IF;
         WHEN st_addr_rd =>
            IF (st_done = '1') THEN
               next_state <= st_data_rd;
            ELSE
               next_state <= st_addr_rd;
            END IF;
         WHEN st_data_rd =>
            IF (st_done = '1') THEN
               next_state <= st_stop;
            ELSE
               next_state <= st_data_rd;
            END IF;
         WHEN st_stop =>
            IF (st_done = '1') THEN
               next_state <= st_idle;
            ELSE
               next_state <= st_stop;
            END IF;
         WHEN OTHERS =>
            next_state <= st_idle;
      END CASE;
   END PROCESS;
   
   
   PROCESS (dri_clk , rst_n)
   BEGIN
      
      IF ((NOT(rst_n)) = '1') THEN
         scl <= '1';
         sda_out <= '1';
         sda_dir <= '1';
         i2c_done <= '0';
         i2c_ack <= '0';
         cnt <= "0000000";
         st_done <= '0';
         data_r <= "00000000";
         i2c_data_r <= "00000000";
         wr_flag <= '0';
         addr_t <= "0000000000000000";
         data_wr_t <= "00000000";
      ELSIF (dri_clk 'EVENT AND dri_clk  = '1') THEN
         st_done <= '0';
         cnt <= cnt + "0000001";
         CASE cur_state IS
            WHEN st_idle =>
               scl <= '1';
               sda_out <= '1';
               sda_dir <= '1';
               i2c_done <= '0';
               cnt <= "0000000";
               IF (i2c_exec = '1') THEN
                  wr_flag <= i2c_rh_wl;
                  addr_t <= i2c_addr;
                  data_wr_t <= i2c_data_w;
                  i2c_ack <= '0';
               END IF;
            WHEN st_sladdr =>
               CASE cnt IS
                  WHEN "0000001" =>
                     sda_out <= '0';
                  WHEN "0000011" =>
                     scl <= '0';
                  WHEN "0000100" =>
                     sda_out <= SLAVE_ADDR(6);
                  WHEN "0000101" =>
                     scl <= '1';
                  WHEN "0000111" =>
                     scl <= '0';
                  WHEN "0001000" =>
                     sda_out <= SLAVE_ADDR(5);
                  WHEN "0001001" =>
                     scl <= '1';
                  WHEN "0001011" =>
                     scl <= '0';
                  WHEN "0001100" =>
                     sda_out <= SLAVE_ADDR(4);
                  WHEN "0001101" =>
                     scl <= '1';
                  WHEN "0001111" =>
                     scl <= '0';
                  WHEN "0010000" =>
                     sda_out <= SLAVE_ADDR(3);
                  WHEN "0010001" =>
                     scl <= '1';
                  WHEN "0010011" =>
                     scl <= '0';
                  WHEN "0010100" =>
                     sda_out <= SLAVE_ADDR(2);
                  WHEN "0010101" =>
                     scl <= '1';
                  WHEN "0010111" =>
                     scl <= '0';
                  WHEN "0011000" =>
                     sda_out <= SLAVE_ADDR(1);
                  WHEN "0011001" =>
                     scl <= '1';
                  WHEN "0011011" =>
                     scl <= '0';
                  WHEN "0011100" =>
                     sda_out <= SLAVE_ADDR(0);
                  WHEN "0011101" =>
                     scl <= '1';
                  WHEN "0011111" =>
                     scl <= '0';
                  WHEN "0100000" =>
                     sda_out <= '0';
                  WHEN "0100001" =>
                     scl <= '1';
                  WHEN "0100011" =>
                     scl <= '0';
                  WHEN "0100100" =>
                     sda_dir <= '0';
                     sda_out <= '1';
                  WHEN "0100101" =>
                     scl <= '1';
                  WHEN "0100110" =>
                     st_done <= '1';
                     IF (sda_in = '1') THEN
                        i2c_ack <= '1';
                     END IF;
                  WHEN "0100111" =>
                     scl <= '0';
                     cnt <= "0000000";
                  WHEN OTHERS => null;
               END CASE;
            WHEN st_addr16 =>
               CASE cnt IS
                  WHEN "0000000" =>
                     sda_dir <= '1';
                     sda_out <= addr_t(15);
                  WHEN "0000001" =>
                     scl <= '1';
                  WHEN "0000011" =>
                     scl <= '0';
                  WHEN "0000100" =>
                     sda_out <= addr_t(14);
                  WHEN "0000101" =>
                     scl <= '1';
                  WHEN "0000111" =>
                     scl <= '0';
                  WHEN "0001000" =>
                     sda_out <= addr_t(13);
                  WHEN "0001001" =>
                     scl <= '1';
                  WHEN "0001011" =>
                     scl <= '0';
                  WHEN "0001100" =>
                     sda_out <= addr_t(12);
                  WHEN "0001101" =>
                     scl <= '1';
                  WHEN "0001111" =>
                     scl <= '0';
                  WHEN "0010000" =>
                     sda_out <= addr_t(11);
                  WHEN "0010001" =>
                     scl <= '1';
                  WHEN "0010011" =>
                     scl <= '0';
                  WHEN "0010100" =>
                     sda_out <= addr_t(10);
                  WHEN "0010101" =>
                     scl <= '1';
                  WHEN "0010111" =>
                     scl <= '0';
                  WHEN "0011000" =>
                     sda_out <= addr_t(9);
                  WHEN "0011001" =>
                     scl <= '1';
                  WHEN "0011011" =>
                     scl <= '0';
                  WHEN "0011100" =>
                     sda_out <= addr_t(8);
                  WHEN "0011101" =>
                     scl <= '1';
                  WHEN "0011111" =>
                     scl <= '0';
                  WHEN "0100000" =>
                     sda_dir <= '0';
                     sda_out <= '1';
                  WHEN "0100001" =>
                     scl <= '1';
                  WHEN "0100010" =>
                     st_done <= '1';
                     IF (sda_in = '1') THEN
                        i2c_ack <= '1';
                     END IF;
                  WHEN "0100011" =>
                     scl <= '0';
                     cnt <= "0000000";
                  WHEN OTHERS => null;
               END CASE;
            WHEN st_addr8 =>
               CASE cnt IS
                  WHEN "0000000" =>
                     sda_dir <= '1';
                     sda_out <= addr_t(7);
                  WHEN "0000001" =>
                     scl <= '1';
                  WHEN "0000011" =>
                     scl <= '0';
                  WHEN "0000100" =>
                     sda_out <= addr_t(6);
                  WHEN "0000101" =>
                     scl <= '1';
                  WHEN "0000111" =>
                     scl <= '0';
                  WHEN "0001000" =>
                     sda_out <= addr_t(5);
                  WHEN "0001001" =>
                     scl <= '1';
                  WHEN "0001011" =>
                     scl <= '0';
                  WHEN "0001100" =>
                     sda_out <= addr_t(4);
                  WHEN "0001101" =>
                     scl <= '1';
                  WHEN "0001111" =>
                     scl <= '0';
                  WHEN "0010000" =>
                     sda_out <= addr_t(3);
                  WHEN "0010001" =>
                     scl <= '1';
                  WHEN "0010011" =>
                     scl <= '0';
                  WHEN "0010100" =>
                     sda_out <= addr_t(2);
                  WHEN "0010101" =>
                     scl <= '1';
                  WHEN "0010111" =>
                     scl <= '0';
                  WHEN "0011000" =>
                     sda_out <= addr_t(1);
                  WHEN "0011001" =>
                     scl <= '1';
                  WHEN "0011011" =>
                     scl <= '0';
                  WHEN "0011100" =>
                     sda_out <= addr_t(0);
                  WHEN "0011101" =>
                     scl <= '1';
                  WHEN "0011111" =>
                     scl <= '0';
                  WHEN "0100000" =>
                     sda_dir <= '0';
                     sda_out <= '1';
                  WHEN "0100001" =>
                     scl <= '1';
                  WHEN "0100010" =>
                     st_done <= '1';
                     IF (sda_in = '1') THEN
                        i2c_ack <= '1';
                     END IF;
                  WHEN "0100011" =>
                     scl <= '0';
                     cnt <= "0000000";
                  WHEN OTHERS => null;
               END CASE;
            WHEN st_data_wr =>
               CASE cnt IS
                  WHEN "0000000" =>
                     sda_out <= data_wr_t(7);
                     sda_dir <= '1';
                  WHEN "0000001" =>
                     scl <= '1';
                  WHEN "0000011" =>
                     scl <= '0';
                  WHEN "0000100" =>
                     sda_out <= data_wr_t(6);
                  WHEN "0000101" =>
                     scl <= '1';
                  WHEN "0000111" =>
                     scl <= '0';
                  WHEN "0001000" =>
                     sda_out <= data_wr_t(5);
                  WHEN "0001001" =>
                     scl <= '1';
                  WHEN "0001011" =>
                     scl <= '0';
                  WHEN "0001100" =>
                     sda_out <= data_wr_t(4);
                  WHEN "0001101" =>
                     scl <= '1';
                  WHEN "0001111" =>
                     scl <= '0';
                  WHEN "0010000" =>
                     sda_out <= data_wr_t(3);
                  WHEN "0010001" =>
                     scl <= '1';
                  WHEN "0010011" =>
                     scl <= '0';
                  WHEN "0010100" =>
                     sda_out <= data_wr_t(2);
                  WHEN "0010101" =>
                     scl <= '1';
                  WHEN "0010111" =>
                     scl <= '0';
                  WHEN "0011000" =>
                     sda_out <= data_wr_t(1);
                  WHEN "0011001" =>
                     scl <= '1';
                  WHEN "0011011" =>
                     scl <= '0';
                  WHEN "0011100" =>
                     sda_out <= data_wr_t(0);
                  WHEN "0011101" =>
                     scl <= '1';
                  WHEN "0011111" =>
                     scl <= '0';
                  WHEN "0100000" =>
                     sda_dir <= '0';
                     sda_out <= '1';
                  WHEN "0100001" =>
                     scl <= '1';
                  WHEN "0100010" =>
                     st_done <= '1';
                     IF (sda_in = '1') THEN
                        i2c_ack <= '1';
                     END IF;
                  WHEN "0100011" =>
                     scl <= '0';
                     cnt <= "0000000";
                  WHEN OTHERS => null;
               END CASE;
            WHEN st_addr_rd =>
               CASE cnt IS
                  WHEN "0000000" =>
                     sda_dir <= '1';
                     sda_out <= '1';
                  WHEN "0000001" =>
                     scl <= '1';
                  WHEN "0000010" =>
                     sda_out <= '0';
                  WHEN "0000011" =>
                     scl <= '0';
                  WHEN "0000100" =>
                     sda_out <= SLAVE_ADDR(6);
                  WHEN "0000101" =>
                     scl <= '1';
                  WHEN "0000111" =>
                     scl <= '0';
                  WHEN "0001000" =>
                     sda_out <= SLAVE_ADDR(5);
                  WHEN "0001001" =>
                     scl <= '1';
                  WHEN "0001011" =>
                     scl <= '0';
                  WHEN "0001100" =>
                     sda_out <= SLAVE_ADDR(4);
                  WHEN "0001101" =>
                     scl <= '1';
                  WHEN "0001111" =>
                     scl <= '0';
                  WHEN "0010000" =>
                     sda_out <= SLAVE_ADDR(3);
                  WHEN "0010001" =>
                     scl <= '1';
                  WHEN "0010011" =>
                     scl <= '0';
                  WHEN "0010100" =>
                     sda_out <= SLAVE_ADDR(2);
                  WHEN "0010101" =>
                     scl <= '1';
                  WHEN "0010111" =>
                     scl <= '0';
                  WHEN "0011000" =>
                     sda_out <= SLAVE_ADDR(1);
                  WHEN "0011001" =>
                     scl <= '1';
                  WHEN "0011011" =>
                     scl <= '0';
                  WHEN "0011100" =>
                     sda_out <= SLAVE_ADDR(0);
                  WHEN "0011101" =>
                     scl <= '1';
                  WHEN "0011111" =>
                     scl <= '0';
                  WHEN "0100000" =>
                     sda_out <= '1';
                  WHEN "0100001" =>
                     scl <= '1';
                  WHEN "0100011" =>
                     scl <= '0';
                  WHEN "0100100" =>
                     sda_dir <= '0';
                     sda_out <= '1';
                  WHEN "0100101" =>
                     scl <= '1';
                  WHEN "0100110" =>
                     st_done <= '1';
                     IF (sda_in = '1') THEN
                        i2c_ack <= '1';
                     END IF;
                  WHEN "0100111" =>
                     scl <= '0';
                     cnt <= "0000000";
                  WHEN OTHERS => null;
               END CASE;
            WHEN st_data_rd =>
               CASE cnt IS
                  WHEN "0000000" =>
                     sda_dir <= '0';
                  WHEN "0000001" =>
                     data_r(7) <= sda_in;
                     scl <= '1';
                  WHEN "0000011" =>
                     scl <= '0';
                  WHEN "0000101" =>
                     data_r(6) <= sda_in;
                     scl <= '1';
                  WHEN "0000111" =>
                     scl <= '0';
                  WHEN "0001001" =>
                     data_r(5) <= sda_in;
                     scl <= '1';
                  WHEN "0001011" =>
                     scl <= '0';
                  WHEN "0001101" =>
                     data_r(4) <= sda_in;
                     scl <= '1';
                  WHEN "0001111" =>
                     scl <= '0';
                  WHEN "0010001" =>
                     data_r(3) <= sda_in;
                     scl <= '1';
                  WHEN "0010011" =>
                     scl <= '0';
                  WHEN "0010101" =>
                     data_r(2) <= sda_in;
                     scl <= '1';
                  WHEN "0010111" =>
                     scl <= '0';
                  WHEN "0011001" =>
                     data_r(1) <= sda_in;
                     scl <= '1';
                  WHEN "0011011" =>
                     scl <= '0';
                  WHEN "0011101" =>
                     data_r(0) <= sda_in;
                     scl <= '1';
                  WHEN "0011111" =>
                     scl <= '0';
                  WHEN "0100000" =>
                     sda_dir <= '1';
                     sda_out <= '1';
                  WHEN "0100001" =>
                     scl <= '1';
                  WHEN "0100010" =>
                     st_done <= '1';
                  WHEN "0100011" =>
                     scl <= '0';
                     cnt <= "0000000";
                     i2c_data_r <= data_r;
                  WHEN OTHERS => null;
               END CASE;
            WHEN st_stop =>
               CASE cnt IS
                  WHEN "0000000" =>
                     sda_dir <= '1';
                     sda_out <= '0';
                  WHEN "0000001" =>
                     scl <= '1';
                  WHEN "0000011" =>
                     sda_out <= '1';
                  WHEN "0001111" =>
                     st_done <= '1';
                  WHEN "0010000" =>
                     cnt <= "0000000";
                     i2c_done <= '1';
                  WHEN OTHERS => null;
               END CASE;
				WHEN OTHERS => null;
         END CASE;
      END IF;
   END PROCESS;
   
   
END behav;


