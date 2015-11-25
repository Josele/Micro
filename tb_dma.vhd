--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:18:28 12/04/2014
-- Design Name:   
-- Module Name:   C:/Users/josele/Desktop/La UPM ETSIT/4/dsed/practica/Micro/tb_dma.vhd
-- Project Name:  Micro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DMA
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_dma IS
END tb_dma;
 
ARCHITECTURE behavior OF tb_dma IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DMA
    PORT(
         reset : IN  std_logic;
         clk : IN  std_logic;
         rcvd_data : IN  std_logic_vector(7 downto 0);
         rx_full : IN  std_logic;
         rx_empty : IN  std_logic;
         data_read : OUT  std_logic;
         ack_out : IN  std_logic;
         tx_rdy : IN  std_logic;
         valid_d : OUT  std_logic;
         tx_data : OUT  std_logic_vector(7 downto 0);
         address : OUT  std_logic_vector(7 downto 0);
         databus : INOUT  std_logic_vector(7 downto 0);
         write_en : OUT  std_logic;
         oe : OUT  std_logic;
         dma_rq : OUT  std_logic;
         dma_ack : IN  std_logic;
         send_comm : IN  std_logic;
         ready : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal reset : std_logic := '0';
   signal clk : std_logic := '0';
   signal rcvd_data : std_logic_vector(7 downto 0) := (others => '0');
   signal rx_full : std_logic := '0';
   signal rx_empty : std_logic := '0';
   signal ack_out : std_logic := '0';
   signal tx_rdy : std_logic := '0';
   signal dma_ack : std_logic := '0';
   signal send_comm : std_logic := '0';

	--BiDirs
   signal databus : std_logic_vector(7 downto 0);

 	--Outputs
   signal data_read : std_logic;
   signal valid_d : std_logic;
   signal tx_data : std_logic_vector(7 downto 0);
   signal address : std_logic_vector(7 downto 0);
   signal write_en : std_logic;
   signal oe : std_logic;
   signal dma_rq : std_logic;
   signal ready : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DMA PORT MAP (
          reset => reset,
          clk => clk,
          rcvd_data => rcvd_data,
          rx_full => rx_full,
          rx_empty => rx_empty,
          data_read => data_read,
          ack_out => ack_out,
          tx_rdy => tx_rdy,
          valid_d => valid_d,
          tx_data => tx_data,
          address => address,
          databus => databus,
          write_en => write_en,
          oe => oe,
          dma_rq => dma_rq,
          dma_ack => dma_ack,
          send_comm => send_comm,
          ready => ready
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rcvd_data<="10101010";
		databus <= (others => 'Z');
		rx_empty<='1';
		rx_full<='1';
		ack_out<='0';
		tx_rdy<= '0';
		dma_ack<= '0';
		send_comm <= '0';
		reset <= '0', '1' after clk_period;
		
		
		
		
      wait for clk_period;
		rx_empty<='0';
		wait for clk_period*2;
		if (dma_rq='1') then
		dma_ack<='1';
		end if;
		wait for clk_period*3;
		rcvd_data<="00001010";
		rx_empty<='1';
		wait for clk_period*2;
		rx_empty<='0';
		wait for clk_period*3;
		rcvd_data<="00111111";		


      -- insert stimulus here 

      wait;
   end process;

END;
