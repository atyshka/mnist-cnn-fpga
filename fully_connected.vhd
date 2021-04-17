----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/06/2021 04:18:51 PM
-- Design Name: 
-- Module Name: fully_connected - Behavioral
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
use work.types.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fully_connected is
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
end fully_connected;

architecture Behavioral of fully_connected is
component signed_reg is
	 generic(N:integer := 8; DEFAULT:integer := 0);
	 port(
		 load : in STD_LOGIC;
		 clk : in STD_LOGIC;
		 clr : in STD_LOGIC;
		 d : in SIGNED(N-1 downto 0);
		 q : out SIGNED(N-1 downto 0)
     );
end component;
component delay_reg is
    generic (DELAY: integer := 1);
    port(
        clk, clr: in std_logic;
        num_in: in signed(7 downto 0);
        num_out: out signed(7 downto 0)
    );
end component;

type fc_state is (waiting, active, finishing, finished);
signal state: fc_state := waiting;
signal index, next_index: integer range 0 to 11 := 0;
signal count: integer range 0 to 2028 := 0;
signal input, input_delayed: signed(7 downto 0);
signal read, input_select : std_logic := '0';
signal weights_signed, weights_diagonalized : vector_8bit(9 downto 0);
signal input_chain: vector_8bit(10 downto 0);
signal accumulated, new_accumulate: vector_32bit(9 downto 0);
signal finish_count: unsigned(3 downto 0);

begin
count_proc: process(clk, clr)
begin
    if clr = '1' then
        index <= 0;
        next_index <= 0;
        state <= waiting;
    elsif clk'event and clk = '1' then
        read <= '0';
        input_select <= '0';
        if (state = finishing or state = finished) then
            input_select <= '1';
        end if;
        if (fifo_empty = '0' and state = waiting) then
            state <= active;
            read <= '1';
        elsif (state = active and next_index /= 11) then
            next_index <= next_index + 1;
            count <= count + 1;
        elsif (next_index = 11 and fifo_empty = '0') then
            next_index <= 0;
            count <= count + 1;
            read <= '1';
        else
            if state = active then
                state <= finishing;
                finish_count <= x"0";
            elsif state = finishing and finish_count /= 11 then
                finish_count <= finish_count + 1;
            elsif state = finishing and finish_count = 11 then
                state <= finished;
            end if;
        end if;
        index <= next_index;
    end if;
end process;

max_proc: process(accumulated)
variable max: vector_32bit(8 downto 0);
variable idx: vector_int(8 downto 0);
begin
    gen_max: for i in 0 to 4 loop
        if (accumulated(2*i) > accumulated(2*i+1)) then
            max(i) := accumulated(2*i);
            idx(i) := 2*i;
        else
            max(i) := accumulated(2*i+1);
            idx(i) := 2*i+1;
        end if;
    end loop;
    if (max(0) > max(1)) then
        max(5) := max(0);
        idx(5) := idx(0);
    else
        max(5) := max(1);
        idx(5) := idx(1);
    end if;
    if (max(2) > max(3)) then
        max(6) := max(2);
        idx(6) := idx(2);
    else
        max(6) := max(3);
        idx(6) := idx(3);
    end if;
    if (max(4) > max(5)) then
        max(7) := max(4);
        idx(7) := idx(4);
    else
        max(7) := max(5);
        idx(7) := idx(5);
    end if;
    if (max(6) > max(7)) then
        max(8) := max(6);
        idx(8) := idx(6);
    else
        max(8) := max(7);
        idx(8) := idx(7);
    end if;
    output <= to_unsigned(idx(8), output'length);
end process;

input_delay: signed_reg port map(clk => clk, clr => clr, load => '1', d => input, q => input_delayed);

gen_weight_signals: for i in 0 to 9 generate
    weights_signed(i) <= signed(weights(79 - i*8 downto 72 - i*8));
    delay: delay_reg generic map(DELAY => i) port map(clk => clk, clr => clr, num_in => weights_signed(i), num_out => weights_diagonalized(i));
    input_regs: signed_reg port map(clk => clk, clr => clr, load => '1', d => input_chain(i), q => input_chain(i+1));
    accumulators: signed_reg generic map(N => 32, DEFAULT => BIASES(i)) port map(clk => clk, clr => clr, load => '1', d => new_accumulate(i), q => accumulated(i));
    new_accumulate(i) <= accumulated(i) + (weights_diagonalized(i) * input_chain(i));
end generate;

input <= nums(index) when input_select = '0' else x"00";
input_chain(0) <= input_delayed;
fifo_read <= read;
weight_addr <= std_logic_vector(to_unsigned(count, weight_addr'length));
done <= '1' when state=finished else '0';
end Behavioral;
