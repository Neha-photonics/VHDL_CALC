library IEEE;
use IEEE.std_logic_1164.all;

entity top is
    port (
        clk_100MHz : in  std_logic;
        rows       : in  std_logic_vector(3 downto 0);  -- JB10..JB7
        cols       : out std_logic_vector(3 downto 0);  -- JB4..JB1
        an         : out std_logic_vector(3 downto 0);
        seg        : out std_logic_vector(6 downto 0)
    );
end top;

architecture rtl of top is
    signal rows_fix  : std_logic_vector(3 downto 0);
    signal key_code  : std_logic_vector(3 downto 0);
    signal disp_code : std_logic_vector(3 downto 0);
begin
    ----------------------------------------------------------------
    -- Row-bit re-order: JB10?bit3 … JB7?bit0
    ----------------------------------------------------------------
    rows_fix <= rows(0) & rows(1) & rows(2) & rows(3);

    ----------------------------------------------------------------
    -- Keypad scanner (unchanged module from earlier steps)
    ----------------------------------------------------------------
    scanner : entity work.decoder
        port map (
            clk_100MHz => clk_100MHz,
            row        => rows_fix,
            col        => cols,
            dec_out    => key_code
        );

    ----------------------------------------------------------------
    -- Single-nibble calculator
    ----------------------------------------------------------------
    calc : entity work.calc_unit
        port map (
            clk       => clk_100MHz,
            key_code  => key_code,
            disp_code => disp_code
        );

    ----------------------------------------------------------------
    -- 7-segment driver (unchanged)
    ----------------------------------------------------------------
    sevenseg : entity work.seg7_control
        port map (
            dec => disp_code,
            an  => an,
            seg => seg
        );
end rtl;
