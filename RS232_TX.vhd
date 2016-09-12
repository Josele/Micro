
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

USE ieee.std_logic_arith.all;
ENTITY RS232_TX IS
    PORT (
         reset: IN std_logic;
         clk: IN std_logic;
         Start: IN std_logic;
			Data:IN std_logic_vector(7 DOWNTO 0);
         EOT, TX: OUT std_logic);
END;

ARCHITECTURE behavior OF RS232_TX IS

   TYPE estados IS (idle, StartBit, SendData, StopBit);
	
   SIGNAL current_state, next_state: estados;
   SIGNAL EOT_tmp,bit_trans,reset_Data_count,reset_Pulse_width: STD_LOGIC;
	SIGNAL Data_count: unsigned(3 DOWNTO 0);
	SIGNAL Pulse_width: unsigned(7 DOWNTO 0) ;
	SIGNAL q_vec: unsigned(3 DOWNTO 0);

	BEGIN	
	
   PROCESS(current_state, Start, Data_count, Pulse_width)	 
		BEGIN
			  -- Asignaciones por defecto
			next_state <= current_state;
			bit_trans<='0';
			reset_Data_count<='0';
			reset_Pulse_width<='0';
			EOT_tmp<='1';
				-- Lógica para transiciones y salidas
			CASE current_state IS
				 WHEN idle =>
					 IF (Start='1') THEN
						next_state <= StartBit;
						reset_Data_count<='1';
						reset_Pulse_width<='1';
						bit_trans <='1';
						EOT_tmp<='0';
					 ELSE 
						next_state <= idle;
					 END IF;
				 WHEN StartBit =>
					 IF (Pulse_width=173) THEN
						next_state <= SendData;
						reset_Pulse_width<='1';
						bit_trans <='1';
						EOT_tmp<='0';
					 ELSE
						 next_state <= StartBit; 
						 EOT_tmp<='0';
					 END IF;
					  
				 WHEN SendData =>
					next_state <= SendData;
					EOT_tmp<='0';
					IF (Pulse_width=173) THEN
					
						reset_Pulse_width<='1';
						bit_trans <='1';
						IF (Data_count=9) THEN
							next_state <= Stopbit;
						END IF;
					END IF;							
						 
				 WHEN StopBit =>
					EOT_tmp<='0';
					IF (Pulse_width=173) THEN
						next_state <= idle;
						EOT_tmp<='1';
						reset_Pulse_width<='1';
						reset_Data_Count<='1';
					ELSE
						next_state <= Stopbit;
					END IF;
					
				 WHEN OTHERS =>null;
				 
			END CASE;        
	END PROCESS;
	  
	PROCESS (reset,clk)
		BEGIN
			IF (reset='0') THEN
				current_state <= idle;
				Data_Count<=(others => '0');
				Pulse_width<=(others => '0');
				EOT <= '1';	
				q_vec<="1001";
			ELSIF clk'event AND clk='1' THEN				
				Pulse_width<=Pulse_width+1;			
				IF reset_Pulse_width='1' THEN
					Pulse_width<=conv_unsigned (0, 8);
				END IF;
				IF reset_Data_Count='1' THEN
					Data_Count<=conv_unsigned (0, 4);
				END IF;
				q_vec<=q_vec;
				IF bit_trans='1' THEN
					q_vec <=Data_Count;
					Data_Count<=Data_Count+1;				
					IF Data_Count=10 THEN
						Data_Count<=conv_unsigned (0, 4);
					END IF;
				END IF;
				current_state <= next_state;
				EOT <= EOT_tmp;	 
			END IF;
	END PROCESS;

	PROCESS (q_vec,Data) IS
		BEGIN
			CASE q_vec IS
			  WHEN "0000" => TX <= '0';
			  WHEN "0001" => TX <= Data(0);
			  WHEN "0010" => TX <= Data(1);
			  WHEN "0011" => TX <= Data(2);
			  WHEN "0100" => TX <= Data(3);
			  WHEN "0101" => TX <= Data(4);
			  WHEN "0110" => TX <= Data(5);
			  WHEN "0111" => TX <= Data(6);
			  WHEN "1000" => TX <= Data(7);
			  WHEN "1001" => TX <= '1';
			  WHEN OTHERS => TX <= '0';
			END CASE;
   END PROCESS;
END behavior;

