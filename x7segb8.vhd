-- x7segb8 - Display 7-seg with leading blanks on 8 digits
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity x7segb8 is
	 port(
		 x : in STD_LOGIC_VECTOR(31 downto 0);
		 clk : in STD_LOGIC;
		 clr : in STD_LOGIC;
		 a_to_g : out STD_LOGIC_VECTOR(6 downto 0);
		 an : out STD_LOGIC_VECTOR(7 downto 0);
		 dp : out STD_LOGIC
	     );
end x7segb8;

architecture behavioral of x7segb8 is

signal s: STD_LOGIC_VECTOR(2 downto 0);
signal digit: STD_LOGIC_VECTOR(3 downto 0);
signal aen: STD_LOGIC_VECTOR(7 downto 0);
signal clkdiv: STD_LOGIC_VECTOR(19 downto 0);

begin

	s <= clkdiv(19 downto 17);
	dp <= '1';
	-- set aen(3 downto 0) for leading blanks
	aen(7) <= x(31) or x(30) or x(29) or x(28);
	aen(6) <= x(31) or x(30) or x(29) or x(28)
			or x(27) or x(26) or x(25) or x(24);
	aen(5) <= x(31) or x(30) or x(29) or x(28)
            or x(27) or x(26) or x(25) or x(24)
			or x(23) or x(22) or x(21) or x(20);
    aen(4) <= x(31) or x(30) or x(29) or x(28)
            or x(27) or x(26) or x(25) or x(24)
            or x(23) or x(22) or x(21) or x(20)
            or x(19) or x(18) or x(17) or x(16);
    aen(3) <= x(31) or x(30) or x(29) or x(28)
            or x(27) or x(26) or x(25) or x(24)
            or x(23) or x(22) or x(21) or x(20)
            or x(19) or x(18) or x(17) or x(16)
            or x(15) or x(14) or x(13) or x(12);
    aen(2) <= x(31) or x(30) or x(29) or x(28)
            or x(27) or x(26) or x(25) or x(24)
            or x(23) or x(22) or x(21) or x(20)
            or x(19) or x(18) or x(17) or x(16)
            or x(15) or x(14) or x(13) or x(12)
            or x(11) or x(10) or x(9) or x(8);
    aen(1) <= x(31) or x(30) or x(29) or x(28)
            or x(27) or x(26) or x(25) or x(24)
            or x(23) or x(22) or x(21) or x(20)
            or x(19) or x(18) or x(17) or x(16)
            or x(15) or x(14) or x(13) or x(12)
            or x(11) or x(10) or x(9) or x(8)
            or x(7) or x(6) or x(5) or x(4);
	aen(0) <= '1';	-- digit 0 always on
	
-- Quad 4-to-1 MUX: mux44
	process(s, x)
	begin
		case s is
		when "000" => digit <= x(3 downto 0);
		when "001" => digit <= x(7 downto 4);
		when "010" => digit <= x(11 downto 8);
		when "011" => digit <= x(15 downto 12);
		when "100" => digit <= x(19 downto 16);
		when "101" => digit <= x(23 downto 20);
		when "110" => digit <= x(27 downto 24);
		when others => digit <= x(31 downto 28);
		end case;
	end process;

-- 7-segment decoder: hex7seg
   process(digit)
   begin
      case digit is
          when X"0" => a_to_g <= "0000001";	 --0
          when X"1" => a_to_g <= "1001111";	 --1
          when X"2" => a_to_g <= "0010010";	 --2
          when X"3" => a_to_g <= "0000110";	 --3
          when X"4" => a_to_g <= "1001100";	 --4
          when X"5" => a_to_g <= "0100100";	 --5
          when X"6" => a_to_g <= "0100000";	 --6
          when X"7" => a_to_g <= "0001101";	 --7
          when X"8" => a_to_g <= "0000000";	 --8
          when X"9" => a_to_g <= "0000100";	 --9
          when X"A" => a_to_g <= "0001000";	 --A
          when X"B" => a_to_g <= "1100000";	 --b
          when X"C" => a_to_g <= "0110001";	 --C
          when X"D" => a_to_g <= "1000010";	 --d
          when X"E" => a_to_g <= "0110000";	 --E
          when others => a_to_g <= "0111000";	 --F
      end case;
   end process;

-- Digit select: ancode
	process(s, aen)
	begin
		an <= "11111111";
		if aen(conv_integer(s)) = '1' then
		   an(conv_integer(s)) <= '0';
		end if;
	end process;

-- Clock divider
	process(clk, clr)
	begin
		if clr = '1' then
		   clkdiv <= (others => '0');
		elsif clk'event and clk = '1' then
		   clkdiv <= clkdiv + 1;
		end if;
	end process;
end behavioral;
