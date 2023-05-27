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
-- Generated on "01/31/2023 11:30:53"
                                                            
-- Vhdl Test Bench template for design  :  top_control
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY top_control_vhd_tst IS
END top_control_vhd_tst;
ARCHITECTURE top_control_arch OF top_control_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL cnn_ready : STD_LOGIC;
SIGNAL current_layer : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL gobal_ready : STD_LOGIC;
SIGNAL is_onetofour : STD_LOGIC;
SIGNAL layer_done : STD_LOGIC;
SIGNAL once_finish : STD_LOGIC;
SIGNAL pix_start_addr : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL pool_ready : STD_LOGIC;
SIGNAL rst_n : STD_LOGIC;
SIGNAL w_start_addr : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL weight_ready : STD_LOGIC;
constant clk_period:time:=20ns;

COMPONENT top_control
	PORT (
	clk : IN STD_LOGIC;
	cnn_ready : IN STD_LOGIC;
	current_layer : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	gobal_ready : OUT STD_LOGIC;
	is_onetofour : OUT STD_LOGIC;
	layer_done : IN STD_LOGIC;
	once_finish : IN STD_LOGIC;
	pix_start_addr : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
	pool_ready : OUT STD_LOGIC;
	rst_n : IN STD_LOGIC;
	w_start_addr : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
	weight_ready : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : top_control
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	cnn_ready => cnn_ready,
	current_layer => current_layer,
	gobal_ready => gobal_ready,
	is_onetofour => is_onetofour,
	layer_done => layer_done,
	once_finish => once_finish,
	pix_start_addr => pix_start_addr,
	pool_ready => pool_ready,
	rst_n => rst_n,
	w_start_addr => w_start_addr,
	weight_ready => weight_ready
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
cnn_ready<='0';wait for 40ns;
cnn_ready<='1';wait for 20ns;
cnn_ready<='0';
wait;
end process;

process
begin
once_finish<='0'; 
wait for 100ns;
once_finish<='1';
wait for 20ns;
end process;

process
begin
layer_done<='0';wait for 94080ns;
layer_done<='1';wait for 20ns;
--layer_done<='0';wait for 10000ns;
--layer_done<='1';wait for 20ns;
--layer_done<='0';wait for 10000ns;
--layer_done<='1';wait for 20ns;
layer_done<='0';wait ;
end process;  
                                    
END top_control_arch;
