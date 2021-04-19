-- Example 37a: vga_bsprite
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_bsprite2a is
    port ( vidon: in std_logic;
           done: in std_logic;
           hc : in std_logic_vector(9 downto 0);
           vc : in std_logic_vector(9 downto 0);
           ROMdata: in std_logic_vector(7 downto 0);
           ROMad: out std_logic_vector(7 downto 0);
           red : out std_logic_vector(3 downto 0);
           green : out std_logic_vector(3 downto 0);
           blue : out std_logic_vector(3 downto 0)
           );           
end vga_bsprite2a;
architecture vga_bsprite2a of vga_bsprite2a is 
constant hbp: std_logic_vector(9 downto 0) := "0010010000";	 
	--Horizontal back porch = 144 (128+16)
constant vbp: std_logic_vector(9 downto 0) := "0000011111";	 
	--Vertical back porch = 31 (2+29)
constant w: integer := 28;
constant h: integer := 28;
signal xpix, ypix: std_logic_vector(4 downto 0);			
signal rom_addr : std_logic_vector(16 downto 0);
signal C1, R1: std_logic_vector(9 downto 0);				
signal spriteon, R, G, B: std_logic;
begin
	--set C1 and R1 using switches
	C1 <= '0'  & "000000001";
	R1 <= '0'  & "000000001";
	ypix <= vc - vbp - R1;
	xpix <= hc - hbp - C1;
	
	--Enable sprite video out when within the sprite region
 	spriteon <= '1' when (((hc > C1 + hbp) and (hc <= C1 + hbp + w))
           and ((vc >= R1 + vbp) and (vc < R1 + vbp + h))) else '0'; 
	process(xpix, ypix)
	variable  rom_addr1, rom_addr2: STD_LOGIC_VECTOR (9 downto 0);
	begin 
		rom_addr1 :=(ypix & "0000") + ('0' & ypix & "000") + ("00" & ypix & "00");	
           -- y*(16+8+4) = y*(28)
		rom_addr2 := rom_addr1 + ("000" & xpix); -- y*240+x
		if (done='1') then
		ROMad <= rom_addr2(7 downto 0);
		end if;
	end process;
	process(spriteon, vidon, ROMdata)
  		variable j: integer;
 	begin
		red <= "0000";
		green <= "0000";
		blue <= "0000";
		if spriteon = '1' and vidon = '1' then
    			red <= not ROMdata(7) & ROMdata(5) & ROMdata(3) & ROMdata(1);
    			green <= not ROMdata(7) & ROMdata(5) & ROMdata(3) & ROMdata(1);
    			blue <= not ROMdata(7) & ROMdata(5) & ROMdata(3) & ROMdata(1);
		end if;
  	end process; 
					
   end vga_bsprite2a;
