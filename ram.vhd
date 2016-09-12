
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

USE work.PIC_pkg.all;

ENTITY ram IS
PORT (
   Clk      : in    std_logic;
   Reset    : in    std_logic;
   write_en : in    std_logic;
   oe       : in    std_logic;
   address  : in    std_logic_vector(7 downto 0);
   databus  : inout std_logic_vector(7 downto 0);
	Switches : out std_logic_vector(7 downto 0);
	Temp_L	: out std_logic_vector(6 downto 0);
	Temp_H	: out std_logic_vector(6 downto 0));
END ram;

ARCHITECTURE behavior OF ram IS
COMPONENT ram_general
    PORT (
   Clk      : in    std_logic;
   write_en : in    std_logic;
   oe       : in    std_logic;
   address  : in    std_logic_vector(7 downto 0);
   databus  : inout std_logic_vector(7 downto 0));
  END COMPONENT;
  
  
  
	SIGNAL contents_ram : array8_ram(63	DOWNTO 0);
	SIGNAL address_temp : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL address_temp2 : STD_LOGIC_VECTOR(7 DOWNTO 0);

	SIGNAL advisor: STD_LOGIC;
	SIGNAL oe_temp: STD_LOGIC;
	SIGNAL write_en_temp: STD_LOGIC;
	SIGNAL oe_temp2: STD_LOGIC;
	SIGNAL write_en_temp2: STD_LOGIC;
	
BEGIN
rami: ram_general
    PORT MAP (
        Clk       => Clk,
        write_en  => write_en_temp,--
        oe   => oe_temp,--
        address    => address_temp,
        databus    => databus);


-------------------------------------------------------------------------
-- Memoria 
-------------------------------------------------------------------------

deco_dir : PROCESS (address,write_en,oe)  -- no reset
BEGIN
--	advisor<='0';
	address_temp<=(others =>'0');
	address_temp2<=(others =>'0');
	IF address >= GP_RAM_BASE THEN
		address_temp<=address -(GP_RAM_BASE) ; -- hay que meter restar 64
		 write_en_temp  <= write_en;
        oe_temp  <= oe;
		  write_en_temp2  <= '0';
        oe_temp2  <= '1'; --No hacer nada
	ELSE 
		address_temp2<=address;
		--advisor<='1';
		write_en_temp2  <= write_en;
        oe_temp2  <= oe;
		write_en_temp  <= '0';
        oe_temp  <= '1'; --No hacer nada
	END IF;

END PROCESS;


--  constant DMA_RX_BUFFER_MSB : std_logic_vector(7 downto 0) := X"00";
--  constant DMA_RX_BUFFER_MID : std_logic_vector(7 downto 0) := X"01";
--  constant DMA_RX_BUFFER_LSB : std_logic_vector(7 downto 0) := X"02";
--  constant NEW_INST          : std_logic_vector(7 downto 0) := X"03";
--  constant DMA_TX_BUFFER_MSB : std_logic_vector(7 downto 0) := X"04";
--  constant DMA_TX_BUFFER_LSB : std_logic_vector(7 downto 0) := X"05";
--  constant SWITCH_BASE       : std_logic_vector(7 downto 0) := X"10";
--  constant LEVER_BASE        : std_logic_vector(7 downto 0) := X"20";
--  constant CAL_OP            : std_logic_vector(7 downto 0) := X"30";
--  constant T_STAT            : std_logic_vector(7 downto 0) := X"31";
--  constant GP_RAM_BASE       : std_logic_vector(7 downto 0) := X"40";


ram_reg : PROCESS (clk, reset)  
BEGIN
  IF reset = '0' THEN  -- asynchronous reset (active low)
  contents_ram(conv_Integer(DMA_RX_BUFFER_MSB)) <= X"00";
  contents_ram(conv_Integer(DMA_RX_BUFFER_MSB + X"01")) <= X"00";
  contents_ram(conv_Integer(DMA_RX_BUFFER_MSB + X"02")) <= X"00";
  contents_ram(conv_Integer(DMA_RX_BUFFER_MSB + X"03")) <= X"00";
  contents_ram(conv_Integer(DMA_RX_BUFFER_MSB + X"04")) <= X"00";
  contents_ram(conv_Integer(DMA_RX_BUFFER_MSB + X"05")) <= X"00";
  contents_ram(conv_Integer(SWITCH_BASE)) <= X"00";
  contents_ram(conv_Integer(SWITCH_BASE + X"01")) <= X"00";
  contents_ram(conv_Integer(SWITCH_BASE + X"02")) <= X"00";
  contents_ram(conv_Integer(SWITCH_BASE + X"03")) <= X"00";
  contents_ram(conv_Integer(SWITCH_BASE + X"04")) <= X"00";
  contents_ram(conv_Integer(SWITCH_BASE + X"05")) <= X"00";
  contents_ram(conv_Integer(SWITCH_BASE + X"06")) <= X"00";
  contents_ram(conv_Integer(SWITCH_BASE + X"07")) <= X"00";
 
  contents_ram(conv_Integer(LEVER_BASE)) <= X"00";
  contents_ram(conv_Integer(LEVER_BASE + X"01")) <= X"00";
  contents_ram(conv_Integer(LEVER_BASE + X"02")) <= X"00";
  contents_ram(conv_Integer(LEVER_BASE + X"03")) <= X"00";
  contents_ram(conv_Integer(LEVER_BASE + X"04")) <= X"00";
  contents_ram(conv_Integer(LEVER_BASE + X"05")) <= X"00";
  contents_ram(conv_Integer(LEVER_BASE + X"06")) <= X"00";
  contents_ram(conv_Integer(LEVER_BASE + X"07")) <= X"00";
  contents_ram(conv_Integer(LEVER_BASE + X"08")) <= X"00";
  
   contents_ram(conv_Integer(T_STAT)) <= X"16";
-- dar valores iniciales  
  ELSIF (clk'event AND clk = '1')then
--	if( advisor = '1') THEN
		IF write_en_temp2 = '1' THEN
			contents_ram(conv_Integer(address_temp2)) <= databus;
		END IF;
	--else
	
	--end if;
		
  END IF;

END PROCESS;
--hay que seleccionar el databus correcto

databus<= contents_ram(conv_integer(address)) WHEN (oe_temp2 = '0')ELSE (OTHERS => 'Z');



Switches<=(contents_ram(conv_integer(SWITCH_BASE))(0))
&(contents_ram(conv_integer(SWITCH_BASE+ X"01"))(0))
&(contents_ram(conv_integer(SWITCH_BASE+ X"02"))(0))
&(contents_ram(conv_integer(SWITCH_BASE+ X"03"))(0))
&(contents_ram(conv_integer(SWITCH_BASE+ X"04"))(0))
&(contents_ram(conv_integer(SWITCH_BASE+ X"05"))(0))
&(contents_ram(conv_integer(SWITCH_BASE+ X"06"))(0))
&(contents_ram(conv_integer(SWITCH_BASE+ X"07"))(0));

-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- Decodificador de BCD a 7 segmentos
-------------------------------------------------------------------------
with contents_ram(conv_integer(T_STAT))(7 downto 4) select
Temp_H <=
    "0000110" when "0001",  -- 1
    "1011011" when "0010",  -- 2
    "1001111" when "0011",  -- 3
    "1100110" when "0100",  -- 4
    "1101101" when "0101",  -- 5
    "1111101" when "0110",  -- 6
    "0000111" when "0111",  -- 7
    "1111111" when "1000",  -- 8
    "1101111" when "1001",  -- 9
--    "1110111" when "1010",  -- A
--    "1111100" when "1011",  -- B
--    "0111001" when "1100",  -- C
--    "1011110" when "1101",  -- D
--    "1111001" when "1110",  -- E
--    "1110001" when "1111",  -- F
    "0111111" when others;  -- 0
	 with contents_ram(conv_integer(T_STAT))(3 downto 0) select
Temp_L <=
    "0000110" when "0001",  -- 1
    "1011011" when "0010",  -- 2
    "1001111" when "0011",  -- 3
    "1100110" when "0100",  -- 4
    "1101101" when "0101",  -- 5
    "1111101" when "0110",  -- 6
    "0000111" when "0111",  -- 7
    "1111111" when "1000",  -- 8
    "1101111" when "1001",  -- 9
--    "1110111" when "1010",  -- A
--    "1111100" when "1011",  -- B
--    "0111001" when "1100",  -- C
--    "1011110" when "1101",  -- D
--    "1111001" when "1110",  -- E
--    "1110001" when "1111",  -- F
    "0111111" when others;  -- 0
-------------------------------------------------------------------------

END behavior;

