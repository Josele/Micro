----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:16:58 10/21/2014 
-- Design Name: 
-- Module Name:    ShiftRegister - Behavioral 
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
----------------------------------------------------------------------------------library IEEE;

LIBRARY ieee;
   USE ieee.std_logic_1164.ALL;
   USE ieee.numeric_std.ALL;
   USE ieee.std_logic_arith.ALL;
   USE ieee.std_logic_unsigned.ALL;

ENTITY ShiftRegister IS
	PORT	(
			Q : OUT std_logic_vector(7 DOWNTO 0);
			Clk, Enable, D, Reset : IN std_logic);
	END ShiftRegister;


ARCHITECTURE ShiftRegister OF ShiftRegister IS

	SIGNAL content: std_logic_vector(7 DOWNTO 0);
	
	BEGIN	
		PROCESS(Clk, Reset)
			BEGIN
			IF (Reset = '0') THEN
				content <= "00000000";
			ELSIF(rising_edge(Clk)) THEN
				IF (Enable = '1') THEN
					content <= D & content(7 DOWNTO 1);
				END IF;
			END IF;
		END PROCESS;		
	Q <= content;
	
END ShiftRegister;