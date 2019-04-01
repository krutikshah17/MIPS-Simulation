library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;


entity Sign_Extend is
  Port (  imm_SE                 : IN STD_LOGIC_VECTOR(15 downto 0);
          sign_ext_imm_SE        : OUT STD_LOGIC_VECTOR(31 downto 0)
     );
end Sign_Extend;

architecture Behavioral of Sign_Extend is


begin
process(imm_SE)
begin
        if (imm_SE(15)= '0') then 
            sign_ext_imm_SE <= "0000000000000000" & imm_SE(15 downto 0);
        elsif (imm_SE(15)= '1') then     
            sign_ext_imm_SE <= "1111111111111111" & imm_SE(15 downto 0);
        end if;
end process;

end Behavioral;
