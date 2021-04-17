----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/26/2021 10:20:03 PM
-- Design Name: 
-- Module Name: systolic_cell - Behavioral
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity systolic_cell is
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
end systolic_cell;

architecture Behavioral of systolic_cell is
attribute use_dsp : string;
attribute use_dsp of Behavioral : architecture is "yes";
component signed_reg is
	 generic(N:integer := 8);
	 port(
		 load : in STD_LOGIC;
		 clk : in STD_LOGIC;
		 clr : in STD_LOGIC;
		 d : in SIGNED(N-1 downto 0);
		 q : out SIGNED(N-1 downto 0)
	     );
end component;

signal num: signed(7 downto 0);
signal sum: signed(31 downto 0);
begin
--    weight_reg: signed_reg port map(load => weight_ld, clk => clk, clr => clr, d => weight_in, q => weight);
    num_reg: signed_reg port map(load => '1', clk => clk, clr => clr, d => num_in, q => num);
    sum_reg: signed_reg generic map(N => 32) port map(load => '1', clk => clk, clr => clr, d => sum_in, q => sum);
--    weight_out <= weight;
    num_out <= num;
    sum_out <= sum + (num * to_signed(weight, num'length));
end Behavioral;
