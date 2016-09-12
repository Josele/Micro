
LIBRARY IEEE;
   USE IEEE.STD_LOGIC_1164.ALL;
   USE IEEE.NUMERIC_STD.ALL;
   USE IEEE.STD_LOGIC_ARITH.ALL;
   USE IEEE.STD_LOGIC_UNSIGNED.ALL;
   
ENTITY RS232top IS

  PORT (
    Reset     : IN  STD_LOGIC;   -- Low_level-active asynchronous reset
    Clk       : IN  STD_LOGIC;   -- System clock (20MHz), rising edge used
    Data_in   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Data to be sent
    Valid_D   : IN  STD_LOGIC;   -- Handshake signal
                                 -- from guest system, low when data is valid
    Ack_in    : out std_logic;   -- ACK for data received, low once data
                                 -- has been stored
    TX_RDY    : OUT STD_LOGIC;   -- System ready to transmit
    TD        : OUT STD_LOGIC;   -- RS232 Transmission line
    RD        : IN  STD_LOGIC;   -- RS232 Reception line
    Data_out  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Received data
    Data_read : IN  STD_LOGIC;   -- Data read for guest system
    Full      : OUT STD_LOGIC;   -- Full internal memory
    Empty     : OUT STD_LOGIC);  -- Empty internal memory

END RS232top;

ARCHITECTURE RTL OF RS232top IS
 
  ------------------------------------------------------------------------
  -- Components for Transmitter Block
  ------------------------------------------------------------------------

  COMPONENT RS232_TX
    PORT (
      Clk   : IN  STD_LOGIC;
      Reset : IN  STD_LOGIC;
      Start : IN  STD_LOGIC;
      Data  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      EOT   : OUT STD_LOGIC;
      TX    : OUT STD_LOGIC);
  END COMPONENT;

  ------------------------------------------------------------------------
  -- Components for Receiver Block
  ------------------------------------------------------------------------

  COMPONENT ShiftRegister
    PORT (
      Reset  : IN  STD_LOGIC;
      Clk    : IN  STD_LOGIC;
      Enable : IN  STD_LOGIC;
      D      : IN  STD_LOGIC;
      Q      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
  END COMPONENT;

  COMPONENT RS232_RX
    PORT (
      Clk       : IN  STD_LOGIC;
      Reset     : IN  STD_LOGIC;
      LineRD_in : IN  STD_LOGIC;
      Valid_out : OUT STD_LOGIC;
      Code_out  : OUT STD_LOGIC;
      Store_out : OUT STD_LOGIC);
  END COMPONENT;

  COMPONENT fifo
    PORT (
      clk   : IN  STD_LOGIC;
      rst   : IN  STD_LOGIC;
      din   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      wr_en : IN  STD_LOGIC;
      rd_en : IN  STD_LOGIC;
      dout  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      full  : OUT STD_LOGIC;
      empty : OUT STD_LOGIC);
  END COMPONENT;

  ------------------------------------------------------------------------
  -- Internal Signals
  ------------------------------------------------------------------------

	SIGNAL Data_FF    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL StartTX    : STD_LOGIC;  -- start signal for transmitter
	SIGNAL LineRD_in  : STD_LOGIC;  -- internal RX line
	SIGNAL Valid_out  : STD_LOGIC;  -- valid bit @ receiver
	SIGNAL Code_out   : STD_LOGIC;  -- bit @ receiver output
	SIGNAL sinit      : STD_LOGIC;  -- fifo reset
	SIGNAL Fifo_in    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL Fifo_write : STD_LOGIC;
	SIGNAL TX_RDY_i   : STD_LOGIC;

	BEGIN  -- RTL

	  Transmitter: RS232_TX
		 PORT MAP (
			Clk   => Clk,
			Reset => Reset,
			Start => StartTX,
			Data  => Data_FF,
			EOT   => TX_RDY_i,
			TX    => TD);

	  Receiver: RS232_RX
		 PORT MAP (
			Clk       => Clk,
			Reset     => Reset,
			LineRD_in => LineRD_in,
			Valid_out => Valid_out,
			Code_out  => Code_out,
			Store_out => Fifo_write);

	  Shift: ShiftRegister
		 PORT MAP (
			Reset  => Reset,
			Clk    => Clk,
			Enable => Valid_Out,
			D      => Code_Out,
			Q      => Fifo_in);

	  sinit <= NOT reset;
	  
	  Internal_memory: fifo
		 PORT MAP (
			clk   => clk,
			rst   => sinit,
			din   => Fifo_in,
			wr_en => Fifo_write,
			rd_en => Data_read,
			dout  => Data_out,
			full  => Full,
			empty => Empty);

	  -- purpose: Clocking process for input protocol
	  Clocking : PROCESS (Clk, Reset)
	  BEGIN
		 IF Reset = '0' THEN  -- asynchronous reset (active low)
			Data_FF   <= (OTHERS => '0');
			LineRD_in <= '1';
			Ack_in    <= '1';
		 ELSIF Clk'event AND Clk = '1' THEN  -- rising edge clock
			LineRD_in <= RD;
			IF Valid_D = '0' AND TX_RDY_i = '1' THEN
			  Data_FF <= Data_in;
			  Ack_in  <= '0';
			  StartTX <= '1';
			ELSE
			  Ack_in  <= '1';
			  StartTX <= '0';
			END IF;
		 END IF;
	  END PROCESS Clocking;

	  TX_RDY <= TX_RDY_i;

END RTL;

