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
        btnLeft, btnRight, btnClr: in std_logic;
        mclk: in std_logic;
        clr: in std_logic;
        a_to_g: out std_logic_vector(6 downto 0);
        an: out std_logic_vector(7 downto 0);
        dp, vidon_out, hsync_out, vsync_out: out std_logic;
        ld, red, green, blue: out std_logic_vector(3 downto 0)
    );
end systolic_topfile;

architecture Behavioral of systolic_topfile is

component systolic_array is
    generic(H:integer := 12; W:integer := 9; BIASES:vector_int(0 to 11); SCALES:vector_int(0 to 11); WEIGHTS: matrix_int);
    port(
        clk: in std_logic;
        nums_in: in vector_8bit(W-1 downto 0);
        clr: in std_logic;
        mac_out: out vector_8bit(H-1 downto 0)
    );
end component;
component inputManager is
    Port ( 
           addrA : out STD_LOGIC_VECTOR (12 downto 0);
           addrB : out STD_LOGIC_VECTOR (12 downto 0);
           addrC : out STD_LOGIC_VECTOR (12 downto 0);     
           addrD : out STD_LOGIC_VECTOR (12 downto 0);
           
           ImageCount: in STD_LOGIC_VECTOR (3 downto 0);
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
component digitsDualROM is
  port (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    clkb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
end component;
component IOState is
    port (
            btnLeft, btnRight, btnClr, clk: in std_logic;
            imageCounter: out std_logic_vector(3 downto 0);
            clr: out std_logic
        );
end component;
component pooling_unit is
    port ( 
        clk, clr, active: in std_logic;
        nums: in vector_8bit(11 downto 0);
        fifo_write: out std_logic;
        pooled: out vector_8bit(11 downto 0)
    );
end component;
component vga_640x480 is
	port (
		clk, clr : in std_logic;
		hsync, vsync : out std_logic;
		hc, vc : out std_logic_vector(9 downto 0);
		vidon : out std_logic
		);
end component;
component fully_connected_fifo is
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(95 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(95 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
end component;
component x7segb8 is
	 port(
		 x : in STD_LOGIC_VECTOR(31 downto 0);
		 clk : in STD_LOGIC;
		 clr : in STD_LOGIC;
		 a_to_g : out STD_LOGIC_VECTOR(6 downto 0);
		 an : out STD_LOGIC_VECTOR(7 downto 0);
		 dp : out STD_LOGIC
	     );
end component;
component fully_connected is
    generic (
        BIASES: vector_int
    );
    port (
        clk, clr: in std_logic;
        nums: in vector_8bit(11 downto 0);
        weights: in std_logic_vector(79 downto 0);
        fifo_empty: in std_logic;
        fifo_read: out std_logic;
        weight_addr: out std_logic_vector(10 downto 0);
        output: out unsigned(3 downto 0);
        done: out std_logic
    );
end component;
component vga_bsprite2a is
        port ( vidon, done: in std_logic;
           hc : in std_logic_vector(9 downto 0);
           vc : in std_logic_vector(9 downto 0);
           dataROM: in std_logic_vector(7 downto 0);
           rom_addr16: out std_logic_vector(12 downto 0);
          counter : in std_logic_vector(3 downto 0);
           red, green, blue : out std_logic_vector(3 downto 0)
	);
end component;
component fc_weight_rom is
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(79 DOWNTO 0)
  );
end component;

constant conv_bias: vector_int := 
        (-22614, -1953, 8920, -5721, 1029, -4363, 20850, -3422, -10759, 6682, -2305, -7267);
constant conv_scaling: vector_int := 
        (45930, 19517, 16497, 70983, 21671, 50430, 14097, 31750, 74862, 23211, 56295, 63894);
constant fc_bias: vector_int := 
        (-1531955, -1195546, -665806, -884319, -1639927, -717025, -1235184, -1324942, -1195119, -1719265);
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

signal conv_out, pooled_out, fc_in: vector_8bit(H-1 downto 0);
signal fifo_input, fifo_output: std_logic_vector(95 downto 0);
signal fc_weights_raw: std_logic_vector(79 downto 0);
signal fc_weight_addr: std_logic_vector(10 downto 0);
--signal swint: signed(7 downto 0);
signal addrAInput, addrADisplay, addrA, addrB, addrC, addrD : STD_LOGIC_VECTOR (12 downto 0);
signal dataA, dataB, dataC, dataD : STD_LOGIC_VECTOR (7 downto 0);
signal CNNAnswer : STD_LOGIC_VECTOR (31 downto 0);
signal conv_input: vector_8bit(8 downto 0);
signal fifo_write, fifo_read, empty : std_logic;
signal result: unsigned(3 downto 0);

signal hsync, vsync, vidon, done, clr2: std_logic;
signal hc, vc: std_logic_vector (9 downto 0);
signal counter: std_logic_vector (3 downto 0);


begin
--r1: digitsROM port map(clka=>mclk,addra=>addrA,douta=> dataA);
--r2: digitsROM port map(clka=>mclk,addra=>addrB,douta=> dataB);
--r3: digitsROM port map(clka=>mclk,addra=>addrC,douta=> dataC);
--r4: digitsROM port map(clka=>mclk,addra=>addrD,douta=> dataD);

r12: digitsDualROM port map(clka=>mclk,clkb=>mclk, addra=>addrA, addrb=>addrB, douta=> dataA, doutb=>dataB);
r34: digitsDualROM port map(clka=>mclk,clkb=>mclk, addra=>addrC, addrb=>addrD, douta=> dataC, doutb=>dataD);

input: inputmanager port map(clk => mclk, clr => clr, addrA => addrAInput, addrB => addrB, addrC => addrC, addrD => addrD,
                                dataA => dataA, dataB => dataB, dataC => dataC, dataD => dataD, numsOut => conv_input, ImageCount => counter);
arr: systolic_array generic map(BIASES => conv_bias, SCALES => conv_scaling, WEIGHTS => conv_weights) 
                    port map(clk => mclk, nums_in => conv_input, clr => clr, mac_out => conv_out);
pool: pooling_unit port map(clk => mclk, clr => clr, active => '1', nums => conv_out, pooled => pooled_out, fifo_write => fifo_write);
fifo: fully_connected_fifo port map(clk => mclk, srst => clr, din => fifo_input, wr_en => fifo_write,
                                    rd_en => fifo_read, dout => fifo_output, empty => empty);
fc: fully_connected generic map(BIASES => fc_bias) port map(clk => mclk, clr => clr, nums => fc_in, fifo_empty => empty, weights => fc_weights_raw,
                                                             weight_addr => fc_weight_addr, fifo_read => fifo_read, output => result, done => done);
weight_rom: fc_weight_rom port map(clka => mclk, addra => fc_weight_addr, douta => fc_weights_raw);

sevSeg: x7segb8 port map (x => CNNAnswer, clk => mclk, clr => clr, a_to_g => a_to_g, an => an, dp => dp);

VGActrl: vga_640x480 port map (clk => mclk, clr => clr, hc => hc, vc => vc, hsync => hsync, vsync => vsync, vidon => vidon);

VGApic: vga_bsprite2a port map (vidon => vidon, done => done, hc => hc, vc => vc, dataROM => dataA, rom_addr16 => addrADisplay,counter=>counter,red => red, green => green, blue => blue);

ImageCounter: IOState port map (btnLeft=>btnLeft, btnRight=>btnRight, btnClr=>btnClr,clk=>mclk,ImageCounter=>counter, clr=>clr2);

gen_fifo_signals: for i in 0 to 11 generate
    fifo_input(i*8 + 7 downto i*8) <= std_logic_vector(pooled_out(i));
    fc_in(i) <= signed(fifo_output(i*8 + 7 downto i*8));
end generate;
ld <= std_logic_vector(result);
CNNAnswer<= X"0000000"& std_logic_vector(result);
hsync_out<=hsync;
vsync_out<=vsync;
vidon_out<=vidon;
addrA <= addrAInput when done='0' else addrADisplay;
--fifo_read <= '0';
--swint <= signed(sw);
--ld(0) <= sums(0)(7);
--ld(1) <= sums(1)(7);
--ld(2) <= sums(2)(7);
--ld(3) <= sums(3)(7);
--ld(4) <= sums(4)(7);
--ld(5) <= sums(5)(7);
--ld(6) <= sums(6)(7);
--ld(7) <= sums(7)(7);
--ld(8) <= sums(8)(7);
--ld(9) <= sums(9)(7);
--ld(10) <= sums(10)(7);
--ld(11) <= sums(11)(7);

end Behavioral;
