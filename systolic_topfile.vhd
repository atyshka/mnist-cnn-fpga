library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.types.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity systolic_topfile is
    generic(H:integer := 12; W:integer := 9);
    port(
        mclk: in std_logic;
        clr: in std_logic;
        ld: out std_logic_vector(11 downto 0)
    );
end systolic_topfile;

architecture Behavioral of systolic_topfile is

component systolic_array is
    generic(H:integer := 12; W:integer := 9; BIASES:vector_int(0 to 11); SCALES:vector_int(0 to 11); WEIGHTS: matrix_int);
    port(
        clk: in std_logic;
        nums_in: in vector_8bit(W-1 downto 0);
        weight_in: in signed(7 downto 0);
        weight_addr: in unsigned(6 downto 0);
        weight_ld: in std_logic;
        clr: in std_logic;
        mac_out: out vector_8bit(H-1 downto 0)
    );
end component;
component inputManager is
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
end component;
component digitsROM is
  port (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
end component;

constant conv_bias: vector_int := (-22614, -1953, 8920, -5721, 1029, -4363, 20850, -3422, -10759, 6682, -2305, -7267);
constant conv_scaling: vector_int := (45930, 19517, 16497, 70983, 21671, 50430, 14097, 31750, 74862, 23211, 56295, 63894);
constant fc_bias: vector_int := (-1531955, -1195546, -665806, -884319, -1639927, -717025, -1235184 -1324942 -1195119 -1719265);
constant conv_weights: matrix_int :=
       ((  83,  104,   38,   26,    4,  -88, -110, -127, -108),
        ( 115,   88,  -92,  -34,  109,  -65,  -35,   41,  127),
        (  19,   69,  115,   79,  -69,   -4,   10,  -95,  127),
        (-127,  -29,   37,  -99,   35,   65,  -30,   59,   33),
        (-127,   68,  111,   96,   42,  -57,   71,    1,  -86),
        ( -16,   61,  -10,   57,   60, -112,   65,   25, -127),
        (  32,   90,   23,  -83,   70,   73,    8,  127,   27),
        (  17,    6,    8,   26,  102,  127,  -95, -115,  -63),
        (  13,   57,   76,   18,   34,   15, -127,  -96,  -95),
        ( -22,  -24,  -40,  -44,   62,  127,   53,   37,  -90),
        (  35,  -84, -127,   55,   25,  -42,   66,   70,   41),
        ( -24,   50,   45,  -97,   23,   67, -127,  -30,   17));

signal sums: vector_8bit(H-1 downto 0);
signal swint: signed(7 downto 0);
signal addrA, addrB, addrC, addrD : STD_LOGIC_VECTOR (9 downto 0);
signal dataA, dataB, dataC, dataD : STD_LOGIC_VECTOR (7 downto 0);
signal conv_input: vector_8bit(8 downto 0);

begin
r1: digitsROM port map(clka=>mclk,addra=>addrA,douta=> dataA);
r2: digitsROM port map(clka=>mclk,addra=>addrB,douta=> dataB);
r3: digitsROM port map(clka=>mclk,addra=>addrC,douta=> dataC);
r4: digitsROM port map(clka=>mclk,addra=>addrD,douta=> dataD);
input: inputmanager port map(clk => mclk, clr => clr, addrA => addrA, addrB => addrB, addrC => addrC, addrD => addrD,
                                dataA => dataA, dataB => dataB, dataC => dataC, dataD => dataD, numsOut => conv_input);
arr: systolic_array generic map(BIASES => conv_bias, SCALES => conv_scaling, WEIGHTS => conv_weights) 
                    port map(clk => mclk, nums_in => conv_input, weight_in => swint, 
                            weight_ld => '1', weight_addr => "0000000", clr => clr, mac_out => sums);
--swint <= signed(sw);
ld(0) <= sums(0)(7);
ld(1) <= sums(1)(7);
ld(2) <= sums(2)(7);
ld(3) <= sums(3)(7);
ld(4) <= sums(4)(7);
ld(5) <= sums(5)(7);
ld(6) <= sums(6)(7);
ld(7) <= sums(7)(7);
ld(8) <= sums(8)(7);
ld(9) <= sums(9)(7);
ld(10) <= sums(10)(7);
ld(11) <= sums(11)(7);

end Behavioral;