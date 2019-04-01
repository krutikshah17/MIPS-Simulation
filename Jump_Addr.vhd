library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Jump_Addr is
  Port (PCPlus4_JA      : IN STD_LOGIC_VECTOR(31 downto 0);
        Imm_JA          : IN STD_LOGIC_VECTOR(25 downto 0); 
        Jump_Addr_JA    : OUT STD_LOGIC_VECTOR(31 downto 0)
  );
end Jump_Addr;

architecture Behavioral of Jump_Addr is

begin

Jump_Addr_JA <= PCPlus4_JA(31 downto 28) & Imm_JA & "00";

end Behavioral;
