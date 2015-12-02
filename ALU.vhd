----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:57:15 12/02/2014 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
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


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           u_instruction : in  ALU_OP;
           FlagZ : out  STD_LOGIC;
           FlagC : out  STD_LOGIC;
           FlagN : out  STD_LOGIC;
           FlagE : out  STD_LOGIC;
           Index_Reg : out  STD_LOGIC_VECTOR (7 downto 0);
           Databus : inout  STD_LOGIC_VECTOR (7 downto 0));
end ALU;

architecture Behavioral of ALU is
	signal a, b : std_logic_vector (7 downto 0);
	signal acc, index : std_logic_vector (7 downto 0);

begin

	

--nop,                                  -- no operation
--      op_lda, op_ldb, op_ldacc, op_ldid,    -- external value load
--      op_mvacc2id, op_mvacc2a, op_mvacc2b,  -- internal load
--      op_add, op_sub, op_shiftl, op_shiftr, -- arithmetic operations
--      op_and, op_or, op_xor,                -- logic operations
--      op_cmpe, op_cmpl, op_cmpg,            -- compare operations
--      op_ascii2bin, op_bin2ascii,           -- conversion operations
--      op_oeacc);  
databus <= (others => 'Z');

PROCESS (reset,clk)
		BEGIN
				
			IF (reset='0') THEN
				flagz<='0';
				flagc<='0';
				flagn<='0';
				flage<='0';
				a<= (OTHERS => '0');
				b<= (OTHERS => '0');
				acc<= (OTHERS => '0');
				index<= (OTHERS => '0');
				
			ELSIF clk'event AND clk='1' THEN	

				case u_instruction is
					
					when nop =>
					-- como funciona						
					
					when op_lda =>
						a<=databus;
						
					when op_ldb =>
						b<=databus;
						
					when op_ldacc =>
						acc <=databus;
						
					when op_ldid =>
						index <= databus;
						
					when op_mvacc2id =>
						index <= acc;
						
					when op_mvacc2a =>
						a <= acc;
						
					when op_mvacc2b =>
						b <=acc;
						
					when op_add =>
						acc <= a+b;
						if((a+b) = "00000000") then
							flagz <='1';
						else
							flagz <='0';
						end if;
						
					when op_sub =>
						acc <= a-b;
						if((a-b) = "00000000") then
							flagz <='1';
						else
							flagz <='0';
						end if;
						
					when op_shiftl =>
						acc<=shl(acc, "000000001");
						
						
					when op_shiftr =>
						acc <= '0'& acc(7 downto 1);
					
					when op_and =>
						acc <= a and b;
						if((a and b)= "00000000") then
							flagz<= '1';
						else
							flagz<= '0';
						end if;
						
					when op_or =>
						acc <= a or b;
						if((a or b) = "00000000") then
							flagz<= '1';
						else
							flagz<= '0';
						end if;
						
					when op_xor =>
						acc <= a xor b;
						if((a xor b)= "00000000") then
							flagz<= '1';
						else
							flagz<= '0';	
						end if;						
					
					when op_cmpe =>
						if a = b then
							flagz <='1';
						else
							flagz <='0';
						end if;
						
					when op_cmpl =>
						if a < b then
							flagz <='1';
						else
							flagz <='0';
						end if;
						
					when op_cmpg =>
						if a > b then
							flagz <='1';
						else
							flagz <='0';
						end if;
						
					when op_ascii2bin =>
						acc <= a-"00110000";						
					when op_bin2ascii =>
						acc <= a +"00110000";
						
					when op_oeacc =>
					
					--when others => null;
						
				END CASE;
				
				
			END IF;
	
	END PROCESS;
	
	index_reg <= index;
	
process(u_instruction,acc)
begin
	case u_instruction is
		when op_oeacc =>
			databus<= acc;
		when others =>
			databus <= (others => 'Z');			
	end case;
end process;
end Behavioral;

