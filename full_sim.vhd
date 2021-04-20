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
    port(
        mclk: in std_logic;
        btn: in std_logic_vector(2 downto 0);
        a_to_g: out std_logic_vector(6 downto 0);
        an: out std_logic_vector(7 downto 0);
        dp, hsync_out, vsync_out: out std_logic;
        ld, red, green, blue: out std_logic_vector(3 downto 0)
    );
end component;
 
signal mclk, hsync_out,vsync_out : STD_LOGIC := '0'; 
signal rgb: std_logic_vector(11 downto 0); 
signal ld: std_logic_vector(3 downto 0); 
signal btn: std_logic_vector(2 downto 0);             
--signal num_in, num_out : vector_8bit(11 downto 0) := (others => x"00");

constant T: time:= 10 ns;
constant DC: real:= 0.5;
begin
    uut: systolic_topfile port map(mclk => mclk, btn => btn, hsync_out=>hsync_out, vsync_out=>vsync_out,ld=>ld);
    
    clock_process: process
    begin
        mclk <= '0'; 
        wait for (T - T*DC);
        mclk <= '1'; 
        wait for T * DC;
    end process;
    
    stim_process: process
    begin	
        btn <= "010";
        wait for 20ns;
        btn <= "000";
        wait for 25000ns;
        btn <= "010";
        wait for 20ns;
        btn <= "000";
        wait;
   end process;

end behavior;
