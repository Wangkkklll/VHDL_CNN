--图像数据处理顶层例化
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

ENTITY cmos_data_top IS
   PORT (
	  rst_n             : IN STD_LOGIC;						--复位信号
      lcd_id            : IN STD_LOGIC_VECTOR(15 DOWNTO 0); --LCD屏的ID号
      h_disp            : IN STD_LOGIC_VECTOR(10 DOWNTO 0); --LCD屏水平分辨率
      v_disp            : IN STD_LOGIC_VECTOR(10 DOWNTO 0); --LCD屏垂直分辨率
      --摄像头接口
      cam_pclk          : IN STD_LOGIC;						--cmos 数据像素时钟
      cam_vsync         : IN STD_LOGIC;						--cmos 场同步信号
      cam_href          : IN STD_LOGIC;						--cmos 行同步信号
      cam_data          : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      --用户接口
      h_pixel           : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);--存入SDRAM的水平分辨率
      v_pixel           : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);--存入SDRAM的垂直分辨率
      sdram_addr_max    : OUT STD_LOGIC_VECTOR(27 DOWNTO 0);--存入SDRAM的最大读写地址
      cmos_frame_vsync  : OUT STD_LOGIC;					--帧有效信号
      cmos_frame_href   : OUT STD_LOGIC;					--行有效信号
      cmos_frame_valid  : OUT STD_LOGIC;					--数据有效使能信号
      cmos_frame_data   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) --有效数据
   );
END cmos_data_top;

ARCHITECTURE structure OF cmos_data_top IS
   COMPONENT cmos_tailor IS
      PORT (
         rst_n             : IN STD_LOGIC;
         lcd_id            : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         h_disp            : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
         v_disp            : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
         h_pixel           : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
         v_pixel           : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
         sdram_addr_max    : OUT STD_LOGIC_VECTOR(27 DOWNTO 0);
         lcd_id_a          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
         cam_pclk          : IN STD_LOGIC;
         cam_vsync         : IN STD_LOGIC;
         cam_href          : IN STD_LOGIC;
         cam_data          : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         cam_data_valid    : IN STD_LOGIC;
         cmos_frame_valid  : OUT STD_LOGIC;
         cmos_frame_data   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
      );
   END COMPONENT;
	
	   COMPONENT cmos_capture_data IS
      PORT (
         rst_n             : IN STD_LOGIC;
         cam_pclk          : IN STD_LOGIC;
         cam_vsync         : IN STD_LOGIC;
         cam_href          : IN STD_LOGIC;
         cam_data          : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         cmos_frame_vsync  : OUT STD_LOGIC;
         cmos_frame_href   : OUT STD_LOGIC;
         cmos_frame_valid  : OUT STD_LOGIC;
         cmos_frame_data   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
      );
   END COMPONENT;
   
   
   SIGNAL lcd_id_a               : STD_LOGIC_VECTOR(15 DOWNTO 0);--时钟同步后的LCD屏的ID号 
   SIGNAL wr_data_tailor         : STD_LOGIC_VECTOR(15 DOWNTO 0);--经过裁剪的摄像头数据
   SIGNAL wr_data                : STD_LOGIC_VECTOR(15 DOWNTO 0);--没有经过裁剪的摄像头数据 
   SIGNAL data_valid_tailor		: STD_LOGIC;					 --经过裁剪的数据有效使能信号
   SIGNAL data_valid	   		 	: STD_LOGIC;					 --没有经过裁剪的数据有效使能信号
   
   SIGNAL cmos_frame_vsync_signal : STD_LOGIC;
   SIGNAL cmos_frame_href_signal  : STD_LOGIC;
	
BEGIN
   cmos_frame_vsync <= cmos_frame_vsync_signal;
   cmos_frame_href <= cmos_frame_href_signal;
   
   cmos_frame_valid <= data_valid_tailor WHEN (lcd_id_a = "0100001101000010") ELSE
                       data_valid;
   cmos_frame_data <= wr_data_tailor WHEN (lcd_id_a = "0100001101000010") ELSE
                      wr_data;
   
   
   
   u_cmos_tailor : cmos_tailor
      PORT MAP (
         rst_n             => rst_n,
         lcd_id            => lcd_id,
         lcd_id_a          => lcd_id_a,
         cam_pclk          => cam_pclk,
         cam_vsync         => cmos_frame_vsync_signal,
         cam_href          => cmos_frame_href_signal,
         cam_data          => wr_data,
         cam_data_valid    => data_valid,
         h_disp            => h_disp,
         v_disp            => v_disp,
         h_pixel           => h_pixel,
         v_pixel           => v_pixel,
         sdram_addr_max    => sdram_addr_max,
         cmos_frame_valid  => data_valid_tailor,
         cmos_frame_data   => wr_data_tailor
      );
   
   
   
   u_cmos_capture_data : cmos_capture_data
      PORT MAP (
         
         rst_n             => rst_n,
         cam_pclk          => cam_pclk,
         cam_vsync         => cam_vsync,
         cam_href          => cam_href,
         cam_data          => cam_data,
         cmos_frame_vsync  => cmos_frame_vsync_signal,
         cmos_frame_href   => cmos_frame_href_signal,
         cmos_frame_valid  => data_valid,
         cmos_frame_data   => wr_data
      );
   
END structure;


