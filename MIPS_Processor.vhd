library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

library work;
use work.pkg.all;

entity MIPS_Processor is
Port (reset     : in std_logic;
--      clk       : in std_logic;
--      sw        : in std_logic; -- when it is 0 show pc else show ALU result or branch addr
      led       : out std_logic_vector(2 downto 0);
--      SSEG_CA   : out  STD_LOGIC_VECTOR (7 downto 0);
--      SSEG_AN   : out  STD_LOGIC_VECTOR (7 downto 0)
      slowerCLK : in std_logic;
      
--      invld   :  out std_logic;
      
      di_vld    : in std_logic;
      din       : in std_logic_vector(63 downto 0);
      key_vld   : in std_logic;
      ukey       : in std_logic_vector(31 downto 0);   --ukey
      
      do_rdy    : out std_logic;
      key_rdy    : out std_logic;
      mode      : in std_logic_vector(3 downto 0); 
      dout      : out std_logic_vector(63 downto 0)
--      o : out STD_LOGIC_VECTOR (31 downto 0)
  );
end MIPS_Processor;

architecture Behavioral of MIPS_Processor is

component ALU
 port(
        SrcA_ALU           : in std_logic_vector(31 downto 0); -- src1
        SrcB_ALU           : in std_logic_vector(31 downto 0); -- src2
        ALUControl_ALU     : in std_logic_vector(3 downto 0); -- function select
        ALUResult_ALU      : out std_logic_vector(31 downto 0); -- ALU Output Result
        zero_ALU           : out std_logic -- Zero Flag
    );
end component;

component Control_unit
Port (
       opcode_CU        : in STD_LOGIC_VECTOR(5 downto 0);
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
end component;

component Data_Memory
port (
      clk_DM                  : in std_logic;
      reset_DM                : in std_logic;
      mem_access_addr_DM      : in std_logic_Vector(31 downto 0);
      mem_write_data_DM       : in std_logic_Vector(31 downto 0);
      mem_write_en_DM         : in std_logic;
      mem_read_DM             : in std_logic;
      mem_read_data_DM        : out std_logic_Vector(31 downto 0);
      key_vld_DM              : in std_logic;
      ukey_DM                 : in std_logic_Vector(31 downto 0);
      din_DM                  : in  std_logic_vector(63 downto 0);
      di_vld_DM               : in std_logic;
      mode_DM                 : in std_logic_vector(3 downto 0)
--      array_m                 : out mem_array_t(0 to 1023)
      );
 end component;

component Decode_Unit
Port (  
        --reset_DU               : in STD_LOGIC;
        Instr_dec_DU           : in STD_LOGIC_VECTOR(31 downto 0);
        Rs_DU                  : out STD_LOGIC_VECTOR(4 downto 0);
        Rt_DU                  : out STD_LOGIC_VECTOR(4 downto 0);
        Rd_DU                  : out STD_LOGIC_VECTOR(4 downto 0);
        funct_DU               : out STD_LOGIC_VECTOR(5 downto 0);
        imm_DU                 : out std_logic_vector(15 downto 0);
        opcode_DU              : out STD_LOGIC_VECTOR(5 downto 0);
        address_DU             : out STD_LOGIC_VECTOR(25 downto 0)
);
end component;

component Instruction_Memory
port ( 
       prog_counter_IM   : in std_logic_vector(31 downto 0);
       instruction_IM    : out  std_logic_vector(31 downto 0)
      );
end component;

component Jump_Addr
Port ( 
        PCPlus4_JA      : IN STD_LOGIC_VECTOR(31 downto 0);
        Imm_JA          : IN STD_LOGIC_VECTOR(25 downto 0); 
        Jump_Addr_JA    : OUT STD_LOGIC_VECTOR(31 downto 0)
  );
end component;

component Mux2_1_32bit
Port (
       input0_mux   : in  std_logic_vector(31 downto 0);
       input1_mux   : in std_logic_vector(31 downto 0);
       select_mux   : in std_logic;
       output_mux   : out std_logic_vector(31 downto 0)
      );
end component;

component Mux2_1_5bit 
Port (
       input0_mux   :in  std_logic_vector(4 downto 0);
       input1_mux   :in std_logic_vector(4 downto 0);
       select_mux   :in std_logic;
       output_mux   : out std_logic_vector(4 downto 0)
      );
end component;

component Mux3_1_32bit 
 Port (input0_mux   : in  std_logic_vector(31 downto 0);    -- PC+4
       input1_mux   : in std_logic_vector(31 downto 0);     -- Branch
       input2_mux   : in std_logic_vector(31 downto 0);     -- Jump
       select_mux   : in std_logic_vector(1 downto 0);      -- MSB - Jump, LSB - Branch
       output_mux   : out std_logic_vector(31 downto 0)
       );
end component;

component PCBranch
Port (sign_imm_PCB  : in std_logic_vector(31 downto 0);
      PCPlus4_PCB   : in std_logic_vector(31 downto 0);
      PCBranch_PCB  : out std_logic_vector(31 downto 0)
      );
end component;

component PCPlus4
Port ( 
      input_PC4   : in STD_LOGIC_VECTOR(31 downto 0);
      halt_PC4    : in STD_LOGIC;
      output_PC4  : out STD_LOGIC_VECTOR(31 downto 0)
  );
end component;

component PCSrc
Port ( branch_PCS   : in std_logic;
       zero_PCS     : in std_logic;
       PCSrc_PCS    : out std_logic 
      );
end component;

component Program_Counter 
Port (   clk_PC     : in STD_LOGIC;
         reset_PC   : in STD_LOGIC;
         input_PC   : in STD_LOGIC_VECTOR(31 downto 0);
         output_PC  : out STD_LOGIC_VECTOR(31 downto 0)
  ); 
end component;

component Register_file
Port (  clk_RF              : in STD_LOGIC;
        reset_RF            : in STD_LOGIC;
        reg_write_en_RF     : in std_logic;
        reg_write_dest_RF   : in std_logic_vector(4 downto 0);
        reg_write_data_RF   : in std_logic_vector(31 downto 0);
        reg_read_addr_1_RF  : in std_logic_vector(4 downto 0);
        reg_read_data_1_RF  : out std_logic_vector(31 downto 0);
        reg_read_addr_2_RF  : in std_logic_vector(4 downto 0);
        reg_read_data_2_RF  : out std_logic_vector(31 downto 0);
        array_o             : out slv8_array_t(0 to 31)
       );
 end component;
 
 component Sign_Extend
 Port (  imm_SE                 : IN STD_LOGIC_VECTOR(15 downto 0);
         sign_ext_imm_SE        : OUT STD_LOGIC_VECTOR(31 downto 0)
      );
 end component;
 
-- component SevenSeg_Top
-- Port ( 
--        sCLK             : in  STD_LOGIC;
--        HexVal           : in std_logic_vector(31 downto 0);
--        SSEG_CA          : out  STD_LOGIC_VECTOR (7 downto 0);
--        SSEG_AN          : out  STD_LOGIC_VECTOR (7 downto 0)
--         );
-- end component;
signal mode_sel      : std_logic_vector(31 downto 0);

signal ip_IM         : std_logic_vector(31 downto 0);  --input of IM
signal ip_B_PCSrc    : std_logic;
signal ip_Zero_PCSrc : std_logic;
signal ip_srcA_ALU   : std_logic_vector(31 downto 0);
signal ip_srcB_ALU   : std_logic_vector(31 downto 0);
signal reg_array     : slv8_array_t(0 to 31);
--signal mem_array     : mem_array_t(0 to 1023);

signal ip_PC         : std_logic_vector(31 downto 0);  --input of PC
signal ip_DU         : std_logic_vector(31 downto 0);  --input for DU
signal ip_RA1_RF     : std_logic_vector(4 downto 0);   --input of RF
signal ip_RA2_RF     : std_logic_vector(4 downto 0);   --input of RF -- input to i0 5 bit mux 
signal ip_i1_5mux    : std_logic_vector(4 downto 0);   -- input to i1 5 bit mux
signal ip_funct_CU   : std_logic_vector(5 downto 0);   -- input to CU
signal ip_imm_SE     : std_logic_vector(15 downto 0);   -- input to SE
signal ip_opc_CU     : std_logic_vector(5 downto 0);   -- input to CU
signal ip_i0_mux2    : std_logic_vector(31 downto 0); -- ip0 of mux2 and ip of memory access address of dmem
signal ip_imm_JA     : std_logic_vector(25 downto 0);   -- input to JA
signal ip_sel_mux2   : std_logic;   -- select to 32 bit mux2
signal ip_mem_WE_DM  : std_logic;   -- WE to DM
signal ip_ALU_Ctrl   : std_logic_vector(3 downto 0);  
signal ip_sel_mux1   : std_logic; 
signal ip_sel_5mux   : std_logic;   -- sel to 5 bit mux
signal ip_WE_RF      : std_logic;   -- WE to RF
signal ip_halt_PP4   : std_logic;   -- Sel to PP4
signal ip_sel3_1mux  : std_logic_vector(1 downto 0); 
signal ip_mem_RE_DM  : std_logic;
signal ip_WA_RF      : std_logic_vector(4 downto 0);  ---op of 5 bit mux
signal ip_WD_RF      : std_logic_vector(31 downto 0); --op of 32 bit mux2
signal ip_i0_mux1    : std_logic_vector(31 downto 0); --ip0 of mux1 which is of 32bit
signal ip_i1_mux1    : std_logic_vector(31 downto 0); --ip1 of mux1 which is of 32bit, output of sign extend
signal ip_i1_mux2    : std_logic_vector(31 downto 0); -- ip1 of mux2
signal ip_i0_3_1mux  : std_logic_vector(31 downto 0); --op of PC4, ip of PCB, ip_i0_3_1mux
signal ip_i1_3_1mux  : std_logic_vector(31 downto 0);
signal ip_i2_3_1mux  : std_logic_vector(31 downto 0);

--signal i_cnt: std_logic_vector(19 downto 0):=x"00000";
--signal c_cnt: std_logic_vector(31 downto 0):=x"00000000";
--signal slowCLK: std_logic:='0';
--signal slowerCLK: std_logic:='0';

signal ip_SS         : std_logic_vector(63 downto 0);

begin

PC : Program_Counter    port map(clk_PC => slowerCLK, reset_PC => reset, input_PC => mode_sel, 
                                 output_PC => ip_IM);

IM : Instruction_Memory port map(prog_counter_IM => ip_IM,instruction_IM => ip_DU);

DU : Decode_Unit        port map(Instr_dec_DU => ip_DU, Rs_DU => ip_RA1_RF, 
                                 Rt_DU => ip_RA2_RF, Rd_DU => ip_i1_5mux, funct_DU => ip_funct_CU, 
                                 imm_DU => ip_imm_SE, opcode_DU => ip_opc_CU, address_DU =>ip_imm_JA);

CU : Control_unit       port map(opcode_CU => ip_opc_CU,funct_CU => ip_funct_CU, mem_to_reg_CU => ip_sel_mux2,
                                 mem_write_CU => ip_mem_WE_DM, branch_CU => ip_B_PCSrc,
                                 alu_control_CU=> ip_ALU_Ctrl, alu_src_CU => ip_sel_mux1, reg_dst_CU => ip_sel_5mux,
                                 reg_write_CU => ip_WE_RF, halt_CU => ip_halt_PP4, jump_CU => ip_sel3_1mux(1),
                                 mem_read_CU =>  ip_mem_RE_DM);
                           
RF : Register_file      port map(clk_RF => slowerCLK, reset_RF => reset, reg_write_en_RF => ip_WE_RF, 
                                 reg_write_dest_RF => ip_WA_RF, reg_write_data_RF => ip_WD_RF, 
                                 reg_read_addr_1_RF => ip_RA1_RF, reg_read_data_1_RF => ip_srcA_ALU,
                                 reg_read_addr_2_RF => ip_RA2_RF, reg_read_data_2_RF => ip_i0_mux1,
                                 array_o => reg_array);
                            
ALU1 : ALU              port map ( SrcA_ALU => ip_srcA_ALU, SrcB_ALU => ip_srcB_ALU, ALUControl_ALU => ip_ALU_Ctrl,
                                   ALUResult_ALU => ip_i0_mux2, zero_ALU => ip_Zero_PCSrc);
                        
Mux5bit : Mux2_1_5bit   port map (input0_mux => ip_RA2_RF, input1_mux => ip_i1_5mux, select_mux => ip_sel_5mux,
                                  output_mux => ip_WA_RF);
                                
Mux1 : Mux2_1_32bit     port map (input0_mux => ip_i0_mux1, input1_mux => ip_i1_mux1, select_mux=> ip_sel_mux1,
                                  output_mux => ip_srcB_ALU);
                              
SE : Sign_Extend        port map (imm_SE => ip_imm_SE, sign_ext_imm_SE => ip_i1_mux1);

PCS : PCSrc             port map (branch_PCS => ip_B_PCSrc, zero_PCS => ip_Zero_PCSrc, PCSrc_PCS => ip_sel3_1mux(0));    
               
DM :  Data_Memory       port map (clk_DM => slowerCLK, reset_DM => reset, mode_DM => mode, mem_access_addr_DM => ip_i0_mux2, mem_write_data_DM =>  ip_i0_mux1,
                                  mem_write_en_DM => ip_mem_WE_DM, mem_read_DM => ip_mem_RE_DM, mem_read_data_DM => ip_i1_mux2,
                                  ukey_DM => ukey, key_vld_DM => key_vld, din_DM =>din, di_vld_DM => di_vld); --array_m => mem_array
                            

Mux2: Mux2_1_32bit      port map (input0_mux =>ip_i0_mux2, input1_mux => ip_i1_mux2, select_mux => ip_sel_mux2,
                                  output_mux => ip_WD_RF);
                             
PCB: PCBranch           port map (sign_imm_PCB => ip_i1_mux1, PCPlus4_PCB => ip_i0_3_1mux, PCBranch_PCB => ip_i1_3_1mux);

PP4: PCPlus4            port map (input_PC4 => ip_IM, halt_PC4 => ip_halt_PP4, output_PC4 => ip_i0_3_1mux);

JA: Jump_Addr           port map(PCPlus4_JA => ip_i0_3_1mux, Imm_JA => ip_imm_JA, Jump_Addr_JA => ip_i2_3_1mux);

Mux3_1: Mux3_1_32bit    port map(input0_mux => ip_i0_3_1mux, input1_mux => ip_i1_3_1mux, input2_mux => ip_i2_3_1mux,
                                 select_mux => ip_sel3_1mux, output_mux => ip_PC);            

--dout <= reg_array(1) & reg_array(2);
process(ip_PC, mode, key_vld, di_vld )
begin

if ( mode = "0001" and key_vld = '1') then
    mode_sel <= x"00000038";
elsif ( mode = "0010" and di_vld = '1') then
    mode_sel <= x"00000178";
elsif ( mode = "0100" and di_vld = '1') then
    mode_sel <= x"00000274"; 
elsif ( mode = "1000" ) then  
    mode_sel <= x"0000037C"; 
else
    mode_sel <= ip_PC;
   
end if;
end process;

process(reg_array)
begin
if (reg_array(30) = x"00000001") then
    do_rdy <= '1';
else
    do_rdy <= '0';
end if;
end process;

process(reg_array)
begin
if (reg_array(31) = x"0000004E") then
    key_rdy <= '1';
else
    key_rdy <= '0';
end if;
end process;

--process(reg_array)
--begin
--if (reg_array(22) = x"00000001") then
--    invld <= '1';
--else
--    invld <= '0';
--end if;
--end process;

--o<= ip_i0_mux2;

-- Assigning signals to leds
led(0) <= ip_WE_RF;
led(1) <= ip_mem_WE_DM;
led(2) <= ip_B_PCSrc;

process(ip_WE_RF, ip_WD_RF, ip_mem_WE_DM, ip_i0_mux1, ip_B_PCSrc, ip_PC, reg_array, ip_IM)
begin
    if (reg_array(30) = x"00000001") then
        ip_SS <= reg_array(1) & reg_array(2);
    elsif (ip_WE_RF = '1') then
        ip_SS <= ip_WD_RF & ip_IM; -- when writing to register
    elsif (ip_mem_WE_DM = '1') then
        ip_SS <= ip_i0_mux1 & ip_IM; -- when writing to memory
    elsif (ip_B_PCSrc = '1') then
        ip_SS <= ip_PC & ip_IM; -- address of branch
    else
        ip_SS <=  reg_array(1) & reg_array(2);
    end if;
end process;

dout <= ip_SS;

----HexVal <= ip_SS;

--SS: SevenSeg_Top port map(sCLK => slowCLK, HexVal => ip_SS, SSEG_CA => SSEG_CA, SSEG_AN => SSEG_AN);

--process(clk)
--begin
--    if (rising_edge(clk)) then
--    if (i_cnt=x"186A0")then --Hex(186A0)=Dec(100,000)
--        slowCLK<=not slowCLK; --slowCLK toggles once after we see 100000 rising edges of CLK. 2 toggles is one period.
--        i_cnt<=x"00000";
--    else
--        i_cnt<=i_cnt+'1';
--    end if;
--    end if;
--end process;

--process(clk)
--begin
--    if (rising_edge(clk)) then
--    if (c_cnt = x"1DCD6500")then --Hex(1DCD6500)=Dec(500,000,000)
--        slowerCLK<=not slowerCLK; --slowerCLK toggles once after we see 100000 rising edges of CLK. 2 toggles is one period.
--        c_cnt<=x"00000000";
--    else
--        c_cnt<=c_cnt+'1';
--    end if;
--    end if;
--end process;

--process(ip_WE_RF, ip_WD_RF, ip_mem_WE_DM, ip_i0_mux1, ip_B_PCSrc, ip_PC)
--begin
--        if (ip_WE_RF = '1') then
--            ip_SS <= ip_WD_RF; -- when writing to register
--        elsif (ip_mem_WE_DM = '1') then
--            ip_SS <= ip_i0_mux1; -- when writing to memory
--        elsif (ip_B_PCSrc = '1') then
--            ip_SS <= ip_PC; -- address of branch
--        else
--            ip_SS <= x"ffffffff";
--        end if;

--end process;

--o <= ip_SS;

                        
end Behavioral;
