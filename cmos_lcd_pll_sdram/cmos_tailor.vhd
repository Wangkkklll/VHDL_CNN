--图像数据裁剪
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

ENTITY cmos_tailor IS
   PORT (
		rst_n             : IN STD_LOGIC;							 --复位信号
      lcd_id            : IN STD_LOGIC_VECTOR(15 DOWNTO 0);  --LCD屏的ID号
      h_disp            : IN STD_LOGIC_VECTOR(10 DOWNTO 0);  --LCD屏水平分辨率
      v_disp            : IN STD_LOGIC_VECTOR(10 DOWNTO 0);  --LCD屏垂直分辨率
      h_pixel           : OUT STD_LOGIC_VECTOR(10 DOWNTO 0); --存入SDRAM的水平分辨率
      v_pixel           : OUT STD_LOGIC_VECTOR(10 DOWNTO 0); --存入SDRAM的屏垂直分辨率
      sdram_addr_max    : OUT STD_LOGIC_VECTOR(27 DOWNTO 0); --存入SDRAM的最大读写地址
      lcd_id_a          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); --时钟同步后的LCD屏的ID号
      --摄像头接口
      cam_pclk          : IN STD_LOGIC;							 --cmos 数据像素时钟
      cam_vsync         : IN STD_LOGIC;							 --cmos 场同步信号
      cam_href          : IN STD_LOGIC;							 --cmos 行同步信号
      cam_data          : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      cam_data_valid    : IN STD_LOGIC;
      --用户接口
      cmos_frame_valid  : OUT STD_LOGIC;							 --数据有效使能信号
      cmos_frame_data   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)  --有效数据
   );
END cmos_tailor;

ARCHITECTURE behav OF cmos_tailor IS
   
   SIGNAL cam_vsync_d0     : STD_LOGIC;
   SIGNAL cam_vsync_d1     : STD_LOGIC;
   SIGNAL cam_href_d0      : STD_LOGIC;
   SIGNAL cam_href_d1      : STD_LOGIC;
   SIGNAL h_cnt            : STD_LOGIC_VECTOR(10 DOWNTO 0);  --对行计数
   SIGNAL v_cnt            : STD_LOGIC_VECTOR(10 DOWNTO 0);  --对场计数
   SIGNAL h_disp_a         : STD_LOGIC_VECTOR(10 DOWNTO 0);  --LCD屏水平分辨率
   SIGNAL v_disp_a         : STD_LOGIC_VECTOR(10 DOWNTO 0);  --LCD屏垂直分辨率
   
   SIGNAL pos_vsync        : STD_LOGIC;							 --采输入场同步信号的上升沿
   SIGNAL neg_hsync        : STD_LOGIC;							 --采输入行同步信号的下降沿
   SIGNAL cmos_h_pixel     : STD_LOGIC_VECTOR(10 DOWNTO 0);  --CMOS水平方向像素个数
   SIGNAL cmos_v_pixel     : STD_LOGIC_VECTOR(10 DOWNTO 0);  --CMOS垂直方向像素个数
   SIGNAL cam_border_pos_l : STD_LOGIC_VECTOR(10 DOWNTO 0);  --左侧边界的横坐标
   SIGNAL cam_border_pos_r : STD_LOGIC_VECTOR(10 DOWNTO 0);  --右侧边界的横坐标
   SIGNAL cam_border_pos_t : STD_LOGIC_VECTOR(10 DOWNTO 0);  --上端边界的纵坐标
   SIGNAL cam_border_pos_b : STD_LOGIC_VECTOR(10 DOWNTO 0);  --下端边界的纵坐标
   
   SIGNAL h_pixel_signal	: STD_LOGIC_VECTOR(10 DOWNTO 0);  --存入SDRAM的水平分辨率
   SIGNAL v_pixel_signal	: STD_LOGIC_VECTOR(10 DOWNTO 0);  --存入SDRAM的屏垂直分辨率
   SIGNAL lcd_id_a_signal  : STD_LOGIC_VECTOR(15 DOWNTO 0);  --时钟同步后的LCD屏的ID号
	signal h_extra				:std_LOGIC_VECTOR(10 downto 0);	 --多出来的水平分辨率
	signal v_extra				:std_LOGIC_VECTOR(10 downto 0);	 --多出来的垂直分辨率
	
BEGIN
   h_pixel <= h_pixel_signal;
   v_pixel <= v_pixel_signal;
   lcd_id_a <= lcd_id_a_signal;
   
   sdram_addr_max <= ("000000" & h_pixel_signal * v_pixel_signal);  --存入SDRAM的最大读写地址
   cmos_h_pixel <= "01010000000";  --CMOS水平方向像素个数640
   cmos_v_pixel <= "00111100000";  --CMOS垂直方向像素个数480
	
	--计算裁剪后的图像坐标
	h_extra <= cmos_h_pixel - h_disp_a;
	v_extra <= cmos_v_pixel - v_disp_a;
	--左侧边界的横坐标计算
	--cam_border_pos_l <= (cmos_h_pixel - h_disp_a) / "00000000010" - "00000000001";
	cam_border_pos_l <= ('0' &h_extra(9 downto 1)) - "00000000001";
	--右侧边界的横坐标计算
	--cam_border_pos_r <= h_disp + (cmos_h_pixel - h_disp_a) / "00000000010" - "00000000001";
	cam_border_pos_l <= h_disp + ('0' &h_extra(9 downto 1)) - "00000000001";
	--上端边界的纵坐标计算
	--cam_border_pos_t <= (cmos_v_pixel - v_disp_a) / "00000000010";
	cam_border_pos_t <= ('0' &v_extra(9 downto 1)) - "00000000001";
	--下端边界的纵坐标计算
	--cam_border_pos_b <= v_disp_a + (cmos_v_pixel - v_disp_a) / "00000000010";
	cam_border_pos_b <= v_disp + ('0' &v_extra(9 downto 1)) - "00000000001";
	
	PROCESS (cam_pclk, rst_n)
   BEGIN
      IF ((rst_n) = '0') THEN
         cam_vsync_d0 <= '0';
         cam_vsync_d1 <= '0';
         cam_href_d0 <= '0';
         cam_href_d1 <= '0';
         lcd_id_a_signal <= "0000000000000000";
         v_disp_a <= "00000000000";
         h_disp_a <= "00000000000";
      ELSIF (cam_pclk'EVENT AND cam_pclk = '1') THEN
         cam_vsync_d0 <= cam_vsync;
         cam_vsync_d1 <= cam_vsync_d0;
         cam_href_d0 <= cam_href;
         cam_href_d1 <= cam_href_d0;
         lcd_id_a_signal <= lcd_id;
         v_disp_a <= v_disp;
         h_disp_a <= h_disp;
      END IF;
   END PROCESS;
	--采输入场同步信号的上升沿
	pos_vsync <= (NOT(cam_vsync_d1)) AND cam_vsync_d0;
	--采输入行同步信号的下降沿
	neg_hsync <= (NOT(cam_href_d0)) AND cam_href_d1;
	
	--计算存入SDRAM的分辨率
   PROCESS (cam_pclk, rst_n)
   BEGIN
      IF ((rst_n) = '0') THEN
         h_pixel_signal <= "00000000000";
         v_pixel_signal <= "00000000000";
      ELSIF (cam_pclk'EVENT AND cam_pclk = '1') THEN
         IF (lcd_id_a_signal = "0100001101000010") THEN  --LCD屏ID为4342，分辨率小于摄像头
            h_pixel_signal <= h_disp_a;  --存入SDRAM的分辨率为LCD屏的
            v_pixel_signal <= v_disp_a;
         ELSE
            h_pixel_signal <= cmos_h_pixel;  --存入SDRAM的分辨率为摄像头的
            v_pixel_signal <= cmos_v_pixel;
         END IF;
      END IF;
   END PROCESS;
	
	--对行数据计数
	PROCESS (cam_pclk, rst_n)
   BEGIN
      IF ((rst_n) = '0') THEN
         h_cnt <= "00000000000";
      ELSIF (cam_pclk'EVENT AND cam_pclk = '1') THEN
         IF ((pos_vsync = '1') OR (neg_hsync = '1')) THEN
            h_cnt <= "00000000000";
         ELSIF (cam_data_valid = '1') THEN
            h_cnt <= h_cnt + "00000000001";
         ELSIF (cam_href_d0 = '1') THEN
            h_cnt <= h_cnt;
         ELSE
            h_cnt <= h_cnt;
         END IF;
      END IF;
   END PROCESS;
	
	--对行计数
	PROCESS (cam_pclk, rst_n)
   BEGIN
      IF ((NOT(rst_n)) = '1') THEN
         v_cnt <= "00000000000";
      ELSIF (cam_pclk'EVENT AND cam_pclk = '1') THEN
         IF (pos_vsync = '1') THEN
            v_cnt <= "00000000000";
         ELSIF (neg_hsync = '1') THEN
            v_cnt <= v_cnt + "00000000001";
         ELSE
            v_cnt <= v_cnt;
         END IF;
      END IF;
   END PROCESS;
	
	--产生输出数据有效信号(cmos_frame_valid)
	PROCESS (cam_pclk, rst_n)
   BEGIN
      IF ((rst_n) = '0') THEN
         cmos_frame_valid <= '0';
      ELSIF (cam_pclk'EVENT AND cam_pclk = '1') THEN
         IF (h_cnt(10 DOWNTO 0) >= cam_border_pos_l AND h_cnt(10 DOWNTO 0) < cam_border_pos_r AND v_cnt(10 DOWNTO 0) >= cam_border_pos_t AND v_cnt(10 DOWNTO 0) < cam_border_pos_b) THEN
            cmos_frame_valid <= cam_data_valid;
         ELSE
            cmos_frame_valid <= '0';
         END IF;
      END IF;
   END PROCESS;
   --产生有效输出数据(cmos_frame_data)
	PROCESS (cam_pclk, rst_n)
   BEGIN
      IF ((rst_n) = '0') THEN
         cmos_frame_data <= "0000000000000000";
      ELSIF (cam_pclk'EVENT AND cam_pclk = '1') THEN
         IF (h_cnt(10 DOWNTO 0) >= cam_border_pos_l AND h_cnt(10 DOWNTO 0) < cam_border_pos_r AND v_cnt(10 DOWNTO 0) >= cam_border_pos_t AND v_cnt(10 DOWNTO 0) < cam_border_pos_b) THEN
            cmos_frame_data <= cam_data;
         ELSE
            cmos_frame_data <= "0000000000000000";
         END IF;
      END IF;
   END PROCESS;
   
END behav;