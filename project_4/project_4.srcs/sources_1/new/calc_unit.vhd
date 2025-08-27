library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity calc_unit is
    port (
        clk       : in  std_logic;                         -- system clock
        key_code  : in  std_logic_vector(3 downto 0);      -- from keypad decoder
        disp_code : out std_logic_vector(3 downto 0)       -- to seg7_control
    );
end calc_unit;

architecture rtl of calc_unit is
    -- ------------------------------------------------------------
    --  FSM types
    -- ------------------------------------------------------------
    type op_t     is (NOP, ADD, SUB, MUL, DIVI);
    type state_t  is (S_A, S_OP, S_B, S_RES);

    signal state  : state_t              := S_A;
    signal oper   : op_t                 := NOP;

    signal a_val  : unsigned(3 downto 0) := (others=>'0');
    signal b_val  : unsigned(3 downto 0) := (others=>'0');
    signal result : unsigned(3 downto 0) := (others=>'0');

    -- edge detector so each key press is counted once
    signal last_key : std_logic_vector(3 downto 0) := (others=>'0');
    signal key_stb  : std_logic                    := '0';
begin
    ----------------------------------------------------------------
    --  MAIN PROCESS : key handling & arithmetic
    ----------------------------------------------------------------
    process(clk)
        variable tmp : unsigned(3 downto 0);
    begin
        if rising_edge(clk) then
            -- key-change strobe
            if key_code /= last_key then
                key_stb  <= '1';
                last_key <= key_code;
            else
                key_stb  <= '0';
            end if;

            if key_stb = '1' then
                ----------------------------------------------------
                -- 0-9  ? digit entry
                ----------------------------------------------------
                if key_code <= "1001" then
                    case state is
                        when S_A | S_RES =>
                            a_val <= unsigned(key_code);
                            state <= S_OP;

                        when S_OP | S_B =>
                            b_val <= unsigned(key_code);
                            state <= S_B;
                    end case;

                ----------------------------------------------------
                -- A/B/C/D  ?  + / - / × / ÷
                ----------------------------------------------------
                elsif key_code = "1010" or key_code = "1011"
                   or key_code = "1100" or key_code = "1101" then
                    case key_code is
                        when "1010" => oper <= ADD;   -- A
                        when "1011" => oper <= SUB;   -- B
                        when "1100" => oper <= MUL;   -- C
                        when others => oper <= DIVI;  -- D
                    end case;
                    state <= S_B;

                ----------------------------------------------------
                -- E  ?  '='   evaluate
                ----------------------------------------------------
                elsif key_code = "1110" then                     -- E
                    if state = S_B then
                        case oper is
                            when ADD  =>
                                tmp := a_val + b_val;                 -- still 4 bits
                            when SUB  =>
                                tmp := a_val - b_val;                 -- wraps unsigned
                            when MUL  =>
                                tmp := resize(a_val * b_val, 4);      -- truncate to 4
                            when DIVI =>
                                if b_val = 0 then
                                    tmp := "1111";                    -- show 'F'
                                else
                                    tmp := a_val / b_val;             -- 4 bits
                                end if;
                            when others =>
                                tmp := a_val;
                        end case;

                        result <= tmp;
                        a_val  <= tmp;        -- chain next calculation
                        state  <= S_RES;
                    end if;

                ----------------------------------------------------
                -- F  ?  clear / reset
                ----------------------------------------------------
                elsif key_code = "1111" then                     -- F
                    a_val  <= (others=>'0');
                    b_val  <= (others=>'0');
                    result <= (others=>'0');
                    oper   <= NOP;
                    state  <= S_A;
                end if;
            end if; -- key_stb
        end if;     -- rising_edge
    end process;

    ----------------------------------------------------------------
    --  Selected value ? display driver
    ----------------------------------------------------------------
    with state select
        disp_code <= std_logic_vector(a_val)   when S_A,
                      std_logic_vector(a_val)   when S_OP,
                      std_logic_vector(b_val)   when S_B,
                      std_logic_vector(result)  when others;  -- S_RES
end rtl;

