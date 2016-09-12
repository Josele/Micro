
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity contador is
    generic ( size: integer:= 4
    );
    port ( clk, reset: in std_logic;
           q: out std_logic;
			  q_vec: out std_logic_vector(size-1 downto 0)
    );
end contador;

architecture behavior of contador is

    signal q_i: unsigned (size-1 downto 0);
	 signal q_o: std_logic;
	 signal q_cuenta: std_logic_vector(size-1 downto 0);
begin

    process (clk, reset)
    begin
		q_o<='0';
		
        if reset = '1' then
            q_i <= (others => '0');
				q_cuenta<=(others => '0');
        elsif  clk'event and clk = '1' then

            if q_i = 2**size - 1 then
                q_i <= conv_unsigned (0, size);
            else
                q_i <= q_i + 1;
            end if;
				q_cuenta<=q_i;
			if q_i= 173 then
			q_o<='1';
			end if;
        end if;
    end process;

    q <= q_o;
	q_vec	<=q_cuenta;
end behavior;

