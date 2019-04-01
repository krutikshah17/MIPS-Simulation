library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
--use IEEE.STD_LOGIC_arith.ALL;

library work;
use work.pkg.all;


entity Register_file is
    Port (  clk_RF              : in STD_LOGIC;
            reset_RF            : in STD_LOGIC;
            reg_write_en_RF     : in std_logic;
            reg_write_dest_RF   : in std_logic_vector(4 downto 0);
            reg_write_data_RF   : in std_logic_vector(31 downto 0);
            reg_read_addr_1_RF  : in std_logic_vector(4 downto 0);
            reg_read_data_1_RF  : out std_logic_vector(31 downto 0);
            reg_read_addr_2_RF  : in std_logic_vector(4 downto 0);
            reg_read_data_2_RF  : out std_logic_vector(31 downto 0);
            array_o             : out slv8_array_t(0 to 31)
           );
end Register_file;

architecture Behavioral of Register_file is

--type reg_type is array (0 to 31 ) of std_logic_vector (31 downto 0);

signal reg_array: slv8_array_t(0 to 31);

begin
 process(clk_RF,reset_RF, reg_write_dest_RF, reg_write_data_RF, reg_write_en_RF) 
 begin
        if(reset_RF='1') then
            reg_array(0) <= x"00000000";
            reg_array(1) <= x"00000000";
            reg_array(2) <= x"00000000";
            reg_array(3) <= x"00000000";
            reg_array(4) <= x"00000000";
            reg_array(5) <= x"00000000";
            reg_array(6) <= x"00000000";
            reg_array(7) <= x"00000000";
            reg_array(8) <= x"00000000";
            reg_array(9) <= x"00000000";
            reg_array(10) <= x"00000000";
            reg_array(11) <= x"00000000";
            reg_array(12) <= x"00000000";
            reg_array(13) <= x"00000000";
            reg_array(14) <= x"00000000";
            reg_array(15) <= x"00000000";
            reg_array(16) <= x"00000000";
            reg_array(17) <= x"00000000";
            reg_array(18) <= x"00000000";
            reg_array(19) <= x"00000000";
            reg_array(20) <= x"00000000";
            reg_array(21) <= x"00000000";
            reg_array(22) <= x"00000000";
            reg_array(23) <= x"00000000";
            reg_array(24) <= x"00000000";
            reg_array(25) <= x"00000000";
            reg_array(26) <= x"00000000";
            reg_array(27) <= x"00000000";
            reg_array(28) <= x"00000000";
            reg_array(29) <= x"00000000";
            reg_array(30) <= x"00000000";
            reg_array(31) <= x"00000000";
  
 elsif(rising_edge(clk_RF)) then
   if(reg_write_en_RF='1') then
        reg_array(to_integer(unsigned(reg_write_dest_RF))) <= reg_write_data_RF;
   end if;
 end if;
 
 end process;

 reg_read_data_1_RF <= x"00000000" when reg_read_addr_1_RF = "00000" else reg_array(to_integer(unsigned(reg_read_addr_1_RF)));
 reg_read_data_2_RF <= x"00000000" when reg_read_addr_2_RF = "00000" else reg_array(to_integer(unsigned(reg_read_addr_2_RF)));

 array_o <= reg_array;
end Behavioral;
