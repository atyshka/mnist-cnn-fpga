library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity pool_sim is
--  Port ( );
end pool_sim;

architecture behavior of pool_sim is

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
 
signal mclk, clr : STD_LOGIC := '0';               
signal num_in, num_out : signed(7 downto 0) := x"00";

constant T: time:= 10 ns;
constant DC: real:= 0.5;
begin
    uut: pooling_row generic map(DELAY => 0) port map(clk => mclk, clr => clr, num_in => num_in, num_out => num_out);
    
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
        wait for 15ns;	
        for i in 0 to 127 loop
            num_in <= to_signed(i, num_in'length);
            wait for 10ns;
        end loop;
        
        wait;
   end process;

end behavior;
