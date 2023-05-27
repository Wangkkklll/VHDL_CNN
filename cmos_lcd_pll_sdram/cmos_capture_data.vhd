--图像数据采集
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cmos_capture_data is
   port(
	   rst_n:in std_logic;  --复位信号
		--摄像头接口
		cam_pclk:in std_logic;  --cmos数据像素时钟
		cam_vsync:in std_logic;  --cmos场同步信号
		cam_href:in std_logic;  --cmos行同步信号
		cam_data:in std_logic_vector(7 downto 0);
		--用户接口
		cmos_frame_vsync:out std_logic;  --帧有效信号
		cmos_frame_href:out std_logic;  --行有效信号
		cmos_frame_valid:out std_logic;  --数据有效使能信号
		cmos_frame_data:out std_logic_vector(15 downto 0)  --有效数据
	);
end cmos_capture_data;

architecture behav of cmos_capture_data is
   constant WAIT_FRAME:integer:=10;  --寄存器数据稳定等待的帧数
	--定义内部信号
	signal cam_vsync_d0:std_logic;
	signal cam_vsync_d1:std_logic;
	signal cam_href_d0:std_logic;
	signal cam_href_d1:std_logic;
   signal cmos_ps_cnt:std_logic_vector(3 downto 0);  --等待帧数稳定的计数器
   signal cam_data_d0:std_logic_vector(7 downto 0);
   signal cmos_data_t:std_logic_vector(15 downto 0);  --用于8位转16位的临时信号
   signal byte_flag:std_logic;  --16位RGB数据转换完成的标志信号
   signal byte_flag_d0:std_logic;
   signal frame_val_flag:std_logic;  --帧有效的标志
	signal pos_vsync:std_logic;  --输入场同步信号的上升沿
	
begin
	--利用信号的延迟性抓取边沿
	PROCESS (cam_pclk, rst_n)
   BEGIN
      IF ((rst_n) = '0') THEN
         cam_vsync_d0 <= '0';
         cam_vsync_d1 <= '0';
         cam_href_d0 <= '0';
         cam_href_d1 <= '0';
      ELSIF (cam_pclk'EVENT AND cam_pclk = '1') THEN
         cam_vsync_d0 <= cam_vsync;
         cam_vsync_d1 <= cam_vsync_d0;
         cam_href_d0 <= cam_href;
         cam_href_d1 <= cam_href_d0;
      END IF;
   END PROCESS;
   --采输入场同步信号的上升沿
   pos_vsync <= (not(cam_vsync_d1)) and cam_vsync_d0;
	
	--寄存器全部配置完成后，先等待10帧数据，待寄存器配置生效后再开始采集图像
	--对帧数进行计数
	PROCESS (cam_pclk, rst_n)
   BEGIN
      IF ((rst_n) = '0') THEN
         cmos_ps_cnt <= "0000";
      ELSIF (cam_pclk'EVENT AND cam_pclk = '1') THEN
         IF (pos_vsync = '1' AND (cmos_ps_cnt < WAIT_FRAME)) THEN
            cmos_ps_cnt <= cmos_ps_cnt + "0001";
         END IF;
      END IF;
   END PROCESS;
	
	--帧有效标志
	PROCESS (cam_pclk, rst_n)
   BEGIN
      IF ((rst_n) = '0') THEN
         frame_val_flag <= '0';
      ELSIF (cam_pclk'EVENT AND cam_pclk = '1') THEN
         IF ((cmos_ps_cnt = WAIT_FRAME) AND pos_vsync = '1') THEN
            frame_val_flag <= '1';  --已等待10帧
         END IF;
      END IF;
   END PROCESS;
	
	--8位数据转16位RGB565数据
	PROCESS (cam_pclk, rst_n)
   BEGIN
      IF ((rst_n) = '0') THEN
         cmos_data_t <= "0000000000000000";
         cam_data_d0 <= "00000000";
         byte_flag <= '0';
      ELSIF (cam_pclk'EVENT AND cam_pclk = '1') THEN
         IF (cam_href = '1') THEN  --行同步信号拉高
            byte_flag <= NOT(byte_flag);
            cam_data_d0 <= cam_data;
            IF (byte_flag = '1') THEN
               cmos_data_t <= (cam_data_d0 & cam_data);  --两个8bit数据拼接成一个16bit数据
            END IF;
         ELSE
            byte_flag <= '0';
            cam_data_d0 <= "00000000";
         END IF;
      END IF;
   END PROCESS;
	
	--将byte_flag延迟一个时钟输出，与拼接好的数据cmos_data_t匹配
	PROCESS (cam_pclk, rst_n)
   BEGIN
      IF ((rst_n) = '0') THEN
         byte_flag_d0 <= '0';
      ELSIF (cam_pclk'EVENT AND cam_pclk = '1') THEN
         byte_flag_d0 <= byte_flag;
      END IF;
   END PROCESS;
   --输出数据使能有效信号
   cmos_frame_valid <= byte_flag_d0 when (frame_val_flag = '1') else '0';
   --输出数据（延迟了两个时钟）
   cmos_frame_data <= cmos_data_t when (frame_val_flag = '1') else "0000000000000000";	
	--输出帧有效信号（同样延迟两个时钟，与输出数据匹配）
	cmos_frame_vsync <= cam_vsync_d1 when (frame_val_flag = '1') else '0';
   --输出行有效信号（同样延迟两个时钟，与输出数据匹配）
	cmos_frame_href <= cam_href_d1 when (frame_val_flag = '1') else '0';
end behav;