LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;

ENTITY i2c_ov7725_rgb565_cfg IS
   PORT (
      clk        : IN STD_LOGIC;
      rst_n      : IN STD_LOGIC;
      i2c_done   : IN STD_LOGIC;
      i2c_exec   : buffer  STD_LOGIC;
      init_done  : OUT STD_LOGIC;
		i2c_data   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
   );
END i2c_ov7725_rgb565_cfg;

ARCHITECTURE behav OF i2c_ov7725_rgb565_cfg IS
   constant reg_num:std_logic_vector(6 downto 0):="1000110";
   SIGNAL start_init_cnt : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL init_reg_cnt   : STD_LOGIC_VECTOR(6 DOWNTO 0);
   
BEGIN
   
   PROCESS (clk, rst_n)
   BEGIN
      IF ((NOT(rst_n)) = '1') THEN
         start_init_cnt <= "0000000000";
      ELSIF (clk'EVENT AND clk = '1') THEN
         IF ((init_reg_cnt = "0000001") AND i2c_done = '1') THEN
            start_init_cnt <= "0000000000";
         ELSIF (start_init_cnt < "1111111111") THEN
            start_init_cnt <= start_init_cnt + "0000000001";
         END IF;
      END IF;
   END PROCESS;
   
   
   PROCESS (clk, rst_n)
   BEGIN
      IF ((NOT(rst_n)) = '1') THEN
         init_reg_cnt <= "0000000";
      ELSIF (clk'EVENT AND clk = '1') THEN
         IF (i2c_exec  = '1') THEN
            init_reg_cnt <= init_reg_cnt + "0000001";
         END IF;
      END IF;
   END PROCESS;
   
   
   PROCESS (clk, rst_n)
   BEGIN
      IF ((NOT(rst_n)) = '1') THEN
         i2c_exec  <= '0';
      ELSIF (clk'EVENT AND clk = '1') THEN
         IF (start_init_cnt = "1111111110") THEN
            i2c_exec  <= '1';
         
         ELSIF (i2c_done = '1' AND (init_reg_cnt /= "0000001") AND (init_reg_cnt < REG_NUM)) THEN
            i2c_exec  <= '1';
         ELSE
            i2c_exec  <= '0';
         END IF;
      END IF;
   END PROCESS;
   
   
   PROCESS (clk, rst_n)
   BEGIN
      IF ((NOT(rst_n)) = '1') THEN
         init_done <= '0';
      ELSIF (clk'EVENT AND clk = '1') THEN
         IF ((init_reg_cnt = REG_NUM) AND i2c_done = '1') THEN
            init_done <= '1';
         END IF;
      END IF;
   END PROCESS;
   
   
   PROCESS (clk, rst_n)
   BEGIN
      IF ((NOT(rst_n)) = '1') THEN
         i2c_data <= "0000000000000000";
      ELSIF (clk'EVENT AND clk = '1') THEN
         CASE init_reg_cnt IS
            
            WHEN "0000000" =>
               i2c_data <= ("00010010" & "10000000");
            WHEN "0000001" =>
               i2c_data <= ("00111101" & "00000011");
            WHEN "0000010" =>
               i2c_data <= ("00010101" & "00000000");
            WHEN "0000011" =>
               i2c_data <= ("00010111" & "00100011");
            WHEN "0000100" =>
               i2c_data <= ("00011000" & "10100000");
            WHEN "0000101" =>
               i2c_data <= ("00011001" & "00000111");
            WHEN "0000110" =>
               i2c_data <= ("00011010" & "11110000");
            WHEN "0000111" =>
               i2c_data <= ("00110010" & "00000000");
            WHEN "0001000" =>
               i2c_data <= ("00101001" & "10100000");
            WHEN "0001001" =>
               i2c_data <= ("00101010" & "00000000");
            WHEN "0001010" =>
               i2c_data <= ("00101011" & "00000000");
            WHEN "0001011" =>
               i2c_data <= ("00101100" & "11110000");
            WHEN "0001100" =>
               i2c_data <= ("00001101" & "01000001");
            WHEN "0001101" =>
               i2c_data <= ("00010001" & "00000000");
            WHEN "0001110" =>
               i2c_data <= ("00010010" & "00000110");
            WHEN "0001111" =>
               i2c_data <= ("00001100" & "00010000");
            
            WHEN "0010000" =>
               i2c_data <= ("01000010" & "01111111");
            WHEN "0010001" =>
               i2c_data <= ("01001101" & "00001001");
            WHEN "0010010" =>
               i2c_data <= ("01100011" & "11110000");
            WHEN "0010011" =>
               i2c_data <= ("01100100" & "11111111");
            WHEN "0010100" =>
               i2c_data <= ("01100101" & "00000000");
            WHEN "0010101" =>
               i2c_data <= ("01100110" & "00000000");
            WHEN "0010110" =>
               i2c_data <= ("01100111" & "00000000");
            
            WHEN "0010111" =>
               i2c_data <= ("00010011" & "11111111");
            WHEN "0011000" =>
               i2c_data <= ("00001111" & "11000101");
            WHEN "0011001" =>
               i2c_data <= ("00010100" & "00010001");
            WHEN "0011010" =>
               i2c_data <= ("00100010" & "10011000");
            WHEN "0011011" =>
               i2c_data <= ("00100011" & "00000011");
            WHEN "0011100" =>
               i2c_data <= ("00100100" & "01000000");
            WHEN "0011101" =>
               i2c_data <= ("00100101" & "00110000");
            WHEN "0011110" =>
               i2c_data <= ("00100110" & "10100001");
            WHEN "0011111" =>
               i2c_data <= ("01101011" & "10101010");
            WHEN "0100000" =>
               i2c_data <= ("00010011" & "11111111");
            WHEN "0100001" =>
               i2c_data <= ("10010000" & "00001010");
            
            WHEN "0100010" =>
               i2c_data <= ("10010001" & "00000001");
            WHEN "0100011" =>
               i2c_data <= ("10010010" & "00000001");
            WHEN "0100100" =>
               i2c_data <= ("10010011" & "00000001");
            WHEN "0100101" =>
               i2c_data <= ("10010100" & "01011111");
            WHEN "0100110" =>
               i2c_data <= ("10010101" & "01010011");
            WHEN "0100111" =>
               i2c_data <= ("10010110" & "00010001");
            WHEN "0101000" =>
               i2c_data <= ("10010111" & "00011010");
            WHEN "0101001" =>
               i2c_data <= ("10011000" & "00111101");
            WHEN "0101010" =>
               i2c_data <= ("10011001" & "01011010");
            WHEN "0101011" =>
               i2c_data <= ("10011010" & "00011110");
            WHEN "0101100" =>
               i2c_data <= ("10011011" & "00111111");
            WHEN "0101101" =>
               i2c_data <= ("10011100" & "00100101");
            WHEN "0101110" =>
               i2c_data <= ("10011110" & "10000001");
            WHEN "0101111" =>
               i2c_data <= ("10100110" & "00000110");
            WHEN "0110000" =>
               i2c_data <= ("10100111" & "01100101");
            WHEN "0110001" =>
               i2c_data <= ("10101000" & "01100101");
            WHEN "0110010" =>
               i2c_data <= ("10101001" & "10000000");
            WHEN "0110011" =>
               i2c_data <= ("10101010" & "10000000");
            
            WHEN "0110100" =>
               i2c_data <= ("01111110" & "00001100");
            WHEN "0110101" =>
               i2c_data <= ("01111111" & "00010110");
            WHEN "0110110" =>
               i2c_data <= ("10000000" & "00101010");
            WHEN "0110111" =>
               i2c_data <= ("10000001" & "01001110");
            WHEN "0111000" =>
               i2c_data <= ("10000010" & "01100001");
            WHEN "0111001" =>
               i2c_data <= ("10000011" & "01101111");
            WHEN "0111010" =>
               i2c_data <= ("10000100" & "01111011");
            WHEN "0111011" =>
               i2c_data <= ("10000101" & "10000110");
            WHEN "0111100" =>
               i2c_data <= ("10000110" & "10001110");
            WHEN "0111101" =>
               i2c_data <= ("10000111" & "10010111");
            WHEN "0111110" =>
               i2c_data <= ("10001000" & "10100100");
            WHEN "0111111" =>
               i2c_data <= ("10001001" & "10101111");
            WHEN "1000000" =>
               i2c_data <= ("10001010" & "11000101");
            WHEN "1000001" =>
               i2c_data <= ("10001011" & "11010111");
            WHEN "1000010" =>
               i2c_data <= ("10001100" & "11101000");
            WHEN "1000011" =>
               i2c_data <= ("10001101" & "00100000");
            WHEN "1000100" =>
               i2c_data <= ("00001110" & "01100101");
            WHEN "1000101" =>
               i2c_data <= ("00001001" & "00000000");
            
            WHEN OTHERS =>
               i2c_data <= ("00011100" & "01111111");
         END CASE;
      END IF;
   END PROCESS;
   
   
END behav;


