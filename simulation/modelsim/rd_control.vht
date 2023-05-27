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
-- Generated on "01/31/2023 12:39:58"
                                                            
-- Vhdl Test Bench template for design  :  rd_control
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY rd_control_vhd_tst IS
END rd_control_vhd_tst;
ARCHITECTURE rd_control_arch OF rd_control_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL conv_over : STD_LOGIC;
SIGNAL conv_stop : STD_LOGIC;
SIGNAL gobal_ready : STD_LOGIC;
SIGNAL group1_en : STD_LOGIC;
SIGNAL group2_en : STD_LOGIC;
SIGNAL group3_en : STD_LOGIC;
SIGNAL layer : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL maxpool_over : STD_LOGIC;
SIGNAL pix_start_addr : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL pool_ready : STD_LOGIC;
SIGNAL pool_start : STD_LOGIC;
SIGNAL position_out : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL rd_addr : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL rst_n : STD_LOGIC;
SIGNAL w_pre_ready : STD_LOGIC;
constant clk_period:time:=20ns;

COMPONENT rd_control
	PORT (
	clk : IN STD_LOGIC;
	conv_over : OUT STD_LOGIC;
	conv_stop : OUT STD_LOGIC;
	gobal_ready : IN STD_LOGIC;
	group1_en : OUT STD_LOGIC;
	group2_en : OUT STD_LOGIC;
	group3_en : OUT STD_LOGIC;
	layer : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	maxpool_over : OUT STD_LOGIC;
	pix_start_addr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	pool_ready : IN STD_LOGIC;
	pool_start : OUT STD_LOGIC;
	position_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	rd_addr : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
	rst_n : IN STD_LOGIC;
	w_pre_ready : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : rd_control
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	conv_over => conv_over,
	conv_stop => conv_stop,
	gobal_ready => gobal_ready,
	group1_en => group1_en,
	group2_en => group2_en,
	group3_en => group3_en,
	layer => layer,
	maxpool_over => maxpool_over,
	pix_start_addr => pix_start_addr,
	pool_ready => pool_ready,
	pool_start => pool_start,
	position_out => position_out,
	rd_addr => rd_addr,
	rst_n => rst_n,
	w_pre_ready => w_pre_ready
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
rst_n<='0';wait for 15ns;
rst_n<='1';wait;
end process;


process
begin
gobal_ready<='0';wait for 30ns;
gobal_ready<='1';wait for 20ns;
gobal_ready<='0';wait;
end process;

pix_start_addr<="0000000000";
w_pre_ready<='0';
pool_ready<='0';
layer<="1000";
                                      
END rd_control_arch;
