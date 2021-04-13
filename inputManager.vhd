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
use IEEE.NUMERIC_STD.ALL;

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
           
           dataA : in STD_LOGIC_VECTOR (7 downto 0);
           dataB : in STD_LOGIC_VECTOR (7 downto 0);
           dataC : in STD_LOGIC_VECTOR (7 downto 0);     
           dataD : in STD_LOGIC_VECTOR (7 downto 0);
           
           numsOut: out vector_8bit(8 downto 0);
           
           clr, clk: in STD_LOGIC
           );
end inputManager;

architecture Behavioral of inputManager is


signal timerA,timerB, timerC, timerD, count: STD_LOGIC_VECTOR(9 downto 0) :=(others => '0');
signal aA, aB, aC, aD: STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
signal msel: STD_LOGIC_VECTOR(5 downto 0):=(others => '0');

begin

process(clk,clr)
variable newCount: STD_LOGIC_VECTOR (9 downto 0) := "0000000000";
begin
if clr = '1' then
    count<="0000000000";

    timerA<="0000000000";
    timerB<="0000000000";
    timerC<="0000000000";
    
    aA<="0000000000";
    aB<="0000000000";
    aC<="0000000000";
    aD<="0000000000";
elsif clk'event and clk = '1' then
    newCount:=Count+1;
    timerA<=timerA+1;
    timerB<=timerB+1;
    timerC<=timerC+1;
    
    if (timerA<25) then
        aA <= aA+1;
        msel(5 downto 4) <="00";
    elsif (timerA=25) then
        aA<=aA+1;
        aD<=aA+3;
        
    elsif (timerA=26) then
        aA<=aA+1;
        aD<=aA+3;
        msel(5 downto 4) <="10";
    elsif (timerA=27) then
        aA<=aA+3;
        timerA<="0000000001";
        msel(5 downto 4) <="11";
    end if;
    
    
    if (timerB<25) then
        aB <= aB+1;
        msel(3 downto 2) <="00";
    elsif (timerB=25) then
        aB<=aB+1;
        aD<=aB+3;
        
    elsif (timerB=26) then
        aB<=aB+1;
        aD<=aB+3;
        msel(3 downto 2) <="10";
    elsif (timerB=27) then
        aB<=aB+3;
        timerB<="0000000001";
        msel(3 downto 2) <="11";
    end if;
    
    
    if (timerC<25) then
        aC <= aC+1;
       msel(1 downto 0) <="00";
    elsif (timerC=25) then
        aC<=aC+1;
        aD<=aC+3;
        
    elsif (timerC=26) then
        aC<=aC+1;
        aD<=aC+3;
        msel(1 downto 0) <="10";
    elsif (timerC=27) then
        aC<=aC+3;
        timerC<="0000000001";
        msel(1 downto 0) <="11";
    end if;
    if (newCount=3) then
        timerB<="0000000000";
        aB<="0000001100";
    end if;
    if (newCount=6) then
        timerC<="0000000000";
        aC<="0000011000";
    end if; 
    count<=newCount;
end if;   
end process;

process(clk,clr)
begin

end process;

numsOut(0) <= signed(dataA) when msel(5)='0' else signed(dataD);
numsOut(1) <= signed(dataA) when msel(4)='0' else signed(dataD);
numsOut(2) <= signed(dataA);

numsOut(3) <= signed(dataB) when msel(3)='0' else signed(dataD);
numsOut(4) <= signed(dataB) when msel(2)='0' else signed(dataD);
numsOut(5) <= signed(dataB);

numsOut(6) <= signed(dataC) when msel(1)='0' else signed(dataD);
numsOut(7) <= signed(dataC) when msel(0)='0' else signed(dataD);
numsOut(8) <= signed(dataC);

addrA<=aA;
addrB<=aB;
addrC<=aC;
addrD<=aD;

end Behavioral;
