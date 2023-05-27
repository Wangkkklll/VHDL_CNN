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
-- Generated on "01/31/2023 13:17:20"
                                                            
-- Vhdl Test Bench template for design  :  wr_control
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;                               

ENTITY wr_control_vhd_tst IS
END wr_control_vhd_tst;
ARCHITECTURE wr_control_arch OF wr_control_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL data_out : STD_LOGIC_VECTOR(7 DOWNTO 0):="00000000";
SIGNAL data_out1 : STD_LOGIC_VECTOR(7 DOWNTO 0):="00000000";
SIGNAL data_out2 : STD_LOGIC_VECTOR(7 DOWNTO 0):="00000000";
SIGNAL data_out3 : STD_LOGIC_VECTOR(7 DOWNTO 0):="00000000";
SIGNAL data_out4 : STD_LOGIC_VECTOR(7 DOWNTO 0):="00000000";
SIGNAL finish : STD_LOGIC;
SIGNAL layer : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL layer_done : STD_LOGIC;
SIGNAL rst_n : STD_LOGIC;
SIGNAL wr_addr : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL wr_data_a : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL wr_data_b : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL wr_data_c : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL wr_data_d : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL wr_en_ain : STD_LOGIC;
SIGNAL wr_en_aout1 : STD_LOGIC;
SIGNAL wr_en_aout2 : STD_LOGIC;
SIGNAL wr_en_bin : STD_LOGIC;
SIGNAL wr_en_bout1 : STD_LOGIC;
SIGNAL wr_en_bout2 : STD_LOGIC;
SIGNAL wr_en_cin : STD_LOGIC;
SIGNAL wr_en_cout1 : STD_LOGIC;
SIGNAL wr_en_cout2 : STD_LOGIC;
SIGNAL wr_en_din : STD_LOGIC;
SIGNAL wr_en_dout1 : STD_LOGIC;
SIGNAL wr_en_dout2 : STD_LOGIC;
constant clk_period:time:=20ns;

COMPONENT wr_control
	PORT (
	clk : IN STD_LOGIC;
	data_out : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	data_out1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	data_out2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	data_out3 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	data_out4 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	finish : IN STD_LOGIC;
	layer : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	layer_done : OUT STD_LOGIC;
	rst_n : IN STD_LOGIC;
	wr_addr : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
	wr_data_a : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	wr_data_b : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	wr_data_c : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	wr_data_d : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	wr_en_ain : OUT STD_LOGIC;
	wr_en_aout1 : OUT STD_LOGIC;
	wr_en_aout2 : OUT STD_LOGIC;
	wr_en_bin : OUT STD_LOGIC;
	wr_en_bout1 : OUT STD_LOGIC;
	wr_en_bout2 : OUT STD_LOGIC;
	wr_en_cin : OUT STD_LOGIC;
	wr_en_cout1 : OUT STD_LOGIC;
	wr_en_cout2 : OUT STD_LOGIC;
	wr_en_din : OUT STD_LOGIC;
	wr_en_dout1 : OUT STD_LOGIC;
	wr_en_dout2 : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : wr_control
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	data_out => data_out,
	data_out1 => data_out1,
	data_out2 => data_out2,
	data_out3 => data_out3,
	data_out4 => data_out4,
	finish => finish,
	layer => layer,
	layer_done => layer_done,
	rst_n => rst_n,
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
rst_n<='0';wait for 15ns;
rst_n<='1';wait;
end process;


process
begin
finish<='0';wait for 180ns;
finish<='1';wait for 20ns;
end process;

process
begin
wait for 180ns;
data_out<=data_out+'1';
--data_out1<=data_out1+'1';
--data_out2<=data_out2+'1';
--data_out3<=data_out3+'1';
--data_out4<=data_out4+'1';
wait for 10ns;
end process;



layer<="0100";
                                       
END wr_control_arch;
