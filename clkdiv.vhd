----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/15/2020 03:52:30 PM
-- Design Name: 
-- Module Name: clkdiv - Behavioral
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
use IEEE.STD_LOGIC_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clkdiv is
    Port ( mclk : in STD_LOGIC;
           clr : in STD_LOGIC;
           clk25 : out STD_LOGIC);
end clkdiv;

architecture Behavioral of clkdiv is
    signal q: STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    begin
        process(mclk,clr)
        begin
            if clr = '1' then
                q<=X"000000";
            elsif mclk'event and mclk = '1' then
                q<=q +1;
            end if;
        end process;
    clk25<=q(1);
end Behavioral;
