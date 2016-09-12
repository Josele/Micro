--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:23:56 12/04/2014
-- Design Name:   
-- Module Name:   C:/Users/Bea/Desktop/Xilinx_ISE_DS_Win_12.4_M.81d.2.0/Micro/tb_alu.vhd
-- Project Name:  Micro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ALU
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
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_signed.all;

USE work.PIC_pkg.all;
 
ENTITY tb_alu IS
END tb_alu;
 
ARCHITECTURE behavior OF tb_alu IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ALU
    PORT(
         reset : IN  std_logic;
         clk : IN  std_logic;
         u_instruction : IN  alu_op;
         FlagZ : OUT  std_logic;
         FlagC : OUT  std_logic;
         FlagN : OUT  std_logic;
         FlagE : OUT  std_logic;
         Index_Reg : OUT  std_logic_vector(7 downto 0);
         Databus : INOUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal reset : std_logic := '0';
   signal clk : std_logic := '0';
   signal u_instruction : alu_op := nop;

	--BiDirs
   signal Databus : std_logic_vector(7 downto 0);

 	--Outputs
   signal FlagZ : std_logic;
   signal FlagC : std_logic;
   signal FlagN : std_logic;
   signal FlagE : std_logic;
   signal Index_Reg : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 50 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ALU PORT MAP (
          reset => reset,
          clk => clk,
          u_instruction => u_instruction,
          FlagZ => FlagZ,
          FlagC => FlagC,
          FlagN => FlagN,
          FlagE => FlagE,
          Index_Reg => Index_Reg,
          Databus => Databus
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
 
--nop,                                  -- no operation
--      op_lda, op_ldb, op_ldacc, op_ldid,    -- external value load
--      op_mvacc2id, op_mvacc2a, op_mvacc2b,  -- internal load
--      op_add, op_sub, op_shiftl, op_shiftr, -- arithmetic operations
--      op_and, op_or, op_xor,                -- logic operations
--      op_cmpe, op_cmpl, op_cmpg,            -- compare operations
--      op_ascii2bin, op_bin2ascii,           -- conversion operations
--      op_oeacc);  

   -- Stimulus process
   stim_proc: process
   begin	
		reset <= '0', '1' after 100 ns;
		databus <= (others => 'Z');
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		databus <= "00000011";
		u_instruction <= nop;
		 wait for clk_period;
	u_instruction <= op_lda;
		 wait for clk_period;
		 databus <= "11010010";
	u_instruction <= op_ldb;
		 wait for clk_period;
	u_instruction <= op_ldacc;
		 wait for clk_period;
	u_instruction <= op_ldid;
		 wait for clk_period;
	u_instruction <= op_add;
		 wait for clk_period;
	u_instruction <= op_sub;
		 wait for clk_period;
	u_instruction <= op_shiftr;
		 wait for clk_period;
	u_instruction <= op_shiftl;
		 wait for clk_period;
	u_instruction <= op_and;
		 wait for clk_period;
	u_instruction <= op_or;
		 wait for clk_period;
	u_instruction <= op_xor;
		 wait for clk_period;
	u_instruction <= op_cmpe;
		 wait for clk_period;
	u_instruction <= op_cmpl;
		 wait for clk_period;
	u_instruction <= op_cmpg;
		 wait for clk_period;
	u_instruction <=op_bin2ascii;
		 wait for clk_period;
	u_instruction <= op_ascii2bin;
		 wait for clk_period;
		databus <= (others => 'Z');
u_instruction <= op_oeacc;
		 wait for clk_period;
		
      -- insert stimulus here 

      wait;
   end process;

END;
