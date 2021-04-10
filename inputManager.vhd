----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/10/2021 11:36:21 AM
-- Design Name: 
-- Module Name: inputManager - Behavioral
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
use IEEE.STD_LOGIC_unsigned.ALL;
use work.types.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
--a <= b when sel_b=1 else c;
entity inputManager is
    Port ( 
           addrA : out STD_LOGIC_VECTOR (9 downto 0);
           addrB : out STD_LOGIC_VECTOR (9 downto 0);
           addrC : out STD_LOGIC_VECTOR (9 downto 0);     
           addrD : out STD_LOGIC_VECTOR (9 downto 0);
           count : in STD_LOGIC_VECTOR (9 downto 0);
           --numsOut: out vector_8bit(8 downto 0);
           
           clr: in STD_LOGIC
           );
end inputManager;

architecture Behavioral of inputManager is


signal timerA,timerB, timerC, timerD: STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
signal aA, aB, aC, aD: STD_LOGIC_VECTOR(9 downto 0):=(others => '0');

begin



process(count)
begin
timerA<=timerA+1;
timerB<=timerB+1;
timerC<=timerC+1;
    if (timerA<9) then
        aA <= aA+1;
       
    elsif (timerA=9) then
        aA<=aA+1;
        aD<=aA+3;
        
    elsif (timerA=10) then
        aA<=aA+1;
        aD<=aA+3;
        
    elsif (timerA=11) then
        aA<=aA+3;
        timerA<="0000000001";
    end if;
    
    
    
        if (timerB<9) then
        aB <= aB+1;
       
    elsif (timerB=9) then
        aB<=aB+1;
        aD<=aB+3;
        
    elsif (timerB=10) then
        aB<=aB+1;
        aD<=aB+3;
        
    elsif (timerB=11) then
        aB<=aB+3;
        timerB<="0000000001";
    end if;
   
   
   
       if (timerC<9) then
        aA <= aA+1;
       
    elsif (timerC=9) then
        aC<=aC+1;
        aD<=aC+3;
        
    elsif (timerC=10) then
        aC<=aC+1;
        aD<=aC+3;
        
    elsif (timerC=11) then
        aC<=aC+3;
        timerC<="0000000001";
    end if;
    
    
    if (Count=0) then
        timerA<="0000000000";
        aA<="0000000000";
    end if;
    if (Count=3) then
        timerB<="0000000000";
        aB<="0000001100";
    end if;
    if (Count=6) then
        timerC<="0000000000";
        aC<="0000011000";
    end if;    
end process;



end Behavioral;
