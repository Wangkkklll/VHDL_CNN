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
-- Generated on "01/31/2023 11:05:40"
                                                            
-- Vhdl Test Bench template for design  :  rom_weight
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY rom_weight_vhd_tst IS
END rom_weight_vhd_tst;
ARCHITECTURE rom_weight_arch OF rom_weight_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL load_ready : STD_LOGIC;
SIGNAL rst_n : STD_LOGIC;
SIGNAL w_pre_ready : STD_LOGIC;
SIGNAL w_start_addr : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL weight_out : STD_LOGIC_VECTOR(71 DOWNTO 0);
constant clk_period:time:=20ns;

COMPONENT rom_weight
	PORT (
	clk : IN STD_LOGIC;
	load_ready : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	w_pre_ready : OUT STD_LOGIC;
	w_start_addr : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	weight_out : OUT STD_LOGIC_VECTOR(71 DOWNTO 0)
	);
END COMPONENT;
BEGIN
	i1 : rom_weight
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	load_ready => load_ready,
	rst_n => rst_n,
	w_pre_ready => w_pre_ready,
	w_start_addr => w_start_addr,
	weight_out => weight_out
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
load_ready<='0';wait for 20ns;
load_ready<='1';wait for 20ns;
load_ready<='0';wait for 2000ns;
load_ready<='1';wait for 20ns;
load_ready<='0';wait for 2000ns;
load_ready<='1';wait for 20ns;
load_ready<='0';wait;
end process;

process
begin
w_start_addr<="000000000000";wait for 2000ns;
w_start_addr<="000000100100";wait for 2000ns;
w_start_addr<="000001001000";wait;
end process;
                                         
END rom_weight_arch;
