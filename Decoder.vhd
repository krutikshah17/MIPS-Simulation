library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity Decode_Unit is
Port (  --reset_DU               : in STD_LOGIC;
        Instr_dec_DU           : in STD_LOGIC_VECTOR(31 downto 0);
        Rs_DU                  : out STD_LOGIC_VECTOR(4 downto 0);
        Rt_DU                  : out STD_LOGIC_VECTOR(4 downto 0);
        Rd_DU                  : out STD_LOGIC_VECTOR(4 downto 0);
        funct_DU               : out STD_LOGIC_VECTOR(5 downto 0);
        imm_DU                 : out std_logic_vector(15 downto 0);
        opcode_DU              : out STD_LOGIC_VECTOR(5 downto 0);
        address_DU             : out STD_LOGIC_VECTOR(25 downto 0)

);

end Decode_Unit;

architecture Behavioral of Decode_Unit is

signal opcode_sig   : std_logic_vector(5 downto 0);
--signal imm      : std_logic_vector(15 downto 0);

begin

opcode_DU(5 downto 0) <= Instr_dec_DU (31 downto 26); 
opcode_sig <= Instr_dec_DU (31 downto 26); 

process(opcode_sig, Instr_dec_DU)
begin
        -- for R-type
        if (opcode_sig = "000000") then 
                Rs_DU      <= Instr_dec_DU (25 downto 21);
                Rt_DU      <= Instr_dec_DU (20 downto 16); 
                Rd_DU      <= Instr_dec_DU (15 downto 11);
                funct_DU   <= Instr_dec_DU (5 downto 0); 
            -- for I-type
        elsif (opcode_sig /= "000000" and opcode_sig /= "001100" and opcode_sig /= "111111") then   
                Rs_DU    <= Instr_dec_DU (25 downto 21);
                Rt_DU    <= Instr_dec_DU (20 downto 16); 
                imm_DU   <= Instr_dec_DU (15 downto 0);
    
            -- for J-type
        elsif (opcode_sig = "001100") then
               address_DU  <= Instr_dec_DU (25 downto 0);        
        end if;

end process;

end Behavioral;
