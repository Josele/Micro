
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

USE work.PIC_pkg.all;

entity PICtop is
  port (
    Reset    : in  std_logic;           -- Asynchronous, active low
    Clk      : in  std_logic;           -- System clock, 20 MHz, rising_edge
    RS232_RX : in  std_logic;           -- RS232 RX line
    RS232_TX : out std_logic;           -- RS232 TX line
    switches : out std_logic_vector(7 downto 0);  -- Switch status bargraph
    Temp_L   : out std_logic_vector(6 downto 0);  -- Less significant figure of T_STAT
    Temp_H   : out std_logic_vector(6 downto 0));  -- Most significant figure of T_STAT
end PICtop;

architecture behavior of PICtop is

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
  component DMA
    port (
      reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           rcvd_data : in  STD_LOGIC_VECTOR (7 downto 0);
           rx_full : in  STD_LOGIC;
           rx_empty : in  STD_LOGIC;
           data_read : out  STD_LOGIC;
           ack_out : in  STD_LOGIC;
           tx_rdy : in  STD_LOGIC;
           valid_d : out  STD_LOGIC;
           tx_data : out  STD_LOGIC_VECTOR (7 downto 0);
           address : out  STD_LOGIC_VECTOR (7 downto 0);
           databus : inout  STD_LOGIC_VECTOR (7 downto 0);
           write_en : out  STD_LOGIC;
           oe : out  STD_LOGIC;
           dma_rq : out  STD_LOGIC;
           int_RQ : out  STD_LOGIC;
           dma_ack : in  STD_LOGIC;
           send_comm : in  STD_LOGIC;
           ready : out  STD_LOGIC);
  end component;

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
   
	
   component ALU
	 Port ( 
			  reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           u_instruction : in  ALU_OP;
           FlagZ : out  STD_LOGIC;
           FlagC : out  STD_LOGIC;
           FlagN : out  STD_LOGIC;
           FlagE : out  STD_LOGIC;
           Index_Reg : out  STD_LOGIC_VECTOR (7 downto 0);
           Databus : inout  STD_LOGIC_VECTOR (7 downto 0));
	end component;
	
	component CPU
	 port ( Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           ROM_Data : in  STD_LOGIC_VECTOR (11 downto 0);
           ROM_Addr : out  STD_LOGIC_VECTOR (11 downto 0);
           RAM_Addr : out  STD_LOGIC_VECTOR (7 downto 0);
           RAM_Write : out  STD_LOGIC;
           RAM_OE : out  STD_LOGIC;
           Databus : inout  STD_LOGIC_VECTOR (7 downto 0);
           DMA_RQ : in  STD_LOGIC;
           DMA_ACK : out  STD_LOGIC;
           SEND_comm : out  STD_LOGIC;
           DMA_READY : in  STD_LOGIC;
           Alu_op : out  alu_op;
           Index_Reg : in  STD_LOGIC_VECTOR (7 downto 0);
           int_rq : in  STD_LOGIC;
           FlagZ : in  STD_LOGIC;
           FlagC : in  STD_LOGIC;
           FlagN : in  STD_LOGIC;
           FlagE : in  STD_LOGIC);
			  
end component;
component rom
  PORT  (
    Instruction     : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);  -- Instruction bus
    Program_counter : IN  STD_LOGIC_VECTOR(11 DOWNTO 0));
END component;	
  	SIGNAL	ROM_Data :   STD_LOGIC_VECTOR (11 downto 0);
   SIGNAL        ROM_Addr :   STD_LOGIC_VECTOR (11 downto 0);
	SIGNAL Data_FF    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL Index_Reg    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL StartTX    : STD_LOGIC;  -- start signal for transmitter
	SIGNAL Alu_op : alu_op;
	SIGNAL FlagZ    : STD_LOGIC;  -- start signal for transmitter
	SIGNAL FlagC    : STD_LOGIC;  -- start signal for transmitter
	SIGNAL FlagN    : STD_LOGIC;  -- start signal for transmitter
	SIGNAL FlagE    : STD_LOGIC;  -- start signal for transmitter
  SIGNAL RCVD_Data   : STD_LOGIC_vector(7 downto 0);
  SIGNAL RX_Full   : STD_LOGIC;
  SIGNAL RX_Empty   : STD_LOGIC;
  SIGNAL Data_read   : STD_LOGIC;
  SIGNAL TX_RDY   : STD_LOGIC;
  SIGNAL Ack_out   : STD_LOGIC;
  SIGNAL Valid_D   : STD_LOGIC;
  SIGNAL oe   : STD_LOGIC;
  SIGNAL write_en   : STD_LOGIC;
  SIGNAL dma_rq   : STD_LOGIC;
  SIGNAL dma_ack   : STD_LOGIC;
  SIGNAL send_comm   : STD_LOGIC;
  SIGNAL int_rq   : STD_LOGIC;
  SIGNAL ready   : STD_LOGIC;
  SIGNAL TX_Data    : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL address    : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL databus    : STD_LOGIC_VECTOR(7 DOWNTO 0);
begin  -- behavior

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
           int_rq  =>int_rq,
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

mialu: alu
    port map (
        Reset     => Reset,
        Clk       => Clk,
		  FlagZ =>FlagZ,
        databus  =>databus,
        u_instruction  =>Alu_op,
        index_reg  =>index_reg,
		  FlagN =>FlagN,
		  FlagC =>FlagC,
		  FlagE =>FlagE);
micpu: cpu
    port map (
			  Reset => Reset,
           Clk =>Clk ,
           ROM_Data=>ROM_Data ,
           ROM_Addr=>ROM_Addr ,
           RAM_Addr=>address ,
           RAM_Write=>write_en ,
           RAM_OE =>OE ,
           Databus=>Databus ,
           DMA_RQ=>DMA_RQ ,
           DMA_ACK=>DMA_ACK ,
           SEND_comm=>SEND_comm ,
            
           DMA_READY=>READY ,
           Alu_op=>Alu_op ,
           int_rq=>int_rq ,
           Index_Reg=>Index_Reg ,
           FlagZ=>FlagZ ,
           FlagC=>FlagC ,
           FlagN=>FlagN ,
           FlagE=>FlagE );

mirom: rom
  PORT map (
    Instruction     =>Rom_data ,
    Program_counter =>rom_Addr);
end behavior;