library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.std_logic_unsigned.all;

entity MIPS_Processor_top is
Port ( SW : in STD_LOGIC_VECTOR (13 downto 0);  ---SW[7 downto 0]- data, SW[9]-reset, SW[8]-step mode
                                                --SW(10)lsb, SW(11), SW(12), SW(13)msb are mode 
       led_top : out STD_LOGIC_VECTOR( 11 downto 0 );   --led_top[0]-key ready, led_top[1]- data ready,led_top[2]- RF write data,  
                                                   --led_top[3]- Mem write data, led_top[4]- Branch addr, led_top[7 downto 5]-in_cnt
                                                   -- led_top(11 downto 10) - k_cnt
       BTNL: in STD_LOGIC;              -- Din push input
       BTND : in STD_LOGIC;             --push_output
       BTNU : in STD_LOGIC;             --key_vld  
       BTNC: in STD_LOGIC;              --di_vld
       BTNR      : in STD_LOGIC;        --ukey push input
       CLK100MHZ : in  STD_LOGIC;
       SSEG_CA   : out  STD_LOGIC_VECTOR (7 downto 0);
       SSEG_AN   : out  STD_LOGIC_VECTOR (7 downto 0)     
       
       );
end MIPS_Processor_top;

architecture Behavioral of MIPS_Processor_top is

component MIPS_Processor
PORT
(
    reset	: IN	STD_LOGIC;
	slowerCLK	: IN	STD_LOGIC;
	
	mode      : in std_logic_vector(3 downto 0); 
	
	din	: IN	STD_LOGIC_VECTOR(63 DOWNTO 0);
	di_vld	: IN	STD_LOGIC;  -- input is valid
	ukey       : in std_logic_vector(31 downto 0);   --ukey
    key_vld   : in std_logic;
	
	dout	: OUT	STD_LOGIC_VECTOR(63 DOWNTO 0);
	led       : out std_logic_vector(2 downto 0);
	do_rdy	: OUT	STD_LOGIC;   -- output is ready
	key_rdy    : out std_logic-- when key is ready
	
);

end component;

component Hex2LED 
    Port ( CLK: in STD_LOGIC; 
           X: in STD_LOGIC_VECTOR (3 downto 0); 
           Y: out STD_LOGIC_VECTOR (7 downto 0)); 
end component; 

component dbnce

    port(   clk : in std_logic;
            rst : in std_logic;
            btn_in : in std_logic;
            pls_out : out std_logic);

end component;

-- 7Segment signals 
type arr is array(0 to 22) of std_logic_vector(7 downto 0);
signal NAME: arr;
signal Val : std_logic_vector(3 downto 0) := (others => '0');
signal HexVal: std_logic_vector(31 downto 0);
signal slowCLK: std_logic:='0';
signal i_cnt: std_logic_vector(19 downto 0):=x"00000";

-- Inputs

signal din : STD_LOGIC_VECTOR( 63 downto 0 ):= x"0000000000000000";
signal ukey: std_logic_vector(31 downto 0):= x"00000000";
signal in_cnt: std_logic_vector( 2 downto 0 ) := "000";
signal k_cnt: std_logic_vector( 1 downto 0 ) := "00";


signal inp_press : STD_LOGIC;
signal k_press : STD_LOGIC;
signal outp_press : STD_LOGIC;
signal done : STD_LOGIC;
signal key_done: STD_LOGIC;
signal inp_press_db : std_logic;
signal k_press_db : std_logic;
signal db_reset: STD_LOGIC;
signal di_vld_top: STD_LOGIC;
signal key_vld_top: STD_LOGIC;

--signal LED_din: STD_LOGIC_VECTOR(1 downto 0);
--clock for normal execution
signal c_cnt: std_logic_vector(31 downto 0):=x"00000000";
signal slower_CLK: std_logic:='0';

--clock for step
signal s_cnt: std_logic_vector(31 downto 0):=x"00000000";
signal slower_step_CLK: std_logic:='0';

--input for clock
signal ip_clk: std_logic:='0';
signal step_mode: std_logic:= '0';
--signal step_clk: std_logic:= '0';

signal led_sig: std_logic_vector(2 downto 0):="000";


-- Output

signal dout : STD_LOGIC_VECTOR( 63 downto 0 );

begin

-----Creating a slow_clk of 1Hz using the board's 100MHz clock----
--    clock_1sec: process(CLK100MHZ)
--        begin
--            if (CLK100MHZ'event and CLK100MHZ = '1') then
--                if (c_cnt = x"2FAF080")then --Hex(2FAF080)=Dec(50,000,000)
--                    slow_clk <= not slow_clk; --slow_clk toggles once after we see 50000000 rising edges of CLK. 2 toggles is one period.
--                    c_cnt <= x"0000000";
--                else
--                    c_cnt <= c_cnt + 1;
--                end if;
--            end if;
--    end process clock_1sec;
    
-- 7-Sege=ment setup
    
    process( CLK100MHZ )
    begin
        if (rising_edge(CLK100MHZ)) then
            if (i_cnt=x"186A0")then 
                slowCLK<=not slowCLK; 
                i_cnt<=x"00000";
            else
                i_cnt <= i_cnt + '1';
            end if;
        end if;
    end process; 

    timer_inc_process : process (slowCLK)
    begin
        if (rising_edge(slowCLK)) then
            if(Val="1000") then
                Val<="0001";
            else
                Val <= Val + '1'; 
            end if;
        end if;
    end process;

    with Val select
	SSEG_AN   <=  "01111111" when "0001",
				  "10111111" when "0010",
				  "11011111" when "0011",
				  "11101111" when "0100",
				  "11110111" when "0101",
				  "11111011" when "0110",
				  "11111101" when "0111",
				  "11111110" when "1000",
				  "11111111" when others;

    with Val select
	SSEG_CA   <=  NAME(0) when "0001", 
				  NAME(1) when "0010", 
				  NAME(2) when "0011",
				  NAME(3) when "0100",
				  NAME(4) when "0101",
				  NAME(5) when "0110",
				  NAME(6) when "0111",
				  NAME(7) when "1000",
				  NAME(0) when others;

    CONV1: Hex2LED port map (CLK => CLK100MHZ, X => HexVal(31 downto 28), Y => NAME(0));
    CONV2: Hex2LED port map (CLK => CLK100MHZ, X => HexVal(27 downto 24), Y => NAME(1));
    CONV3: Hex2LED port map (CLK => CLK100MHZ, X => HexVal(23 downto 20), Y => NAME(2));
    CONV4: Hex2LED port map (CLK => CLK100MHZ, X => HexVal(19 downto 16), Y => NAME(3));		
    CONV5: Hex2LED port map (CLK => CLK100MHZ, X => HexVal(15 downto 12), Y => NAME(4));
    CONV6: Hex2LED port map (CLK => CLK100MHZ, X => HexVal(11 downto 8), Y => NAME(5));
    CONV7: Hex2LED port map (CLK => CLK100MHZ, X => HexVal(7 downto 4), Y => NAME(6));
    CONV8: Hex2LED port map (CLK => CLK100MHZ, X => HexVal(3 downto 0), Y => NAME(7));
 
    inp_press <= BTNL;
    outp_press <= BTND;
    key_vld_top <= BTNU;
    di_vld_top <= BTNC;
    k_press <= BTNR;
    
    db_reset <= SW(9);
    step_mode <= SW(8);

DB3: dbnce PORT MAP( clk => slowCLK , rst => db_reset , 
                     btn_in => inp_press , pls_out => inp_press_db  );
                     
DBK: dbnce PORT MAP( clk => slowCLK , rst => db_reset , 
                     btn_in => k_press , pls_out => k_press_db  );

MP: MIPS_Processor PORT MAP( din => din, dout => dout, reset => db_reset, 
                             slowerCLK => ip_clk, do_rdy => done, di_vld => di_vld_top, led => led_sig, 
                             key_vld => key_vld_top, ukey => ukey , key_rdy => key_done, mode => SW(13 downto 10));

process(step_mode, slower_step_CLK, slower_CLK)
begin
if(step_mode = '1') then
    ip_clk <= slower_step_CLK; -- do step
else
    ip_clk <= slower_CLK; -- do normal
end if;
end process;

-- ip_clk <= slower_CLK;
 

-- Switch to led_top
    led_top(4 downto 2) <=  led_sig;
    led_top(0) <= key_done;
    led_top(1) <= done;     
    led_top(7 downto 5) <= in_cnt ;
    led_top(8) <= di_vld_top;
    led_top(9) <= key_vld_top;
    led_top(11 downto 10) <= k_cnt;
    -- take input in signals from switch via
    -- button press
    
    
    process ( outp_press )
    begin
        case outp_press is
            when '0' => HexVal( 31 downto 0 ) <= dout( 31 downto 0 );
            when '1' => HexVal( 31 downto 0 ) <= dout( 63 downto 32);
            when others => HexVal( 31 downto 0 ) <= dout( 31 downto 0 );
         end case;
    end process;
            
--    process( inp_press_db )
--    begin
--        case in_cnt is 
--            when "00"    => din( 15 downto 0 )  <= SW( 15 downto 0);
                            
--                            led_top(3 downto 2) <= "00";
--                            in_cnt <= in_cnt+1;
----                            led_top_din(1 downto 0) <= "00";
--            when "01"    => din( 31 downto 16 ) <= SW( 15 downto 0);
                            
--                            led_top(3 downto 2) <= "01";
--                            in_cnt <= in_cnt+1;
----                            led_top_din(1 downto 0) <= "01";
--            when "10"    => din( 47 downto 32 ) <= SW( 15 downto 0);
                            
--                            led_top(3 downto 2) <= "10";
--                            in_cnt <= in_cnt+1;
----                            led_top_din(1 downto 0) <= "10";
--            when "11"    => din( 63 downto 48 ) <= SW( 15 downto 0);
                            
--                            led_top(3 downto 2) <= "11";
--                            in_cnt <= "00";
----                            led_top_din(1 downto 0) <= "11";
--            when others  => din( 15 downto 0 )  <= SW( 15 downto 0);
--        end case;
--    end process;

--for key_vld, user key
process( k_press_db, SW )
begin
--    if (key_vld_top = '1') then
        if( k_press_db'event and k_press_db = '1' ) then
            if ( k_cnt = "11" ) then
                k_cnt <= "00";
            end if;
        -- Decode
            if( k_cnt = "00" ) then
                ukey( 7 downto 0 ) <= SW( 7 downto 0);
                k_cnt <= k_cnt + 1;
             elsif(k_cnt = "01"  ) then
                ukey( 15 downto 8 ) <= SW(7 downto 0);
                k_cnt <= k_cnt + 1;
             elsif( k_cnt = "10" ) then
                ukey( 23 downto 16 ) <= SW( 7 downto 0);
                k_cnt <= k_cnt + 1;
             else
                ukey( 31 downto 24 ) <= SW( 7 downto 0);
                k_cnt <= "00";
            end if;
         end if;
--    end if;
end process; 

--for di_vld, data input
process( inp_press_db, SW )
begin
--    if (di_vld_top = '1') then
        if( inp_press_db'event and inp_press_db = '1' ) then
            if ( in_cnt = "111" ) then
                in_cnt <= "000";
            end if;
        -- Decode
            if( in_cnt = "000" ) then
                din( 7 downto 0 ) <= SW( 7 downto 0);
                in_cnt <= in_cnt + 1;
             elsif(in_cnt = "001"  ) then
                din( 15 downto 8 ) <= SW( 7 downto 0);
                in_cnt <= in_cnt + 1;
             elsif( in_cnt = "010" ) then
                din( 23 downto 16 ) <= SW( 7 downto 0);
                in_cnt <= in_cnt + 1;
             elsif( in_cnt = "011" ) then
                din( 31 downto 24 ) <= SW( 7 downto 0);
                in_cnt <= in_cnt + 1;
             elsif( in_cnt = "100" ) then
                din(39 downto 32 ) <= SW( 7 downto 0);
                in_cnt <= in_cnt + 1;
             elsif( in_cnt = "101" ) then
                din(47 downto 40 ) <= SW( 7 downto 0);
                in_cnt <= in_cnt + 1;
             elsif( in_cnt = "110" ) then
                 din(55 downto 48 ) <= SW( 7 downto 0);
                 in_cnt <= in_cnt + 1;                          
             else
                din( 63 downto 56 ) <= SW( 7 downto 0);
                in_cnt <= "000";
            end if;
         end if;
--    end if;
end process; 

--process(CLK100MHZ) -- normal execution -- 40 ns
--begin
--    if (rising_edge(CLK100MHZ)) then
--    if (c_cnt = x"00000002")then --Hex(00000002)=Dec(2)
--        slower_CLK<=not slower_CLK; --slowerCLK toggles once after we see 100000 rising edges of CLK. 2 toggles is one period.
--        c_cnt<=x"00000000";
--    else
--        c_cnt<=c_cnt+'1';
--    end if;
--    end if;
--end process;

process(CLK100MHZ) -- normal execution -- 100 ns
begin
    if (rising_edge(CLK100MHZ)) then
    if (c_cnt = x"00000005")then --Hex(00000005)=Dec(5)
        slower_CLK<=not slower_CLK; --slowerCLK toggles once after we see 100000 rising edges of CLK. 2 toggles is one period.
        c_cnt<=x"00000000";
    else
        c_cnt<=c_cnt+'1';
    end if;
    end if;
end process;

process(CLK100MHZ) -- step 10 seconds
begin
    if (rising_edge(CLK100MHZ)) then
    if (s_cnt = x"1DCD6500")then --Hex(1DCD6500)=Dec(500,000,000)
        slower_step_CLK<=not slower_step_CLK; --slowerCLK toggles once after we see 100000 rising edges of CLK. 2 toggles is one period.
        s_cnt<=x"00000000";
    else
        s_cnt<=s_cnt+'1';
    end if;
    end if;
end process;

--process(CLK100MHZ) -- step 5 seconds
--begin
--    if (rising_edge(CLK100MHZ)) then
--    if (s_cnt = x"0EE6B280")then --Hex(0EE6B280)=Dec(250,000,000)
--        slower_step_CLK<=not slower_step_CLK; --slowerCLK toggles once after we see 100000 rising edges of CLK. 2 toggles is one period.
--        s_cnt<=x"00000000";
--    else
--        s_cnt<=s_cnt+'1';
--    end if;
--    end if;
--end process;

--process(CLK100MHZ) -- step 10,000ns = 10 us 
--begin
--    if (rising_edge(CLK100MHZ)) then
--    if (s_cnt = x"000001F4")then --Hex(000001F4)=Dec(500)
--        slower_step_CLK<=not slower_step_CLK; --slowerCLK toggles once after we see 100000 rising edges of CLK. 2 toggles is one period.
--        s_cnt<=x"00000000";
--    else
--        s_cnt<=s_cnt+'1';
--    end if;
--    end if;
--end process;

--process(CLK100MHZ) -- step 10 ms 
--begin
--    if (rising_edge(CLK100MHZ)) then
--    if (s_cnt = x"0007A120")then --Hex(0007A120)=Dec(500,000)
--        slower_step_CLK<=not slower_step_CLK; --slowerCLK toggles once after we see 100000 rising edges of CLK. 2 toggles is one period.
--        s_cnt<=x"00000000";
--    else
--        s_cnt<=s_cnt+'1';
--    end if;
--    end if;
--end process;

--process(CLK100MHZ) -- step 1s
--begin
--    if (rising_edge(CLK100MHZ)) then
--    if (s_cnt = x"02FAF080")then --Hex(02FAF080)=Dec(50,000,000)
--        slower_step_CLK<=not slower_step_CLK; --slowerCLK toggles once after we see 100000 rising edges of CLK. 2 toggles is one period.
--        s_cnt<=x"00000000";
--    else
--        s_cnt<=s_cnt+'1';
--    end if;
--    end if;
--end process;

--process(CLK100MHZ) -- step 100ms
--begin
--    if (rising_edge(CLK100MHZ)) then
--    if (s_cnt = x"004C4B40")then --Hex(004C4B40)=Dec(5,000,000)
--        slower_step_CLK<=not slower_step_CLK; --slowerCLK toggles once after we see 100000 rising edges of CLK. 2 toggles is one period.
--        s_cnt<=x"00000000";
--    else
--        s_cnt<=s_cnt+'1';
--    end if;
--    end if;
--end process;

--process(CLK100MHZ) -- step 50ms
--begin
--    if (rising_edge(CLK100MHZ)) then
--    if (s_cnt = x"002625A0")then --Hex(002625A0)=Dec(2,500,000)
--        slower_step_CLK<=not slower_step_CLK; --slowerCLK toggles once after we see 100000 rising edges of CLK. 2 toggles is one period.
--        s_cnt<=x"00000000";
--    else
--        s_cnt<=s_cnt+'1';
--    end if;
--    end if;
--end process;

end Behavioral;
