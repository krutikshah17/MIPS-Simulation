

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Mux2_1_32bit is
 Port (input0_mux   : in  std_logic_vector(31 downto 0);
       input1_mux   : in std_logic_vector(31 downto 0);
       select_mux   : in std_logic;
       output_mux   : out std_logic_vector(31 downto 0)
        );
end Mux2_1_32bit;

architecture Behavioral of Mux2_1_32bit is

begin

process(input0_mux,input1_mux,select_mux)
begin
    if(select_mux = '1') then 
        output_mux <= input1_mux;
    else
        output_mux <= input0_mux;
    end if;
end process;

end Behavioral;
