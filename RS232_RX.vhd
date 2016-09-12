
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

use ieee.std_logic_arith.all;
ENTITY RS232_RX IS
    PORT (
         reset: in std_logic;
         clk: in std_logic;
         LineRD_in: in std_logic;
         Valid_out, Code_out, Store_out: out std_logic
    );
END;

ARCHITECTURE behavior OF RS232_RX IS

   TYPE estados IS (idle, StartBit, RcvData, StopBit);
   SIGNAL current_state, next_state: estados;
   SIGNAL valid_tmp, code_tmp, store_tmp,bit_rev,reset_BitCounter,reset_HalfBitCounter,reset_DataCount: std_logic;
	signal DataCount:  unsigned (3 downto 0) ;
	signal BitCounter: unsigned(7 downto 0);
	signal HalfBitCounter: unsigned(7 downto 0) ;


	BEGIN
	  
		PROCESS(current_state, LineRD_in, Bitcounter, Halfbitcounter, Datacount)
	 
		BEGIN
         -- Asignaciones por defecto
			next_state <= current_state;
			valid_tmp <= '0';
			code_tmp <= '0';
			store_tmp <= '0';
			bit_rev<='0';
			reset_BitCounter<='0';
			reset_HalfBitCounter<='0';
			reset_DataCount<='0';
         -- Lógica para transiciones y salidas
         CASE current_state IS
				WHEN idle =>
					IF (LineRD_in='0') THEN
						next_state <= StartBit;
						reset_BitCounter<='1';
						reset_HalfBitCounter<='1';
					ELSE 
						next_state <= idle;
               END IF;
				WHEN StartBit =>
					IF (BitCounter=173) THEN
						next_state <= RcvData;
						reset_BitCounter<='1';
						reset_HalfBitCounter<='1';
					ELSE
						next_state <= StartBit; 
					END IF;
                    
            WHEN RcvData =>
             	IF (BitCounter=173) THEN
						reset_BitCounter<='1';
						reset_HalfBitCounter<='1'; 
					IF (DataCount=8) THEN
						next_state <= Stopbit;									
					END IF;							 
					ELSIF (HalfBitCounter=86) THEN
						bit_rev <='1';
						code_tmp <=LineRD_in;
						valid_tmp <='1';						
					END IF;
						  
				WHEN StopBit =>
					IF (BitCounter=173) THEN
						next_state <= idle;
						reset_BitCounter<='1';
						reset_DataCount<='1';
						reset_HalfBitCounter<='1';
					ELSIF(HalfBitCounter=86)and(LineRD_in='1') THEN
						store_tmp <='1';
               END IF;
           WHEN OTHERS =>null;
			END CASE;
        
    END PROCESS;
	  
    PROCESS (reset,clk,reset_HalfBitCounter,reset_BitCounter,bit_rev,DataCount,reset_DataCount)
    BEGIN
			IF (reset='0') THEN
				current_state <= idle;
				DataCount<=(others => '0');
				BitCounter<=(others => '0');
				HalfBitCounter<=(others => '0');
				Valid_out <= '0';
				Code_out <='0' ;
				Store_out <= '0';
			ELSIF clk'event AND clk='1' THEN
				HalfBitCounter<=HalfBitCounter+1;
				BitCounter<=BitCounter+1;
			
				IF reset_HalfBitCounter='1' then
					HalfBitCounter<=conv_unsigned (0, 8);
				End IF;
				IF reset_DataCount='1' then
					DataCount<=conv_unsigned (0, 4);
				End IF;
				IF reset_BitCounter='1' then
					BitCounter<=conv_unsigned (0, 8);
				End IF;
				IF bit_rev='1' then
					DataCount<=DataCount+1;
				IF DataCount=9 then
					DataCount<=conv_unsigned (0, 4);
				End IF;
				End IF;
				current_state <= next_state;
				Valid_out <= valid_tmp;
				Code_out <= Code_tmp;
				Store_out <= Store_tmp;
        END IF;

    END PROCESS;

END behavior;
