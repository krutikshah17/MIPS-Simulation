library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;


entity PCPlus4 is
  Port ( 
         input_PC4   : in STD_LOGIC_VECTOR(31 downto 0);
         halt_PC4    : in STD_LOGIC;
         output_PC4  : out STD_LOGIC_VECTOR(31 downto 0)
  );
   
end PCPlus4;

architecture Behavioral of PCPlus4 is

begin

process(halt_PC4,input_PC4)

begin
            if(halt_PC4 = '1') then
                output_PC4 <= input_PC4;
            else
                output_PC4 <= input_PC4 + "100";
            end if;
            
end process;

end Behavioral;