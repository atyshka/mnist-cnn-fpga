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


entity input_sim is
--  Port ( );
end input_sim;

architecture behavior of input_sim is

component inputManager is
    Port ( addrA : out STD_LOGIC_VECTOR (9 downto 0);
           addrB : out STD_LOGIC_VECTOR (9 downto 0);
           addrC : out STD_LOGIC_VECTOR (9 downto 0);     
           addrD : out STD_LOGIC_VECTOR (9 downto 0);
           
           --numsOut: out vector_8bit(8 downto 0);
           clr,clk: in STD_LOGIC
           );
end component;

component counter is
    Port ( mclk : in STD_LOGIC;
           clr : in STD_LOGIC;
           counter: out STD_LOGIC_VECTOR(9 downto 0));
end component;
 
--signal timerA, timerB, timerC, timerD: STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
signal aA, aB, aC, aD, count: STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
signal mclk, clr : STD_LOGIC := '0';   

constant T: time:= 10 ns;
constant DC: real:= 0.5;
begin
    c: counter port map(mclk => mclk, clr => clr, counter=>count);
    i: inputManager port map(addrA=>aA,addrB=>aB,addrC=>aC,addrD=>aD,clk=>mclk,clr=>clr);
    
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
