----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2018 06:26:40 PM
-- Design Name: 
-- Module Name: Mux2_1_5bit - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;



entity Mux2_1_5bit is
 Port (input0_mux   :in  std_logic_vector(4 downto 0);
       input1_mux   :in std_logic_vector(4 downto 0);
       select_mux   :in std_logic;
       output_mux   : out std_logic_vector(4 downto 0)
        );
end Mux2_1_5bit;

architecture Behavioral of Mux2_1_5bit is

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