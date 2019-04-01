library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

library work;
use work.pkg.all;
USE	IEEE.STD_LOGIC_TEXTIO.ALL;
USE	STD.TEXTIO.ALL;

entity Final_MIPS_Processor_TB_TestVect is
end Final_MIPS_Processor_TB_TestVect;

architecture Behavioral of Final_MIPS_Processor_TB_TestVect is

component MIPS_Processor
Port (reset     : in std_logic;
      led       : out std_logic_vector(2 downto 0);
      slowerCLK : in std_logic;
         
      di_vld    : in std_logic;
      din       : in std_logic_vector(63 downto 0);
      key_vld   : in std_logic;
      ukey      : in std_logic_vector(31 downto 0);   --ukey
      
      do_rdy    : out std_logic;
      key_rdy   : out std_logic;
      mode      : in std_logic_vector(3 downto 0); 
      dout      : out std_logic_vector(63 downto 0)
      );
end component;

signal reset     : std_logic;
signal led       : std_logic_vector(2 downto 0);
signal slowerCLK : std_logic;
signal di_vld    : std_logic;
signal din_MP    : std_logic_vector(63 downto 0);
signal ukey_MP   : std_logic_vector(31 downto 0);   --ukey
signal mode_MP   : std_logic_vector(3 downto 0); 
signal dout_MP   : std_logic_vector(63 downto 0);
signal key_vld   : std_logic;
signal do_rdy    : std_logic;
signal key_rdy   : std_logic;

--signal din_temp    : std_logic_vector(63 downto 0);
--signal ukey_temp   : std_logic_vector(31 downto 0);   --ukey
--signal mode_temp   : std_logic_vector(3 downto 0); 
--signal dout_temp   : std_logic_vector(63 downto 0);

signal stop_the_clock : boolean;
constant PERIOD: time := 200 ns;

begin

UUT : MIPS_Processor PORT MAP (reset => reset , led => led, slowerCLK => slowerCLK, di_vld => di_vld,
                                        din => din_MP, key_vld => key_vld, ukey => ukey_MP, do_rdy => do_rdy,
                                        key_rdy => key_rdy, mode => mode_MP , dout => dout_MP);
                                                              
                                     
--clk_gen: process        
--           begin
--               loop
--                   slowerCLK <= '0';
--                   wait for PERIOD / 2;
--                   slowerCLK <= '1';
--                   wait for PERIOD / 2;
--                   slowerCLK <= '0';
--                   wait for PERIOD / 2;
--                   slowerCLK <= '1';
--                   wait for PERIOD / 2;
--                   slowerCLK <= '0';
--                   wait for PERIOD / 2;
--                   slowerCLK <= '1';
--                   wait for PERIOD / 2;
--                   slowerCLK <= '0';
--                   wait for PERIOD / 2;
--                   slowerCLK <= '1';
--                   wait for PERIOD / 2;
--                   slowerCLK <= '0';
--                   wait for PERIOD / 2;
--                   slowerCLK <= '1';
--                   wait for PERIOD / 2;
--               end loop;
--           end process;

clocking: process
  begin
    while not stop_the_clock loop
      slowerCLK <= '0', '1' after PERIOD / 2;
      wait for PERIOD;
    end loop;
    wait;
  end process;
           
                                            
readcmd: process

file cmdfile: TEXT;       -- Define the file 'handle'
file outfile: TEXT;       -- Define the file 'handle'
variable L: Line;         -- Define the line buffer
variable line_out: Line; 
variable good: boolean; --status of the read operation

variable mode_txt          : std_logic_vector(3 downto 0); 
variable din_txt, dout_txt : std_logic_vector(63 downto 0);
variable ukey_txt          : std_logic_vector(31 downto 0);

constant TESTPASS: string := "Test_Passed";
constant TESTFAIL: string := "Test_Failed";

begin

--reset
    reset <= '1';
    di_vld <= '0';
    key_vld <= '1';
    mode_MP <= "0000";
    ukey_MP <= x"00000000";
    din_MP <= x"0000000000000000";
    wait for 1000ns;
    
    reset <= '0';
    di_vld <= '0';
    key_vld <= '1';
    mode_MP <= "0000";
    ukey_MP <= x"00000000";
    din_MP <= x"0000000000000000";
    wait for 1000ns;

-- Open the command file...

FILE_OPEN(cmdfile,"C:\Users\shefa\OneDrive\Desktop\500_Test_Vectors.txt",READ_MODE);
FILE_OPEN(outfile,"C:\Users\shefa\OneDrive\Desktop\500_Test_Vectors_Results.txt",write_mode);

loop
    if endfile(cmdfile) then  -- Check EOF
        assert false
            report "End of file encountered; exiting."
            severity NOTE;
        exit;
    end if;
    
readline(cmdfile,L);            -- Read the line
next when L'length = 0;         -- Skip empty lines

hread(L,mode_txt,good);     -- Read the mode argument as 4-bit value
assert good
    report "Text I/O read error"
    severity ERROR;

hread(L,ukey_txt,good);     -- Read the user key argument as hex value
assert good
    report "Text I/O read error"
    severity ERROR;

hread(L,din_txt,good);     -- Read the din argument
assert good
    report "Text I/O read error"
    severity ERROR;

hread(L,dout_txt,good);     -- Read the dout expected resulted
assert good
    report "Text I/O read error"
    severity ERROR;
 
--mode_temp <= mode_txt;
--ukey_temp <= ukey_txt;
--din_temp <= din_txt;
--dout_temp <= dout_txt; 

wait for 1500us;       -----look into this


--process(mode_MP,mode_temp, ukey_temp, din_temp, dout_MP, dout_temp)

--begin

if (mode_txt = x"1") then

--key_expansion
    reset <= '0';
    di_vld <= '0';
    key_vld <= '1';
    mode_MP <= mode_txt;
    ukey_MP <= ukey_txt;
    din_MP <= din_txt;
    wait for 1000ns;
   
    reset <= '0';
    di_vld <= '0';
    key_vld <= '0';
    mode_MP <= mode_txt;
    ukey_MP <= ukey_txt;
    din_MP <= din_txt;
    wait for 1000us;
    
--    if (din_MP = din_txt) then
--         write(line_out,TESTPASS);
--     else
--         write(line_out,TESTFAIL);
--     end if;
         
     hwrite(line_out, mode_MP, RIGHT, 2);
     hwrite(line_out,ukey_MP,RIGHT,9);
     hwrite(line_out,din_MP,RIGHT,17);
     hwrite(line_out,dout_MP,RIGHT,17);
     --writeline(OUTPUT,line_out); 
     writeline(outfile,line_out ); 
    
elsif (mode_txt = x"2") then
   --encryption
    reset <= '0';
    di_vld <= '1';
    key_vld <= '0';
    mode_MP <= mode_txt;
    ukey_MP <= ukey_txt;
    din_MP <= din_txt;
   wait for 3000ns;
   
    reset <= '0';
    di_vld <= '0';
    key_vld <= '0';
    mode_MP <= mode_txt;
    ukey_MP <= ukey_txt;
    din_MP <= din_txt;
   wait for 500us;
    
--    if (dout_MP = dout_txt) then
--        write(line_out,TESTPASS);
--    else
--        write(line_out,TESTFAIL);
--    end if;
    
    hwrite(line_out, mode_MP, RIGHT, 2);
    hwrite(line_out,ukey_MP,RIGHT,9);
    hwrite(line_out,din_MP,RIGHT,17);
    hwrite(line_out,dout_MP,RIGHT,17);
        --writeline(OUTPUT,line_out); 
        writeline(outfile,line_out ); 
    
elsif (mode_txt = x"4") then
    --decryption
    reset <= '0';
    di_vld <= '1';
    key_vld <= '0';
    mode_MP <= mode_txt;
    ukey_MP <= ukey_txt;
    din_MP <= din_txt;
    wait for 1000ns;
    
    reset <= '0';
    di_vld <= '0';
    key_vld <= '0';
    mode_MP <= mode_txt;
    ukey_MP <= ukey_txt;
    din_MP <= dout_txt;
    wait for 500us;
     
--     if (dout_MP = din_txt) then
--         write(line_out,TESTPASS);
--     else
--         write(line_out,TESTFAIL);
--     end if;
     
     hwrite(line_out, mode_MP, RIGHT, 2);
     hwrite(line_out,ukey_MP,RIGHT,9);
     hwrite(line_out,din_MP,RIGHT,17);
     hwrite(line_out,dout_MP,RIGHT,17);
 --writeline(OUTPUT,line_out); 
    writeline(outfile,line_out ); 
     
end if;

wait for 1500us; 

end loop;
wait;
stop_the_clock <= true;

end process;

end Behavioral;
