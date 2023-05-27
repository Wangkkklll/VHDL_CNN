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
-- Generated on "01/31/2023 14:50:45"
                                                            
-- Vhdl Test Bench template for design  :  gray_in
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;                             

ENTITY gray_in_vhd_tst IS
END gray_in_vhd_tst;
ARCHITECTURE gray_in_arch OF gray_in_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL data_in : STD_LOGIC_VECTOR(10 DOWNTO 0):="00000000000";
SIGNAL data_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL data_req : STD_LOGIC;
SIGNAL end_pre : STD_LOGIC;
SIGNAL gray_addr : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL gray_en : STD_LOGIC;
SIGNAL gray_ready : STD_LOGIC;
SIGNAL rst_n : STD_LOGIC;
constant clk_period:time:=20ns;


COMPONENT gray_in
	PORT (
	clk : IN STD_LOGIC;
	data_in : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
	data_out : BUFFER STD_LOGIC_VECTOR(7 DOWNTO 0);
	data_req : IN STD_LOGIC;
	end_pre : IN STD_LOGIC;
	gray_addr : BUFFER STD_LOGIC_VECTOR(9 DOWNTO 0);
	gray_en : BUFFER STD_LOGIC;
	gray_ready : BUFFER STD_LOGIC;
	rst_n : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : gray_in
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	data_in => data_in,
	data_out => data_out,
	data_req => data_req,
	end_pre => end_pre,
	gray_addr => gray_addr,
	gray_en => gray_en,
	gray_ready => gray_ready,
	rst_n => rst_n
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
data_req<='0';wait for 100ns;
data_req<='1';wait for 20ns;
end process;

process
begin
wait for 100ns;
data_in<=data_in+'1';
wait for 10ns;
end process;

process
begin
end_pre<='0';wait for 10000ns;
end_pre<='1';wait for 20ns;
end_pre<='0';wait;
end process;


                    
END gray_in_arch;
