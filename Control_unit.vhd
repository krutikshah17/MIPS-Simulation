library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;


entity Control_unit is
Port ( opcode_CU        : in STD_LOGIC_VECTOR(5 downto 0);
       funct_CU         : in STD_LOGIC_VECTOR(5 downto 0);
       mem_to_reg_CU    : out STD_LOGIC;
       mem_write_CU     : out STD_LOGIC;
       branch_CU        : out STD_LOGIC;
       alu_control_CU   : out STD_LOGIC_VECTOR(3 downto 0);
       alu_src_CU       : out STD_LOGIC;
       reg_dst_CU       : out STD_LOGIC;
       reg_write_CU     : out STD_LOGIC;
       halt_CU          : out STD_LOGIC;
       jump_CU          : out STD_LOGIC;
       mem_read_CU      : out STD_LOGIC
);
end Control_unit;

architecture Behavioral of Control_unit is

begin
    
    reg_write_CU <=  '1' when opcode_CU = "000000" -- R type
                     else '1' when opcode_CU = "000001" --addi
                     else '1' when opcode_CU = "000010" -- subi
                     else '1' when opcode_CU = "000011" -- andi
                     else '1' when opcode_CU = "000100" -- ori
                     else '1' when opcode_CU = "000101" -- shl
                     else '1' when opcode_CU = "000111" -- lb
                     else '0';
    
    reg_dst_CU <= 	'1' when opcode_CU="000000"   
                    else '0';
    
    alu_src_CU <=   '0' when opcode_CU = "000000" -- R type
                    else '0' when opcode_CU = "001001" --BLT
                    else '0' when opcode_CU = "001010" --BEQ
                    else '0' when opcode_CU = "001011" --BNE
                    else '0' when opcode_CU = "001100" -- Jump
                    else '0' when opcode_CU = "111111" -- halt
                    else '1';
                
                -- ADD-1, SUB-2, AND-3, OR-4, NOR-5, Shift-6, BLT-7, BEQ-8, BNE-9
    alu_control_CU <= "0001" when opcode_CU = "000001" or opcode_CU = "000111" or opcode_CU = "001000" -- addi, lb, sb
                       else "0001" when opcode_CU = "000000" and funct_CU = "000001" --add
                       
                       else "0010" when opcode_CU = "000010"    -- subi
                       else "0010" when opcode_CU = "000000" and funct_CU = "000011" --sub
                       
                       else "0011" when opcode_CU = "000011"  -- andi
                       else "0011" when opcode_CU = "000000" and funct_CU = "000101" --and 
                       
                       else "0100" when opcode_CU = "000100" -- ori
                       else "0100" when opcode_CU = "000000" and funct_CU = "000111"  --or
                       
                       else "0101" when opcode_CU = "000000" and funct_CU = "001001" --nor
                       else "0110" when opcode_CU = "000101"
                       else "0111" when opcode_CU = "001001"
                       else "1000" when opcode_CU = "001010"
                       else "1001" when opcode_CU = "001011"
                       else "0000";
                   
    branch_CU     <= '1' when opcode_CU = "001001" or opcode_CU = "001010" or opcode_CU = "001011" -- blt, beq, bne
                  else '0'; 
                
    mem_write_CU  <= '1' when opcode_CU = "001000" -- sb
                     else '0';        
                 
    mem_to_reg_CU <= '1' when opcode_CU = "000111" --lb
                      else '0';
    
    halt_CU       <= '1' when opcode_CU = "111111" --halt
                      else '0';         
                               
    jump_CU       <= '1' when opcode_CU = "001100" -- jmp
                      else '0';
                                                
    mem_read_CU   <= '1' when opcode_CU = "000111" --lb
                       else '0';                  
   
end Behavioral;
