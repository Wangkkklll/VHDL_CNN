----------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;
--USE IEEE.std_logic_unsigned.All; error:Error (10621): VHDL Use Clause error at conv.vhd(55): 
--more than one Use Clause imports a declaration of simple name ""="" -- none of the declarations are directly visible

entity ram_pixel is
	port(
	clk:in std_logic;
	layer:in std_logic_vector(3 DOWNTO 0);
	rd_addr:in std_logic_vector(9 DOWNTO 0);
	group1_en, group2_en, group3_en:in std_logic;
	q_out_a, q_out_b, q_out_c, q_out_d:out std_logic_vector(7 DOWNTO 0);
	wr_en_ain,wr_en_bin,wr_en_cin,wr_en_din:in std_logic;
	wr_en_aout1,wr_en_bout1,wr_en_cout1,wr_en_dout1:in std_logic;
	wr_en_aout2,wr_en_bout2,wr_en_cout2,wr_en_dout2:in std_logic;
	wr_addr:in std_logic_vector(9 DOWNTO 0);
	wr_data_a, wr_data_b, wr_data_c, wr_data_d:in  std_logic_vector (7 downto 0)
	);
end entity;

architecture structure of ram_pixel is

-----------------------ram--------------------------
-----------------------input------------------------
COMPONENT ram_input
PORT
(
	clock		: IN STD_LOGIC;
	data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
	rdaddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
	rden		: IN STD_LOGIC;
	wraddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
	wren		: IN STD_LOGIC;
	q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
);
END COMPONENT;

COMPONENT ram_input_b
PORT
(
	clock		: IN STD_LOGIC;
	data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
	rdaddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
	rden		: IN STD_LOGIC;
	wraddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
	wren		: IN STD_LOGIC;
	q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
);
END COMPONENT;

COMPONENT ram_input_c
PORT
(
	clock		: IN STD_LOGIC;
	data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
	rdaddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
	rden		: IN STD_LOGIC;
	wraddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
	wren		: IN STD_LOGIC;
	q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
);
END COMPONENT;

COMPONENT ram_input_d
PORT
(
	clock		: IN STD_LOGIC;
	data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
	rdaddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
	rden		: IN STD_LOGIC;
	wraddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
	wren		: IN STD_LOGIC;
	q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
);
END COMPONENT;

---------------------------output1----------------------
COMPONENT ram_output1
	PORT
	(
		clock		: IN STD_LOGIC;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdaddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		rden		: IN STD_LOGIC ;
		wraddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		wren		: IN STD_LOGIC;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ram_output1_b
	PORT
	(
		clock		: IN STD_LOGIC;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdaddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		rden		: IN STD_LOGIC ;
		wraddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		wren		: IN STD_LOGIC;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ram_output1_c
	PORT
	(
		clock		: IN STD_LOGIC;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdaddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		rden		: IN STD_LOGIC ;
		wraddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		wren		: IN STD_LOGIC;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ram_output1_d
	PORT
	(
		clock		: IN STD_LOGIC;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdaddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		rden		: IN STD_LOGIC ;
		wraddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		wren		: IN STD_LOGIC;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;
--------------------------output2---------------------------------
COMPONENT ram_output2
	PORT
	(
		clock		: IN STD_LOGIC;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdaddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		rden		: IN STD_LOGIC ;
		wraddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		wren		: IN STD_LOGIC;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ram_output2_b
	PORT
	(
		clock		: IN STD_LOGIC;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdaddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		rden		: IN STD_LOGIC ;
		wraddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		wren		: IN STD_LOGIC;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ram_output2_c
	PORT
	(
		clock		: IN STD_LOGIC;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdaddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		rden		: IN STD_LOGIC ;
		wraddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		wren		: IN STD_LOGIC;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ram_output2_d
	PORT
	(
		clock		: IN STD_LOGIC;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdaddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		rden		: IN STD_LOGIC ;
		wraddress		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		wren		: IN STD_LOGIC;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT data_enable
	port(
	layer:in std_logic_vector(3 DOWNTO 0);
	group1_a:in std_logic_vector(7 DOWNTO 0);
	group1_b:in std_logic_vector(7 DOWNTO 0);
	group1_c:in std_logic_vector(7 DOWNTO 0);
	group1_d:in std_logic_vector(7 DOWNTO 0);
	group2_a:in std_logic_vector(7 DOWNTO 0);
	group2_b:in std_logic_vector(7 DOWNTO 0);
	group2_c:in std_logic_vector(7 DOWNTO 0);
	group2_d:in std_logic_vector(7 DOWNTO 0);
	group3_a:in std_logic_vector(7 DOWNTO 0);
	group3_b:in std_logic_vector(7 DOWNTO 0);
	group3_c:in std_logic_vector(7 DOWNTO 0);
	group3_d:in std_logic_vector(7 DOWNTO 0);
	q_out_a:out std_logic_vector(7 DOWNTO 0);
	q_out_b:out std_logic_vector(7 DOWNTO 0);
	q_out_c:out std_logic_vector(7 DOWNTO 0);
	q_out_d:out std_logic_vector(7 DOWNTO 0)
	);
end COMPONENT;


signal group1_a, group1_b, group1_c, group1_d:std_logic_vector(7 DOWNTO 0);
signal group2_a, group2_b, group2_c, group2_d:std_logic_vector(7 DOWNTO 0);
signal group3_a, group3_b, group3_c, group3_d:std_logic_vector(7 DOWNTO 0);

begin

U:data_enable
	PORT map(layer, group1_a, group1_b, group1_c, group1_d, group2_a, group2_b, group2_c, group2_d,
	 group3_a, group3_b, group3_c, group3_d, q_out_a, q_out_b, q_out_c, q_out_d);
---------------------ram---------------------------
---------------------input-------------------------
ram_input_inst : ram_input 
	PORT MAP (
		clock	 => clk,
		data	 => wr_data_a,
		rdaddress	 => rd_addr,
		rden	 => group1_en,
		wraddress	 => wr_addr,
		wren	 => wr_en_ain,
		q	 => group1_a
	);

ram_input_b_inst : ram_input_b 
	PORT MAP (
		clock	 => clk,
		data	 => wr_data_b,
		rdaddress	 => rd_addr,
		rden	 => group1_en,
		wraddress	 => wr_addr,
		wren	 => wr_en_bin,
		q	 => group1_b
	);

ram_input_c_inst : ram_input_c 
	PORT MAP (
		clock	 => clk,
		data	 => wr_data_c,
		rdaddress	 => rd_addr,
		rden	 => group1_en,
		wraddress	 => wr_addr,
		wren	 => wr_en_cin,
		q	 => group1_c
	);

ram_input_d_inst : ram_input_d 
	PORT MAP (
		clock	 => clk,
		data	 => wr_data_d,
		rdaddress	 => rd_addr,
		rden	 => group1_en,
		wraddress	 => wr_addr,
		wren	 => wr_en_din,
		q	 => group1_d
	);
	
---------------------output1-------------------------
ram_output1_inst : ram_output1 
	PORT MAP (
		clock	 => clk,
		data	 => wr_data_a,
		rdaddress	 => rd_addr,
		rden	 => group2_en,
		wraddress	 => wr_addr,
		wren	 => wr_en_aout1,
		q	 => group2_a
	);
	
ram_output1_b_inst : ram_output1_b 
	PORT MAP (
		clock	 => clk,
		data	 => wr_data_b,
		rdaddress	 => rd_addr,
		rden	 => group2_en,
		wraddress	 => wr_addr,
		wren	 => wr_en_bout1,
		q	 => group2_b
	);
	
ram_output1_c_inst : ram_output1_c 
	PORT MAP (
		clock	 => clk,
		data	 => wr_data_c,
		rdaddress	 => rd_addr,
		rden	 => group2_en,
		wraddress	 => wr_addr,
		wren	 => wr_en_cout1,
		q	 => group2_c
	);
	
ram_output1_d_inst : ram_output1_d
	PORT MAP (
		clock	 => clk,
		data	 => wr_data_d,
		rdaddress	 => rd_addr,
		rden	 => group2_en,
		wraddress	 => wr_addr,
		wren	 => wr_en_dout1,
		q	 => group2_d
	);

---------------------output2-------------------------
ram_output2_inst : ram_output2 
	PORT MAP (
		clock	 => clk,
		data	 => wr_data_a,
		rdaddress	 => rd_addr,
		rden	 => group3_en,
		wraddress	 => wr_addr,
		wren	 => wr_en_aout2,
		q	 => group3_a
	);
	
ram_output2_b_inst : ram_output2_b 
	PORT MAP (
		clock	 => clk,
		data	 => wr_data_b,
		rdaddress	 => rd_addr,
		rden	 => group3_en,
		wraddress	 => wr_addr,
		wren	 => wr_en_bout2,
		q	 => group3_b
	);
	
ram_output2_c_inst : ram_output2_c 
	PORT MAP (
		clock	 => clk,
		data	 => wr_data_c,
		rdaddress	 => rd_addr,
		rden	 => group3_en,
		wraddress	 => wr_addr,
		wren	 => wr_en_cout2,
		q	 => group3_c
	);
	
ram_output2_d_inst : ram_output2_d 
	PORT MAP (
		clock	 => clk,
		data	 => wr_data_d,
		rdaddress	 => rd_addr,
		rden	 => group3_en,
		wraddress	 => wr_addr,
		wren	 => wr_en_dout2,
		q	 => group3_d
	);

end structure;



--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;
--USE IEEE.std_logic_unsigned.All; error:Error (10621): VHDL Use Clause error at conv.vhd(55): 
--more than one Use Clause imports a declaration of simple name ""="" -- none of the declarations are directly visible

entity data_enable is
	port(
	layer:in std_logic_vector(3 DOWNTO 0);
	group1_a:in std_logic_vector(7 DOWNTO 0);
	group1_b:in std_logic_vector(7 DOWNTO 0);
	group1_c:in std_logic_vector(7 DOWNTO 0);
	group1_d:in std_logic_vector(7 DOWNTO 0);
	group2_a:in std_logic_vector(7 DOWNTO 0);
	group2_b:in std_logic_vector(7 DOWNTO 0);
	group2_c:in std_logic_vector(7 DOWNTO 0);
	group2_d:in std_logic_vector(7 DOWNTO 0);
	group3_a:in std_logic_vector(7 DOWNTO 0);
	group3_b:in std_logic_vector(7 DOWNTO 0);
	group3_c:in std_logic_vector(7 DOWNTO 0);
	group3_d:in std_logic_vector(7 DOWNTO 0);
	q_out_a:out std_logic_vector(7 DOWNTO 0);
	q_out_b:out std_logic_vector(7 DOWNTO 0);
	q_out_c:out std_logic_vector(7 DOWNTO 0);
	q_out_d:out std_logic_vector(7 DOWNTO 0)
	);
end entity;
architecture behav of data_enable is
begin
process(layer, group1_a, group1_b, group1_c, group1_d)
begin
case(layer)is
	when "0001"|"0100"|"0111"=> q_out_a<=group1_a;q_out_b<=group1_b;q_out_c<=group1_c;q_out_d<=group1_d;
	when "0010"|"0101"|"1000"=> q_out_a<=group2_a;q_out_b<=group2_b;q_out_c<=group2_c;q_out_d<=group2_d;
	when "0011"|"0110"=> q_out_a<=group3_a;q_out_b<=group3_b;q_out_c<=group3_c;q_out_d<=group3_d;
	when others=> NULL;
end case;
end process;
end behav;
