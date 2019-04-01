library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity PCBranch is
Port (sign_imm_PCB  : in std_logic_vector(31 downto 0);
      PCPlus4_PCB   : in std_logic_vector(31 downto 0);
      PCBranch_PCB  : out std_logic_vector(31 downto 0)
);
end PCBranch;

architecture Behavioral of PCBranch is

signal  shift_imm       : std_logic_vector(31 downto 0);
signal concat_zero  : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

begin
            
    shift_imm <= sign_imm_PCB(29 downto 0) & concat_zero(31 downto 30);
    PCBranch_PCB <= shift_imm + PCPlus4_PCB;

end Behavioral;
