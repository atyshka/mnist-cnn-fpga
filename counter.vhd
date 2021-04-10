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

entity counter is
    Port ( mclk : in STD_LOGIC;
           clr : in STD_LOGIC;
           counter: out STD_LOGIC_VECTOR(9 downto 0));
end counter;

architecture Behavioral of counter is
signal count: STD_LOGIC_VECTOR(9 downto 0);
begin
process(mclk,clr)
begin
if clr = '1' then
count<=X"000000";
elsif mclk'event and mclk = '1' then
count<=count +1;
end if;
end process;
counter<=count;
end Behavioral;