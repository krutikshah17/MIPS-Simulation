library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;


entity PCSrc is
 Port (branch_PCS   : in std_logic;
       zero_PCS     : in std_logic;
       PCSrc_PCS    : out std_logic );
end PCSrc;

architecture Behavioral of PCSrc is

begin

PCSrc_PCS <= branch_PCS and zero_PCS;

end Behavioral;
