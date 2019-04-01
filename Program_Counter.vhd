library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;


entity Program_Counter is
  Port ( clk_PC     : in STD_LOGIC;
         reset_PC   : in STD_LOGIC;
         input_PC   : in STD_LOGIC_VECTOR(31 downto 0);
         output_PC  : out STD_LOGIC_VECTOR(31 downto 0)
  );
   
end Program_Counter;

architecture Behavioral of Program_Counter is

begin
process(clk_PC, reset_PC, input_PC)

begin
      if(reset_PC = '1') then
            output_PC <= x"00000000";
      elsif(rising_edge(clk_PC)) then
            output_PC <= input_PC;
      end if;       
end process;

end Behavioral;
