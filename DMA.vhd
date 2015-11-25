----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:58:56 11/18/2014 
-- Design Name: 
-- Module Name:    DMA - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

USE work.PIC_pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DMA is
    Port ( reset : in  STD_LOGIC;
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
           dma_ack : in  STD_LOGIC;
           send_comm : in  STD_LOGIC;
           ready : out  STD_LOGIC);
end DMA;

architecture Behavioral of DMA is
	TYPE estados IS (idle, espera_bus,read_ok,datos2mem, mem_ok, bus_back, escribe_ff, tx_start, 
			tx_mem_1B,tx_1B,tx_2B,tx_mem_2B,wait_tx  );
	
   SIGNAL current_state, next_state: estados;
   SIGNAL reset_Data_count: STD_LOGIC;
	SIGNAL Data_count: unsigned(1 DOWNTO 0):="00";
	SIGNAL data_read_tmp: std_logic;
--	SIGNAL send_comm_tmp: std_logic;
	SIGNAL q_vec: unsigned(3 DOWNTO 0);


	
BEGIN
   PROCESS(current_state, RX_Empty, dma_ack,Data_count,send_comm, tx_rdy, ack_out)	 
		BEGIN
			
			data_read_tmp<='0';
--			send_comm_tmp<='0';
			reset_data_counT<='0'; 
				-- Lógica para transiciones y salidas
			CASE current_state IS
			
				 WHEN idle =>
				 if(send_comm = '1') then
					next_state <= tx_start;
				 elsIF (RX_Empty='0') THEN	

					next_state <= espera_bus;
   			 ELse				
  					next_state <= idle;
  				 END IF;
					 
				 WHEN espera_bus =>
					 IF (dma_ack='1') THEN
						next_state <= read_ok;						
					 ELSE
						 next_state <= espera_bus;						
					 END IF;
					 
				 WHEN read_ok =>
				  IF (RX_Empty='0') then 
					 data_read_tmp<='1';
					 next_state <= datos2mem;
				 else 
					 next_state <= read_ok;
				 end if;	
				 
					 WHEN datos2mem =>
				 
					 next_state <= mem_ok;

				 WHEN mem_ok =>				
				--	bus_tmp<=rcvd_data: meter en process de clk		
				
					IF (Data_count=2) THEN
						next_state <= escribe_ff;
						reset_data_count<='1';
						
					else 
						next_state <= read_ok;
					END IF;							
						 
				 WHEN bus_back =>
				 IF (dma_ack='0') THEN
						next_state <= idle;
						
					 ELSE
						 next_state <= bus_back; 
						
				 END IF;
				
				 WHEN escribe_ff =>				
						 next_state <= bus_back; 				
				 WHEN tx_start =>				
						 next_state <= tx_mem_1B;
						 
				 WHEN tx_mem_1B =>				
						 if(tx_rdy= '0')then
							next_state <= tx_mem_1B;
						 else
							next_state <= tx_1B;
						 end if;
						
				
				 WHEN tx_1B =>	
						if(ack_out = '0')then
							next_state <= tx_mem_2B;
						else
							next_state <= tx_1B;
						end if;
						
				
				 WHEN tx_mem_2B =>
						if(tx_rdy= '0')then
							next_state <= tx_mem_2B;
						else
						 next_state <= tx_2B;
						end if;
				 
				 WHEN tx_2B =>	
						if(ack_out = '0')then
							next_state <= wait_tx;
						else
							next_state <= tx_2B;
						end if;
						
				  WHEN wait_tx =>	
						if(tx_rdy='1')then
							next_state <=idle;

						else
							next_state <= wait_tx;
						end if;
						 
						
				 WHEN OTHERS =>null;
--				 
			END CASE;        
	END PROCESS;
	
	  
	PROCESS (reset,clk)
		
		
--		 data_read : out  STD_LOGIC;
--           ack_out : in  STD_LOGIC;
--           tx_rdy : in  STD_LOGIC;
--           valid_d : out  STD_LOGIC;
--           tx_data : out  STD_LOGIC_VECTOR (7 downto 0);
--           address : out  STD_LOGIC_VECTOR (7 downto 0);
--           databus : inout  STD_LOGIC_VECTOR (7 downto 0);
--           write_en : out  STD_LOGIC;
--           oe : out  STD_LOGIC;
--           dma_rq : out  STD_LOGIC;
--           dma_ack : in  STD_LOGIC;
--           send_comm : in  STD_LOGIC;
--           ready : out  STD_LOGIC);
		BEGIN
			IF (reset='0') THEN
				current_state <= idle;
				Data_Count<=(others => '0');
				databus<=(others=>'Z');
				address<=(others=>'Z');
				write_en <='Z';
            oe <='Z';
				dma_rq<='0';
--				ready<= '1';
				valid_d<='1';
				tx_data<=(others => '0');
				data_read<='0';
			ELSIF clk'event AND clk='1' THEN	
				
				data_read<=data_read_tmp;
				
				
				if current_state=idle then
					write_en <='Z';
					oe <='Z';
					databus<=(others=>'Z');
					address<=(others=>'Z');
					dma_rq<='0';
					valid_d<='1';
				end if;
				
				if current_state=espera_bus then
					write_en <='Z';
					oe <='Z';
					databus<=(others=>'Z');
					dma_rq<='1';
					address<=(others=>'Z');
					valid_d<='1';
				end if;
				
				if current_state=datos2mem then
					write_en <='Z';
					oe <='Z';
					databus<=(others=>'Z');
					dma_rq<='1';
					address<=(others=>'Z');
					valid_d<='1';
				end if;
				
				if current_state=mem_ok then
					oe <= '1';
					dma_rq<='1';
					write_en  <= '1';
					databus <= rcvd_data;
					address <= DMA_RX_BUFFER_MSB + conv_Integer(Data_Count);
					Data_Count <= Data_Count+ 1;
					valid_d<='1';
				end if;
				
				if current_state=bus_back then
					write_en <='Z';
					oe <='Z';
					databus<=(others=>'Z');
					address<=(others=>'Z');
					dma_rq<='0';
					valid_d<='1';
				end if;
				
				if current_state=tx_start then
					write_en <='Z';
					oe <='Z';
					databus<=(others=>'Z');
					address<=(others=>'Z');					
					dma_rq<='0';
					valid_d<='1';
					end if;
				
				if current_state=tx_mem_1B then
					write_en<='0';
					oe <='0';
					tx_data<=databus;
					address<=DMA_TX_BUFFER_MSB;					
					dma_rq<='0';
					valid_d<='1';
				end if;
				
				if current_state=tx_1B then
					write_en<='0';
					oe <='0';
					tx_data<=databus;
					address<=DMA_TX_BUFFER_MSB;					
					dma_rq<='0';
					valid_d<='0';
				end if;
				
				if current_state=tx_mem_2B then
					write_en<='0';
					oe <='0';
					tx_data<=databus;
					address<=DMA_TX_BUFFER_LSB;					
					dma_rq<='0';
					valid_d<='1';
				end if;
				
				if current_state=tx_2B then
					write_en<='0';
					oe <='0';
					tx_data<=databus;
					address<=DMA_TX_BUFFER_LSB;					
					dma_rq<='0';
					valid_d<='0';
				end if;
				
				if current_state=wait_tx then
					write_en <='Z';
					oe <='Z';
					databus<=(others=>'Z');
					address<=(others=>'Z');					
					dma_rq<='0';
					valid_d<='1';
				end if;

				IF reset_Data_Count='1' THEN
					Data_Count<=conv_unsigned (0, 2);
				END IF;
	
				if(current_state=escribe_ff)then
					write_en<='1';
					oe <='1';
					databus<= "11111111";
					dma_rq<='1';
					address<= NEW_INST;
				end if;
				
				current_state <= next_state;
				 
			END IF;
	END PROCESS;
	
	process (send_comm,current_state)
	begin
		if (send_comm='1')  then 
			ready<='0';
		else
			ready<='1';
		end if;
		
		if current_state=wait_tx then
			ready<='1';
		end if;
	
	end process;

end Behavioral;

