--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:56:49 11/23/2014
-- Design Name:   
-- Module Name:   C:/Users/josele/Desktop/La UPM ETSIT/4/dsed/practica/Micro/tb_ram.vhd
-- Project Name:  Micro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ram
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
USE work.PIC_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_ram IS
END tb_ram;
 
ARCHITECTURE behavior OF tb_ram IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ram
    PORT(
         Clk : IN  std_logic;
         Reset : IN  std_logic;
         write_en : IN  std_logic;
         oe : IN  std_logic;
         address : IN  std_logic_vector(7 downto 0);
         databus : INOUT  std_logic_vector(7 downto 0);
         Switches : OUT  std_logic_vector(7 downto 0);
         Temp_L : OUT  std_logic_vector(6 downto 0);
         Temp_H : OUT  std_logic_vector(6 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';
   signal write_en : std_logic := '0';
   signal oe : std_logic := '0';
   signal address : std_logic_vector(7 downto 0) := (others => '0');

	--BiDirs
   signal databus : std_logic_vector(7 downto 0);

 	--Outputs
   signal Switches : std_logic_vector(7 downto 0);
   signal Temp_L : std_logic_vector(6 downto 0);
   signal Temp_H : std_logic_vector(6 downto 0);

   -- Clock period definitions
   constant Clk_period : time := 50 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ram PORT MAP (
          Clk => Clk,
          Reset => Reset,
          write_en => write_en,
          oe => oe,
          address => address,
          databus => databus,
          Switches => Switches,
          Temp_L => Temp_L,
          Temp_H => Temp_H
        );

   -- Clock process definitions
   Clk_process :process
   begin
		Clk <= '0';
		wait for Clk_period/2;
		Clk <= '1';
		wait for Clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
   reset <=  '0';
	oe<='1';
	write_en<='1';
	databus<=(others => 'Z');
   wait for 50 ns;	
	reset <=  '1';
	address<=SWITCH_BASE;
	
	write_en<='0';	
	oe<='0';	 
	wait for 50 ns;

	write_en<='0';	
	oe<='1';	
	wait for 50 ns;
	write_en<='0';	
	oe<='0';	
	address<=T_STAT;
		wait for 50 ns;
		write_en<='1';	
	oe<='1';
	databus<="00000001";
      -- insert stimulus here 

      wait;
   end process;

END;
