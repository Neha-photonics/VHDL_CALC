-- ===============================================================
-- 4 × 4 keypad decoder
-- Target clock 100 MHz
-- ===============================================================
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decoder is
    generic (
        LAG      : integer := 10;        -- extra delay ticks after column drive
        SCAN_MAX : integer := 99_999     -- 1 ms - 1 at 100 MHz
    );
    port (
        clk_100MHz : in  std_logic;                         -- system clock
        row        : in  std_logic_vector(3 downto 0);      -- keypad rows (active-low)
        col        : out std_logic_vector(3 downto 0);      -- keypad columns (active-low)
        dec_out    : out std_logic_vector(3 downto 0)       -- 4-bit code for key pressed
    );
end decoder;

architecture rtl of decoder is
    -- 20-bit timer counts 0 … 99 999
    signal scan_timer : integer range 0 to SCAN_MAX := 0;

    -- selects which of the four columns is driven low
    signal col_select : integer range 0 to 3 := 0;

    -- registered outputs
    signal col_reg  : std_logic_vector(3 downto 0) := (others => '1');
    signal dec_reg  : std_logic_vector(3 downto 0) := (others => '0');
begin
    ----------------------------------------------------------------
    -- drive outputs
    ----------------------------------------------------------------
    col     <= col_reg;
    dec_out <= dec_reg;

    ----------------------------------------------------------------
    -- main sequential process
    ----------------------------------------------------------------
    process (clk_100MHz)
    begin
        if rising_edge(clk_100MHz) then
            --------------------------------------------------------
            -- 1 ms scan-rate timer / column selector
            --------------------------------------------------------
            if scan_timer = SCAN_MAX then
                scan_timer <= 0;
                if col_select = 3 then
                    col_select <= 0;
                else
                    col_select <= col_select + 1;
                end if;
            else
                scan_timer <= scan_timer + 1;
            end if;

            --------------------------------------------------------
            -- column drive and key decoding
            --------------------------------------------------------
            case col_select is
                ----------------------------------------------------
                when 0 =>
                    col_reg <= "0111";                           -- drive column 0 low
                    if scan_timer = LAG then                     -- sample rows
                        case row is
                            when "0111" => dec_reg <= "0001";    -- 1
                            when "1011" => dec_reg <= "0100";    -- 4
                            when "1101" => dec_reg <= "0111";    -- 7
                            when "1110" => dec_reg <= "0000";    -- 0
                            when others => null;
                        end case;
                    end if;

                ----------------------------------------------------
                when 1 =>
                    col_reg <= "1011";
                    if scan_timer = LAG then
                        case row is
                            when "0111" => dec_reg <= "0010";    -- 2
                            when "1011" => dec_reg <= "0101";    -- 5
                            when "1101" => dec_reg <= "1000";    -- 8
                            when "1110" => dec_reg <= "1111";    -- F
                            when others => null;
                        end case;
                    end if;

                ----------------------------------------------------
                when 2 =>
                    col_reg <= "1101";
                    if scan_timer = LAG then
                        case row is
                            when "0111" => dec_reg <= "0011";    -- 3
                            when "1011" => dec_reg <= "0110";    -- 6
                            when "1101" => dec_reg <= "1001";    -- 9
                            when "1110" => dec_reg <= "1110";    -- E
                            when others => null;
                        end case;
                    end if;

                ----------------------------------------------------
                when others =>           -- col_select = 3
                    col_reg <= "1110";
                    if scan_timer = LAG then
                        case row is
                            when "0111" => dec_reg <= "1010";    -- A
                            when "1011" => dec_reg <= "1011";    -- B
                            when "1101" => dec_reg <= "1100";    -- C
                            when "1110" => dec_reg <= "1101";    -- D
                            when others => null;
                        end case;
                    end if;
            end case;
        end if;
    end process;
end rtl;
