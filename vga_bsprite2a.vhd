-- Example 37a: vga_bsprite2a
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity vga_bsprite2a is
    port ( vidon, done: in std_logic;
           hc : in std_logic_vector(9 downto 0);
           vc : in std_logic_vector(9 downto 0);
           dataROM: in std_logic_vector(7 downto 0);
           rom_addr16: out std_logic_vector(12 downto 0);
          counter : in std_logic_vector(3 downto 0);
           red, green, blue : out std_logic_vector(3 downto 0)
	);
end vga_bsprite2a;
architecture vga_bsprite2a of vga_bsprite2a is 
constant hbp: std_logic_vector(9 downto 0) := "0010010000";	 
	--Horizontal back porch = 144 (128+16)
constant vbp: std_logic_vector(9 downto 0) := "0000011111";	 
	--Vertical back porch = 31 (2+29)
constant w: integer := 28;
constant h: integer := 28;
signal xpix, ypix: std_logic_vector(9 downto 0);			
signal rom_addr : std_logic_vector(9 downto 0);
signal C1, R1: std_logic_vector(9 downto 0);				
signal spriteon, R, G, B: std_logic;
begin
	--set C1 and R1 using switches
	C1 <= '0' & "0000" & "00001";
	R1 <= '0' & "0000" & "00001";
	ypix <= vc - vbp - R1;
	xpix <= hc - hbp - C1;
	
	--Enable sprite video out when within the sprite region
 	spriteon <= '1' when (((hc > C1 + hbp) and (hc <= C1 + hbp + w))
           and ((vc >= R1 + vbp) and (vc < R1 + vbp + h))) else '0'; 
	process(xpix, ypix)
	variable  rom_addr1, rom_addr2: STD_LOGIC_VECTOR (9 downto 0);
	variable  rom_addr3: STD_LOGIC_VECTOR (12 downto 0);
	begin 
		rom_addr1 := ('0' & ypix(4 downto 0) & "0000") + ("00" & ypix(4 downto 0) & "000") + ("000" & ypix(4 downto 0) & "00");	
           -- y*(16+8+4) = y*28
		rom_addr2 := rom_addr1 + ("00000" & xpix(4 downto 0)); -- y*28+x
		rom_addr3 := ("0000"&rom_addr2) + ("00000" & counter & "0000") + ('0' & counter & "00000000") + (counter & "000000000");
		-- y*() = y*28
		rom_addr16 <= rom_addr3;
	end process;
	process(spriteon, vidon, dataROM, done)
 	begin
		red <= "0000";
		green <= "0000";
		blue <= "0000";
		if spriteon = '1' and vidon = '1' and done = '1' then
    			red <= (not dataROM(7)) & dataROM(6) & dataROM(5) & dataROM(4);
    			green <= (not dataROM(7)) & dataROM(6) & dataROM(5) & dataROM(4);
    			blue <= (not dataROM(7)) & dataROM(6) & dataROM(5) & dataROM(4);
		end if;
  	end process; 
					
   end vga_bsprite2a;
