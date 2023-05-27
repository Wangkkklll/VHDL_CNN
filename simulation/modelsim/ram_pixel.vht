-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "01/31/2023 15:07:45"
                                                            
-- Vhdl Test Bench template for design  :  ram_pixel
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;                              

ENTITY ram_pixel_vhd_tst IS
END ram_pixel_vhd_tst;
ARCHITECTURE ram_pixel_arch OF ram_pixel_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC:='0';
SIGNAL group1_en : STD_LOGIC:='0';
SIGNAL group2_en : STD_LOGIC:='0';
SIGNAL group3_en : STD_LOGIC:='0';
SIGNAL layer : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL q_out_a : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL q_out_b : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL q_out_c : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL q_out_d : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL rd_addr : STD_LOGIC_VECTOR(9 DOWNTO 0):="0000000000";
SIGNAL wr_addr : STD_LOGIC_VECTOR(9 DOWNTO 0):="0000000000";
SIGNAL wr_data_a : STD_LOGIC_VECTOR(7 DOWNTO 0):="00000000";
SIGNAL wr_data_b : STD_LOGIC_VECTOR(7 DOWNTO 0):="00000000";
SIGNAL wr_data_c : STD_LOGIC_VECTOR(7 DOWNTO 0):="00000000";
SIGNAL wr_data_d : STD_LOGIC_VECTOR(7 DOWNTO 0):="00000000";
SIGNAL wr_en_ain : STD_LOGIC:='0';
SIGNAL wr_en_aout1 : STD_LOGIC:='0';
SIGNAL wr_en_aout2 : STD_LOGIC:='0';
SIGNAL wr_en_bin : STD_LOGIC:='0';
SIGNAL wr_en_bout1 : STD_LOGIC:='0';
SIGNAL wr_en_bout2 : STD_LOGIC:='0';
SIGNAL wr_en_cin : STD_LOGIC:='0';
SIGNAL wr_en_cout1 : STD_LOGIC:='0';
SIGNAL wr_en_cout2 : STD_LOGIC:='0';
SIGNAL wr_en_din : STD_LOGIC:='0';
SIGNAL wr_en_dout1 : STD_LOGIC:='0';
SIGNAL wr_en_dout2 : STD_LOGIC:='0';
constant clk_period:time:=20ns;

COMPONENT ram_pixel
	PORT (
	clk : IN STD_LOGIC;
	group1_en : IN STD_LOGIC;
	group2_en : IN STD_LOGIC;
	group3_en : IN STD_LOGIC;
	layer : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	q_out_a : BUFFER STD_LOGIC_VECTOR(7 DOWNTO 0);
	q_out_b : BUFFER STD_LOGIC_VECTOR(7 DOWNTO 0);
	q_out_c : BUFFER STD_LOGIC_VECTOR(7 DOWNTO 0);
	q_out_d : BUFFER STD_LOGIC_VECTOR(7 DOWNTO 0);
	rd_addr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	wr_addr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	wr_data_a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	wr_data_b : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	wr_data_c : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	wr_data_d : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	wr_en_ain : IN STD_LOGIC;
	wr_en_aout1 : IN STD_LOGIC;
	wr_en_aout2 : IN STD_LOGIC;
	wr_en_bin : IN STD_LOGIC;
	wr_en_bout1 : IN STD_LOGIC;
	wr_en_bout2 : IN STD_LOGIC;
	wr_en_cin : IN STD_LOGIC;
	wr_en_cout1 : IN STD_LOGIC;
	wr_en_cout2 : IN STD_LOGIC;
	wr_en_din : IN STD_LOGIC;
	wr_en_dout1 : IN STD_LOGIC;
	wr_en_dout2 : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : ram_pixel
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	group1_en => group1_en,
	group2_en => group2_en,
	group3_en => group3_en,
	layer => layer,
	q_out_a => q_out_a,
	q_out_b => q_out_b,
	q_out_c => q_out_c,
	q_out_d => q_out_d,
	rd_addr => rd_addr,
	wr_addr => wr_addr,
	wr_data_a => wr_data_a,
	wr_data_b => wr_data_b,
	wr_data_c => wr_data_c,
	wr_data_d => wr_data_d,
	wr_en_ain => wr_en_ain,
	wr_en_aout1 => wr_en_aout1,
	wr_en_aout2 => wr_en_aout2,
	wr_en_bin => wr_en_bin,
	wr_en_bout1 => wr_en_bout1,
	wr_en_bout2 => wr_en_bout2,
	wr_en_cin => wr_en_cin,
	wr_en_cout1 => wr_en_cout1,
	wr_en_cout2 => wr_en_cout2,
	wr_en_din => wr_en_din,
	wr_en_dout1 => wr_en_dout1,
	wr_en_dout2 => wr_en_dout2
	);
init : PROCESS                                               
-- variable declarations                                     
BEGIN                                                        
        -- code that executes only once                      
WAIT;                                                       
END PROCESS init;                                           
always : PROCESS                                              
                                    
BEGIN                                                         
clk<='0';
wait for clk_period/2;
clk<='1';
wait for clk_period/2;                                                        
END PROCESS always;


process
begin
wait for 20ns;
wr_data_a<=wr_data_a+'1';
wr_data_b<=wr_data_b+'1';
wr_data_c<=wr_data_c+'1';
wr_data_d<=wr_data_d+'1';
end process;

process
begin
wait for 20ns;
if(wr_addr/="1100001111")then
	wr_addr<=wr_addr+'1';
	wr_en_aout1<='1';
	wr_en_bout1<='1';
	wr_en_cout1<='1';
	wr_en_dout1<='1';
elsif(wr_addr="1100001111")then
	rd_addr<=rd_addr+'1';
	group2_en<='1';
	wr_en_aout1<='0';
	wr_en_bout1<='0';
	wr_en_cout1<='0';
	wr_en_dout1<='0';
end if;

end process;



layer<="0010";

                                      
END ram_pixel_arch;
