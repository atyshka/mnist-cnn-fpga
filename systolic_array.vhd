----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2021 08:22:05 PM
-- Design Name: 
-- Module Name: systolic_array - Behavioral
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

entity systolic_array is
    generic(H:integer := 12; W:integer := 9; BIASES:vector_int(0 to 11); SCALES:vector_int(0 to 11); WEIGHTS:matrix_int);
    port(
        clk: in std_logic;
        nums_in: in vector_8bit(W-1 downto 0);
        clr: in std_logic;
        mac_out: out vector_8bit(H-1 downto 0)
    );
end systolic_array;

architecture Behavioral of systolic_array is
component systolic_row is
    generic(W:integer := 9; BIAS:integer := 0; SCALE:integer := 16777216; WEIGHTS: vector_int);
    port(
        clk: in std_logic;
        nums_in: in vector_8bit(W-1 downto 0);
        clr: in std_logic;
        nums_out: out vector_8bit(W-1 downto 0);
        mac_out: out signed(7 downto 0)
--        weight_out: out signed(7 downto 0)
    );
end component;

type matrix_8bit is array(H downto 0) of vector_8bit(W-1 downto 0);
type addr_table is array(H-1 downto 0) of std_logic_vector(W-1 downto 0);
    
--signal weight_chain: vector_8bit(H downto 0);
signal nums: matrix_8bit;
signal load_signals: std_logic_vector((W * H) - 1 downto 0);

begin
gen_rows: for i in 0 to H-1 generate
    cell: systolic_row generic map(BIAS => BIASES(i), SCALE => SCALES(i), WEIGHTS=>WEIGHTS(i)) 
                        port map(clk => clk, nums_in => nums(i), clr => clr, nums_out => nums(i+1), mac_out => mac_out(i));
end generate;

nums(0) <= nums_in;

end Behavioral;
