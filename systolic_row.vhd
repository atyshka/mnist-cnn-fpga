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
use IEEE.NUMERIC_STD.ALL;

package types is
    type vector_8bit is array(natural range <>) of signed(7 downto 0);
    type vector_32bit is array(natural range <>) of signed(31 downto 0);
end package;

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
    generic(W:integer := 9; BIAS:integer := 0; SCALE:integer := 16777216);
    port(
        clk: in std_logic;
        nums_in: in vector_8bit(W-1 downto 0);
        weight_in: in signed(7 downto 0);
        weight_ld: in std_logic_vector(W-1 downto 0);
        clr: in std_logic;
        nums_out: out vector_8bit(W-1 downto 0);
        mac_out: out signed(7 downto 0)
--        weight_out: out signed(7 downto 0)
    );
end systolic_row;

architecture Behavioral of systolic_row is

component systolic_cell is
    port(
        clk: in std_logic;
        sum_in: in signed(31 downto 0);
        num_in: in signed(7 downto 0);
        weight_in: in signed(7 downto 0);
        weight_ld: in std_logic;
        clr: in std_logic;
        num_out: out signed(7 downto 0);
        sum_out: out signed(31 downto 0)
--        weight_out: out signed(7 downto 0)
    );
end component;

--signal weight_chain: vector_8bit(W downto 0);
signal sum_chain: vector_32bit(W downto 0);
signal biased: signed(31 downto 0);
signal scaled: signed(63 downto 0);

begin

gen_cells: for i in 0 to W-1 generate
    cell: systolic_cell port map(clk => clk, sum_in => sum_chain(i), num_in => nums_in(i), weight_in => weight_in, weight_ld => weight_ld(i), clr => clr, num_out => nums_out(i),sum_out => sum_chain(i+1));
end generate;

--weight_chain(0) <= weight_in;
sum_chain(0) <= x"00000000";
biased <= sum_chain(W) + to_signed(BIAS, sum_chain'length);
scaled <= (biased * to_signed(SCALE, biased'length));
mac_out <= scaled(31 downto 24);
--weight_out <= weight_chain(W);

end Behavioral;
