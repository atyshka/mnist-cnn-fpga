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

entity pooling_row is
    generic (
        DELAY: integer := 0
    );
    port (
        clk, clr: in std_logic;
        num_in: in signed(7 downto 0);
        num_out: out signed(7 downto 0)
    );
end pooling_row;

architecture Behavioral of pooling_row is
component pool_shifter IS
    port (
        D : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        CLK : IN STD_LOGIC;
        CE : IN STD_LOGIC;
        SCLR : IN STD_LOGIC;
        Q : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
end component;
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

--signal frontend_load, backend_load : std_logic;
signal count: unsigned(1 downto 0);
signal val_1, val_2, val_4, val_5: signed (7 downto 0);
signal val_3: std_logic_vector(7 downto 0);
signal max: signed(7 downto 0) := x"00";

begin

reg_1: signed_reg port map(load => '1', clk => clk, clr => clr, d => num_in, q => val_1);
reg_2: signed_reg port map(load => '1', clk => clk, clr => clr, d => val_1, q => val_2);
shifter: pool_shifter port map(d => std_logic_vector(val_2), clk => clk, ce => '1', sclr => clr, q => val_3);
reg_3: signed_reg port map(load => '1', clk => clk, clr => clr, d => signed(val_3), q => val_4);
reg_4: signed_reg port map(load => '1', clk => clk, clr => clr, d => val_4, q => val_5);

process(clk, clr)
begin
    if (clr = '1') then
        count <= to_unsigned(4 - DELAY, count'length);
    elsif rising_edge(clk) then
        count <= count + 1;
    end if;
end process;

process(val_1, val_2, val_4, val_5)
variable max1, max2 : signed(7 downto 0);
begin
    if (val_1 > val_2) then
        max1 := val_1;
    else
        max1 := val_2;
    end if;
    if (val_4 > val_5) then
        max2 := val_4;
    else
        max2 := val_5;
    end if;
    if (max1 > max2) then
        max <= max1;
    else
        max <= max2;
    end if;
end process;

--frontend_load <= '1';
--backend_load <= count(1);
num_out <= max;

end Behavioral;
