----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/10/2021 01:31:07 PM
-- Design Name: 
-- Module Name: delay_reg - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.types.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity delay_reg is
    generic (DELAY: integer := 1);
    port(
        clk, clr: in std_logic;
        num_in: in signed(7 downto 0);
        num_out: out signed(7 downto 0)
    );
end delay_reg;

architecture Behavioral of delay_reg is
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

signal num_array: vector_8bit(DELAY downto 0);

begin
gen_regs: for i in 0 to DELAY-1 generate
    reg_i: signed_reg port map(load => '1', clk => clk, clr => clr, d => num_array(i), q => num_array(i+1)); 
end generate;

num_array(0) <= num_in;
num_out <= num_array(DELAY);

end Behavioral;
