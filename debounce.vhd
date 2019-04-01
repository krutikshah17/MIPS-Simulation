library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dbnce is
    port(   clk : in std_logic;
            rst : in std_logic;
            btn_in : in std_logic;
            pls_out : out std_logic
        );
end dbnce;

architecture Behavioral of dbnce is

Signal OP1, OP2, OP3,OP4, OP5, OP6: std_logic;

begin

Process(clk)

begin

IF clk'EVENT AND clk = '1' THEN

OP1 <= btn_in ;
OP2 <= OP1;
OP3 <= OP2;
OP4 <= OP3;
OP5 <= OP4;
OP6 <= OP5;

end if;

end process;

pls_out <= OP1 and OP2 and OP3 and OP4 and OP5 and OP6;

end architecture Behavioral;



--constant COUNT_MAX : integer := 50000000; 

--constant BTN_ACTIVE : std_logic := '1';

--signal count : integer := 0;
--type state_type is (idle,wait_time); 
--signal state : state_type := idle;

--begin
  
--process(rst,clk)
--begin
--    if(rst = '1') then
--        state <= idle;
--        pls_out <= '0';
--   elsif(rising_edge(clk)) then
--        case (state) is
--            when idle =>
--                if(btn_in = BTN_ACTIVE) then  
--                    state <= wait_time;
--                else
--                    state <= idle; 
--                end if;
--                pls_out <= '0';
--            when wait_time =>
--                if(count = COUNT_MAX) then
--                    count <= 0;
--                    if(btn_in = BTN_ACTIVE) then
--                        pls_out <= '1';
--                    end if;
--                    state <= idle;  
--                else
--                    count <= count + 1;
--                end if; 
--        end case;       
--    end if;        
--end process;                  
                                                                                
