----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/19/2021 05:52:21 PM
-- Design Name: 
-- Module Name: IOState - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IOState is
    port (
            btnLeft, btnRight, btnClr, clk: in std_logic;
            imageCounter: out std_logic_vector(3 downto 0);
            clr: out std_logic
        );
end IOState;

architecture Behavioral of IOState is

type fc_state is (active, clear, left, right);
signal state: fc_state := clear;
signal imageCount: std_logic_vector(3 downto 0) := "0000";
begin
count_proc: process(clk, btnClr, btnLeft, btnRight)
begin
    if btnClr = '1' then
      state <= clear;
    elsif btnLeft = '1' then
      state <= left;
    elsif btnRight = '1' then
      state <= right;
    elsif clk'event and clk = '1' then
        if (state = active) then
       
        elsif (state = left) then
        state <= clear;
            if(imageCount="0000")then
                imageCount<=imageCount-'1';
            else
                imageCount<="1001";
            end if;
        elsif (state = right) then
            if(imageCount="1001")then
                    imageCount<=imageCount+'1';
                else
                    imageCount<="0000";
                end if;
        state <= clear;
        elsif (state = clear) then
            state <= active;
            clr <= '1';
        end if;
    end if;
end process;

imageCounter<=imageCount;

end Behavioral;
