----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2021 04:34:58 PM
-- Design Name: 
-- Module Name: systolic_row - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.types.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity systolic_row is
    generic(W:integer := 9; BIAS:integer := 0; SCALE:integer := 16777216; WEIGHTS: vector_int);
    port(
        clk: in std_logic;
        nums_in: in vector_8bit(W-1 downto 0);
        clr: in std_logic;
        nums_out: out vector_8bit(W-1 downto 0);
        mac_out: out signed(7 downto 0)
--        weight_out: out signed(7 downto 0)
    );
end systolic_row;

architecture Behavioral of systolic_row is

component systolic_cell is
    generic(
        WEIGHT: integer := 1
    );
    port(
        clk: in std_logic;
        sum_in: in signed(31 downto 0);
        num_in: in signed(7 downto 0);
        clr: in std_logic;
        num_out: out signed(7 downto 0);
        sum_out: out signed(31 downto 0)
--        weight_out: out signed(7 downto 0)
    );
end component;
component signed_reg is
	 generic(N:integer := 8; DEFAULT:integer := 0);
	 port(
		 load : in STD_LOGIC;
		 clk : in STD_LOGIC;
		 clr : in STD_LOGIC;
		 d : in SIGNED(N-1 downto 0);
		 q : out SIGNED(N-1 downto 0)
	     );
end component;

--signal weight_chain: vector_8bit(W downto 0);
signal sum_chain: vector_32bit(W downto 0);
signal bias_input, biased: signed(31 downto 0);
signal scaled: signed(63 downto 0);
signal rounding_correction: signed(1 downto 0);
signal result: signed(7 downto 0);
--attribute use_dsp : string;
--attribute use_dsp of Behavioral : architecture is "yes";
begin

gen_cells: for i in 0 to W-1 generate
    cell: systolic_cell generic map(WEIGHT=>WEIGHTS(i)) 
                        port map(clk => clk, sum_in => sum_chain(i), num_in => nums_in(i), 
                        clr => clr, num_out => nums_out(i),sum_out => sum_chain(i+1));
end generate;
in_reg: signed_reg generic map(N => 32) port map(clk => clk, clr => clr, load => '1', d => sum_chain(W), q => bias_input);
out_reg: signed_reg port map(clk => clk, clr => clr, load => '1', d => result, q => mac_out); 

--weight_chain(0) <= weight_in;
sum_chain(0) <= x"00000000";
biased <= bias_input + to_signed(BIAS, bias_input'length);
--biased <= sum_chain(W) + to_signed(BIAS, sum_chain(W)'length);
scaled <= (biased * to_signed(SCALE, biased'length));
rounding_correction <= "01" when scaled(31) = '0' else "00";
result <= (not(scaled(31)) & scaled(30 downto 24)) + rounding_correction  when biased(31) = '0' else x"80";
--weight_out <= weight_chain(W);

end Behavioral;
