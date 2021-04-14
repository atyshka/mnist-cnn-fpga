----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2021 04:36:36 PM
-- Design Name: 
-- Module Name: types - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

package types is
    type vector_8bit is array(natural range <>) of signed(7 downto 0);
    type vector_32bit is array(natural range <>) of signed(31 downto 0);
    type vector_int is array(natural range <>) of integer;
    type matrix_int is array(natural range <>) of vector_int(0 to 8);
end package;

