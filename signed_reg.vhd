----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/26/2021 10:49:35 PM
-- Design Name: 
-- Module Name: signed_reg - Behavioral
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

entity signed_reg is
	 generic(N:integer := 8; DEFAULT:integer := 0);
	 port(
		 load : in STD_LOGIC;
		 clk : in STD_LOGIC;
		 clr : in STD_LOGIC;
		 d : in SIGNED(N-1 downto 0);
		 q : out SIGNED(N-1 downto 0)
	     );
end signed_reg;

architecture signed_reg of signed_reg is
begin
	process(clk, clr)
	begin
		if clr = '1' then
			q <= to_signed(DEFAULT, q'length);
		elsif clk'event and clk = '1' then
			if load = '1' then
				q <= d;
			end if;	
	end if;							 
	end process;
end signed_reg;
