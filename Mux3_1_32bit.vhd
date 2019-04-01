library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Mux3_1_32bit is
 Port (input0_mux   : in  std_logic_vector(31 downto 0);    -- PC+4
       input1_mux   : in std_logic_vector(31 downto 0);     -- Branch
       input2_mux   : in std_logic_vector(31 downto 0);     -- Jump
       select_mux   : in std_logic_vector(1 downto 0);      -- MSB - Jump, LSB - Branch
       output_mux   : out std_logic_vector(31 downto 0)
        );
end Mux3_1_32bit;

architecture Behavioral of Mux3_1_32bit is

begin

process(input0_mux,input1_mux,input2_mux, select_mux)
begin
    if(select_mux = "00") then 
        output_mux <= input0_mux;
    elsif(select_mux = "01") then
        output_mux <= input1_mux;
    elsif(select_mux = "10") then
        output_mux <= input2_mux;
    end if;
end process;

end Behavioral;
