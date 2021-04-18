----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/05/2021 05:40:42 PM
-- Design Name: 
-- Module Name: pooling_unit - Behavioral
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

entity pooling_unit is
    port ( 
        clk, clr, active: in std_logic;
        nums: in vector_8bit(11 downto 0);
        fifo_write: out std_logic;
        pooled: out vector_8bit(11 downto 0)
    );
end pooling_unit;

architecture Behavioral of pooling_unit is
component pooling_row is
    generic (
        DELAY: integer := 0
    );
    port (
        clk, clr: in std_logic;
        num_in: in signed(7 downto 0);
        num_out: out signed(7 downto 0)
    );
end component;

signal total_count, row_count: unsigned(19 downto 0);
begin

gen_rows: for i in 0 to 11 generate
    row: pooling_row generic map(DELAY=>11-i) port map(clk => clk, clr => clr, num_in => nums(i), num_out => pooled(i));
end generate;

count_proc: process(clk, clr)
begin
    if clr = '1' then
        total_count <= (others => '0');
        row_count <= (others => '0');
    elsif clk'event and clk = '1' then
        total_count <= total_count + 1;
        if row_count = 51 then
            row_count <= (others => '0');
        elsif total_count > 24 then
            row_count <= row_count + 1;
        end if;
    end if;
end process;

fifo_write <= '1' when row_count(0) = '1' and row_count > 25 and total_count < 701 else '0';

end Behavioral;
