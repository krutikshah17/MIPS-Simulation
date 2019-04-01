library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity MIPS_Processor_tb is
end;

architecture bench of MIPS_Processor_tb is

  component MIPS_Processor
  Port (reset     : in std_logic;
        led       : out std_logic_vector(2 downto 0);
        slowerCLK : in std_logic;
--        invld     :  out std_logic;
        di_vld    : in std_logic;
        din       : in std_logic_vector(63 downto 0);
        key_vld   : in std_logic;
        ukey      : in std_logic_vector(31 downto 0);
        do_rdy    : out std_logic;
        key_rdy   : out std_logic;
        mode      : in std_logic_vector(3 downto 0); 
        dout      : out std_logic_vector(63 downto 0)
    );
  end component;

  signal reset: std_logic;
  signal led: std_logic_vector(2 downto 0);
  signal slowerCLK: std_logic;
--  signal invld: std_logic;
  signal di_vld: std_logic;
  signal din: std_logic_vector(63 downto 0);
  signal key_vld: std_logic;
  signal ukey: std_logic_vector(31 downto 0);
  signal do_rdy: std_logic;
  signal key_rdy: std_logic;
  signal mode: std_logic_vector(3 downto 0);
  signal dout: std_logic_vector(63 downto 0) ;
  constant clock_period: time := 100 ns;
  signal stop_the_clock: boolean;

begin

  uut: MIPS_Processor port map ( reset     => reset,
                                 led       => led,
                                 slowerCLK => slowerCLK,
--                                 invld     => invld,
                                 di_vld    => di_vld,
                                 din       => din,
                                 key_vld   => key_vld,
                                 ukey      => ukey,
                                 do_rdy    => do_rdy,
                                 key_rdy   => key_rdy,
                                 mode      => mode,
                                 dout      => dout );

  stimulus: process
  begin
  wait for 1000ns;
    
    --reset
    reset <= '1';
    di_vld <= '0';
    key_vld <= '1';
    mode <= "0000";
    ukey <= x"00000000";
    din <= x"087312232c9311d6";
  --  din <= x"087312232C9311D6";
    wait for 1000ns;
    
    reset <= '0';
    di_vld <= '0';
    key_vld <= '1';
    mode <= "0000";
    ukey <= x"00000000";
    din <= x"087312232c9311d6";
    wait for 1000ns;
    
    --key_expansion
    reset <= '0';
    di_vld <= '0';
    key_vld <= '1';
    mode <= "0001";
    ukey <= x"00000000";
    din <= x"087312232c9311d6";
    wait for 1000ns;
    
--    reset <= '0';
--    di_vld <= '0';
--    key_vld <= '1';
--    mode <= "0001";
--    ukey <= x"00000000";
--    din <= x"087312232c9311d6";
--    wait for 1000ns;
    
    reset <= '0';
    di_vld <= '0';
    key_vld <= '0';
    mode <= "0001";
    ukey <= x"00000000";
    din <= x"087312232c9311d6";
    wait for 1000us;
    
    --encryption
    reset <= '0';
    di_vld <= '1';
    key_vld <= '0';
    mode <= "0010";
    ukey <= x"00000000";
    din <= x"0000000100000001";
    wait for 3000ns;
    
    reset <= '0';
    di_vld <= '0';
    key_vld <= '0';
    mode <= "0010";
    ukey <= x"00000000";
    din <= x"0000000100000001";
    wait for 500us;
    
--    reset <= '0';
--    di_vld <= '0';
--    key_vld <= '0';
--    mode <= "0000";
--    ukey <= x"00000000";
--    din <= x"0000000100000001";
--    wait for 500us;
   
--    --decryption
    reset <= '0';
    di_vld <= '1';
    key_vld <= '0';
    mode <= "0100";
    ukey <= x"00000000";
    din <= x"087312232c9311d6";
    wait for 1000ns;
    
    reset <= '0';
    di_vld <= '0';
    key_vld <= '0';
    mode <= "0100";
    ukey <= x"00000000";
    din <= x"087312232c9311d6";
    wait for 500us;
    
--    reset <= '0';
--    di_vld <= '0';
--    key_vld <= '0';
--    mode <= "0000";
--    ukey <= x"00000000";
--    din <= x"087312232c9311d6";
--    wait for 500us;    
    

        
    stop_the_clock <= true;
   
    wait;
  end process;

clocking: process
  begin
    while not stop_the_clock loop
      slowerCLK <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;
  
end;