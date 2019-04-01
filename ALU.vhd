library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
-- use IEEE.std_logic_signed.all;


entity ALU is
    port(
         SrcA_ALU           : in std_logic_vector(31 downto 0); -- src1
         SrcB_ALU           : in std_logic_vector(31 downto 0); -- src2
         ALUControl_ALU     : in std_logic_vector(3 downto 0); -- function select
         ALUResult_ALU      : out std_logic_vector(31 downto 0); -- ALU Output Result
         zero_ALU           : out std_logic -- Zero Flag
     );
end ALU;

architecture Behavioral of ALU is

signal result       : std_logic_vector(31 downto 0);
signal zero_signal  : std_logic;
signal SrcA_sgn     : signed(31 downto 0);
signal SrcB_sgn     : signed(31 downto 0);
signal concat_zero  : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');


begin
SrcA_sgn <= signed(SrcA_ALU);
SrcB_sgn <= signed(SrcB_ALU);
process(ALUControl_ALU,SrcA_ALU,SrcB_ALU, concat_zero,SrcA_sgn,SrcB_sgn)

begin

    case ALUControl_ALU is
         when "0001" =>
--          result <= SrcA_ALU + SrcB_ALU; -- ADD-1         
          result <= std_logic_vector(unsigned(SrcA_sgn + SrcB_sgn)); -- ADD-1
          zero_signal <= '0';
         when "0010" =>
          result <= SrcA_ALU - SrcB_ALU; -- SUB-2
          zero_signal <= '0';
         when "0011" => 
          result <= SrcA_ALU and SrcB_ALU; -- AND-3
          zero_signal <= '0';
         when "0100" =>
          result <= SrcA_ALU or SrcB_ALU; -- OR-4
          zero_signal <= '0';
         when "0101" =>
            result <= SrcA_ALU nor SrcB_ALU; -- NOR-5
            zero_signal <= '0';
            
         when "0110" =>                     --sll-6
         zero_signal <= '0';
            case SrcB_ALU(4 downto 0) is
                WHEN "00001" => result <= SrcA_ALU(30 downto 0) & concat_zero(31);
                WHEN "00010" => result <= SrcA_ALU(29 downto 0) & concat_zero(31 downto 30);
                WHEN "00011" => result <=  SrcA_ALU(28 downto 0) & concat_zero(31 downto 29);
                WHEN "00100"=> result<= SrcA_ALU(27 DOWNTO 0) & concat_zero(31 DOWNTO 28);
                WHEN "00101"=> result<= SrcA_ALU(26 DOWNTO 0) & concat_zero(31 DOWNTO 27);
                WHEN "00110"=> result<= SrcA_ALU(25 DOWNTO 0) & concat_zero(31 DOWNTO 26);
                WHEN "00111" => result<= SrcA_ALU(24 DOWNTO 0) & concat_zero(31 DOWNTO 25);
                WHEN "01000" => result<= SrcA_ALU(23 DOWNTO 0) & concat_zero(31 DOWNTO 24);
                WHEN "01001" => result<= SrcA_ALU(22 DOWNTO 0) & concat_zero(31 DOWNTO 23);
                WHEN "01010" => result<= SrcA_ALU(21 DOWNTO 0) & concat_zero(31 DOWNTO 22);
                WHEN "01011" => result<= SrcA_ALU(20 DOWNTO 0) & concat_zero(31 DOWNTO 21);
                WHEN "01100" => result<= SrcA_ALU(19 DOWNTO 0) & concat_zero(31 DOWNTO 20);
                WHEN "01101" => result<= SrcA_ALU(18 DOWNTO 0) & concat_zero(31 DOWNTO 19);
                WHEN "01110" => result<= SrcA_ALU(17 DOWNTO 0) & concat_zero(31 DOWNTO 18);
                WHEN "01111" => result<= SrcA_ALU(16 DOWNTO 0) & concat_zero(31 DOWNTO 17);
                WHEN "10000" => result<= SrcA_ALU(15 DOWNTO 0) & concat_zero(31 DOWNTO 16);
                WHEN "10001" =>result<= SrcA_ALU(14 DOWNTO 0) & concat_zero(31 DOWNTO 15);
                WHEN "10010" =>result<= SrcA_ALU(13 DOWNTO 0) & concat_zero(31 DOWNTO 14);
                WHEN "10011" =>result<= SrcA_ALU(12 DOWNTO 0) & concat_zero(31 DOWNTO 13);
                WHEN "10100" =>result<= SrcA_ALU(11 DOWNTO 0) & concat_zero(31 DOWNTO 12);
                WHEN "10101" =>result<= SrcA_ALU(10 DOWNTO 0) & concat_zero(31 DOWNTO 11);
                WHEN "10110" =>result<= SrcA_ALU(9 DOWNTO 0) & concat_zero(31 DOWNTO 10);
                WHEN "10111" =>result<= SrcA_ALU(8 DOWNTO 0) & concat_zero(31 DOWNTO 9);
                WHEN "11000" =>result<= SrcA_ALU(7 DOWNTO 0) & concat_zero(31 DOWNTO 8);
                WHEN "11001" =>result<= SrcA_ALU(6 DOWNTO 0) & concat_zero(31 DOWNTO 7);
                WHEN "11010" =>result<= SrcA_ALU(5 DOWNTO 0) & concat_zero(31 DOWNTO 6);
                WHEN "11011" =>result<= SrcA_ALU(4 DOWNTO 0) & concat_zero(31 DOWNTO 5);
                WHEN "11100" =>result<= SrcA_ALU(3 DOWNTO 0) & concat_zero(31 DOWNTO 4);
                WHEN "11101" =>result<= SrcA_ALU(2 DOWNTO 0) & concat_zero(31 DOWNTO 3);
                WHEN "11110" =>result<= SrcA_ALU(1 DOWNTO 0) & concat_zero(31 DOWNTO 2);
                WHEN "11111" =>result<= SrcA_ALU(0) & concat_zero(31 DOWNTO 1);
                WHEN OTHERS =>result<=SrcA_ALU;            
            end case;
            
         when "0111" =>
             if (SrcA_sgn < SrcB_sgn) then -- BLT-7
                zero_signal <= '1';
                result <= x"00000000";
             else
                zero_signal <= '0';
                result <= x"00000000";
             end if;
             
         when "1000" =>
             if (SrcA_ALU = SrcB_ALU) then -- BEQ-8 
                zero_signal <= '1';
                result <= x"00000000";
             else
                zero_signal <= '0';
                result <= x"00000000";
             end if; 
                     
         when "1001" =>
            if (SrcA_ALU /= SrcB_ALU) then -- BNE-9
               zero_signal <= '1';
               result <= x"00000000";
            else
               zero_signal <= '0';
               result <= x"00000000";
            end if;  
           
         when others => result <= x"00000000";
                        zero_signal <= '0';
    end case;
end process;

  zero_ALU      <= '1'         when zero_signal = '1' else '0';
  ALUResult_ALU <= x"00000000" when zero_signal = '1' else result;

end Behavioral;