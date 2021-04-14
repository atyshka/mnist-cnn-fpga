library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.types.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity full_sim is
--  Port ( );
end full_sim;

architecture behavior of full_sim is

component systolic_topfile is
    generic(H:integer := 12; W:integer := 9);
    port(
        mclk: in std_logic;
        clr: in std_logic;
        ld: out std_logic_vector(11 downto 0)
    );
end component;
 
signal mclk, clr : STD_LOGIC := '0';               
--signal num_in, num_out : vector_8bit(11 downto 0) := (others => x"00");

constant T: time:= 10 ns;
constant DC: real:= 0.5;
begin
    uut: systolic_topfile port map(mclk => mclk, clr => clr);
    
    clock_process: process
    begin
        mclk <= '0'; 
        wait for (T - T*DC);
        mclk <= '1'; 
        wait for T * DC;
    end process;
    
    stim_process: process
    begin	
        clr <= '1';
        wait for 20ns;
        clr <= '0';
        wait;
   end process;

end behavior;