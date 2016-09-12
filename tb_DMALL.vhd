--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:35:23 12/11/2014
-- Design Name:   
-- Module Name:   C:/Users/Bea/Desktop/Xilinx_ISE_DS_Win_12.4_M.81d.2.0/Micro/tb_DMALL.vhd
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
 use work.RS232_test.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_DMALL IS
END tb_DMALL;
 
ARCHITECTURE behavior OF tb_DMALL IS 
 
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
    component ram
    port (
   Clk      : in    std_logic;
   Reset    : in    std_logic;
   write_en : in    std_logic;
   oe       : in    std_logic;
   address  : in    std_logic_vector(7 downto 0);
   databus  : inout std_logic_vector(7 downto 0);
	Switches : out std_logic_vector(7 downto 0);
	Temp_L	: out std_logic_vector(6 downto 0);
	Temp_H	: out std_logic_vector(6 downto 0));
  end component;
    component RS232top
    port (
      Reset     : in  std_logic;
      Clk       : in  std_logic;
      Data_in   : in  std_logic_vector(7 downto 0);
      Valid_D   : in  std_logic;
      Ack_in    : out std_logic;
      TX_RDY    : out std_logic;
      TD        : out std_logic;
      RD        : in  std_logic;
      Data_out  : out std_logic_vector(7 downto 0);
      Data_read : in  std_logic;
      Full      : out std_logic;
      Empty     : out std_logic);
  end component;

   --Inputs
   signal reset : std_logic := '0';
   signal clk : std_logic := '0';
  	SIGNAL	Switches :   STD_LOGIC_VECTOR (7 downto 0);
   SIGNAL        temp_l :   STD_LOGIC_VECTOR (6 downto 0);
   SIGNAL        temp_h :   STD_LOGIC_VECTOR (6 downto 0);
	SIGNAL RS232_TX    : STD_LOGIC;  -- start signal for transmitter
	SIGNAL RS232_RX    : STD_LOGIC;  -- start signal for transmitter
  SIGNAL RCVD_Data   : STD_LOGIC_vector(7 downto 0);
  SIGNAL RX_Full   : STD_LOGIC;
  SIGNAL RX_Empty   : STD_LOGIC;
  SIGNAL Data_read   : STD_LOGIC;
  SIGNAL Data_receive   : STD_LOGIC_vector(7 downto 0);
  SIGNAL TX_RDY   : STD_LOGIC;
  SIGNAL Ack_out   : STD_LOGIC;
  SIGNAL Valid_D   : STD_LOGIC;
  SIGNAL oe   : STD_LOGIC;
  SIGNAL write_en   : STD_LOGIC;
  SIGNAL dma_rq   : STD_LOGIC;
  SIGNAL dma_ack   : STD_LOGIC;
  SIGNAL send_comm   : STD_LOGIC;
  SIGNAL ready   : STD_LOGIC;
  SIGNAL TX_Data    : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL address    : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL databus    : STD_LOGIC_VECTOR(7 DOWNTO 0);
   -- Clock period definitions
   constant clk_period : time := 50 ns;
 
BEGIN
 
  RS232_PHY: RS232top
    port map (
        Reset     => Reset,
        Clk       => Clk,
        Data_in   => TX_Data,
        Valid_D   => Valid_D,
        Ack_in    => Ack_out,
        TX_RDY    => TX_RDY,
        TD        => RS232_TX,
        RD        => RS232_RX,
        Data_out  => RCVD_Data,
        Data_read => Data_read,
        Full      => RX_Full,
        Empty     => RX_Empty);

 midma: dma
    port map (
			Reset     => Reset,
         Clk  => Clk,
         rcvd_data => RCVD_Data,
         rx_full => rx_full,
           rx_empty => RX_Empty,
           data_read => Data_read,
           ack_out => Ack_out,
           tx_rdy => TX_RDY,
           valid_d => Valid_D,
           tx_data  => TX_Data,
           address =>address,
           databus  =>databus,
           write_en  =>write_en,
           oe  =>oe,
           dma_rq  =>dma_rq,
           dma_ack  =>dma_ack,
           send_comm  =>send_comm,
           ready  =>ready);
 miram: ram
    port map (
        Reset     => Reset,
        Clk       => Clk,
		  address =>address,
        databus  =>databus,
        write_en  =>write_en,
        oe  =>oe,
		  Switches =>Switches,
		  Temp_L =>Temp_L,
		  Temp_H =>Temp_H);
	-- Instantiate the Unit Under Test (UUT)
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
		reset<=  '0', '1' after 100 ns;
		oe<='Z';
		write_en<='Z';
		address<=(others=>'Z');
		databus<=(others=>'Z');
		dma_ack <= '0';
		send_comm <='0';
      wait for 100 ns;	
		RS232_RX<='1';
      wait for clk_period*10;
		Transmit(RS232_RX,"10101010");
		wait for 100 ns;
		dma_ack <= '1';
		wait for 100 ns;
		oe<='1';
		write_en<='1';
		address<=X"04";
		databus<=X"58";
		wait for 100 ns;
		address<=X"05";
		wait for 100 ns;
		oe<='Z';
		write_en<='Z';
		address<=(others=>'Z');
		databus<=(others=>'Z');
      wait for clk_period*10;
		send_comm <='1';
		 wait for clk_period;

		Receive(ready,RS232_TX,Data_receive);
		wait for clk_period;
		send_comm <='0';
		 wait for clk_period*10;
		 Transmit(RS232_RX,"10101010");
		wait for 100 ns;
		Transmit(RS232_RX,"10101010");
		wait for 100 ns;
		 wait for clk_period*4;
				dma_ack<='0';

	wait;
   end process;

END;
