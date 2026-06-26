--radix-2
library ieee;
use ieee.std_logic_1164.all;

entity multiplier_radix2 is
    port(
        clk          : in  std_logic;
        rst          : in  std_logic;
        start        : in  std_logic;
        multiplicand : in  std_logic_vector(7 downto 0);
        multiplier   : in  std_logic_vector(7 downto 0);
        product      : out std_logic_vector(15 downto 0);
        done         : out std_logic
    );
end multiplier_radix2;

architecture multiplier_radix2_arch of multiplier_radix2 is
    type state_type is (S_IDLE, S_BUSY, S_DONE);
    type radix_type is (neg, zero, pos);
    type radix_type_vector is array (7 downto 0) of radix_type;
    signal state        : state_type;
    signal mult_reg     : radix_type_vector;        
    signal prod_reg     : std_logic_vector(127 downto 0);
    signal sum_reg      : std_logic_vector(111 downto 0);
    signal compl_2      : std_logic_vector(15 downto 0);
    signal part_compl_2 : std_logic_vector(15 downto 0);
    signal unused_cout  : std_logic_vector(7 downto 0);
    
    component cla16 is
        port(
            a           : in  std_logic_vector(15 downto 0);
            b           : in  std_logic_vector(15 downto 0);
            cin         : in  std_logic;
            sum         : out std_logic_vector(15 downto 0);
            cout        : out std_logic
        );
    end component;

begin
    compl_2_clac : cla16 port map(
            a    => part_compl_2,
            b    => "0000000000000001",
            cin  => '0',
            sum  => compl_2,
            cout => unused_cout(0)
    );
    
    sum0 : cla16 port map(
            a    => prod_reg(15 downto 0),
            b    => prod_reg(31 downto 16),
            cin  => '0',
            sum  => sum_reg(15 downto 0),
            cout => unused_cout(1)
    );
    sum1 : cla16 port map(
            a    => prod_reg(47 downto 32),
            b    => sum_reg(15 downto 0),
            cin  => '0',
            sum  => sum_reg(31 downto 16),
            cout => unused_cout(2)
    );
    sum2 : cla16 port map(
            a    => prod_reg(63 downto 48),
            b    => sum_reg(31 downto 16),
            cin  => '0',
            sum  => sum_reg(47 downto 32),
            cout => unused_cout(3)
    );
    sum3 : cla16 port map(
            a    => prod_reg(79 downto 64),
            b    => sum_reg(47 downto 32),
            cin  => '0',
            sum  => sum_reg(63 downto 48),
            cout => unused_cout(4)
    );
    sum4 : cla16 port map(
            a    => prod_reg(95 downto 80),
            b    => sum_reg(63 downto 48),
            cin  => '0',
            sum  => sum_reg(79 downto 64),
            cout => unused_cout(5)
    );
    sum5 : cla16 port map(
            a    => prod_reg(111 downto 96),
            b    => sum_reg(79 downto 64),
            cin  => '0',
            sum  => sum_reg(95 downto 80),
            cout => unused_cout(6)
    );
    sum6 : cla16 port map(
            a    => prod_reg(127 downto 112),
            b    => sum_reg(95 downto 80),
            cin  => '0',
            sum  => sum_reg(111 downto 96),
            cout => unused_cout(7)
    );
         
    process(clk, rst)
    begin
        if rst = '1' then
            mult_reg                            <= (others => zero);
            prod_reg                            <= (others => '0');
            part_compl_2                        <= (others => '0');
            state                               <= S_IDLE;
            done                                <= '0';
            product                             <= (others => '0');
        elsif rising_edge(clk) then
            case state is
                when S_IDLE => 
                    if start ='1'then
                        if multiplicand(0)='0' then
                            part_compl_2(0)     <= '1';
                        else
                            part_compl_2(0)     <= '0'; 
                        end if;
                        if multiplicand(1)='0' then
                            part_compl_2(1)     <= '1';
                        else
                            part_compl_2(1)     <= '0'; 
                        end if;
                        if multiplicand(2)='0' then
                            part_compl_2(2)     <= '1';
                        else
                            part_compl_2(2)     <= '0'; 
                        end if;
                        if multiplicand(3)='0' then
                            part_compl_2(3)     <= '1';
                        else
                            part_compl_2(3)     <= '0'; 
                        end if;
                        if multiplicand(4)='0' then
                            part_compl_2(4)     <= '1';
                        else
                            part_compl_2(4)     <= '0'; 
                        end if;
                        if multiplicand(5)='0' then
                            part_compl_2(5)     <= '1';
                        else
                            part_compl_2(5)     <= '0'; 
                        end if;
                        if multiplicand(6)='0' then
                            part_compl_2(6)     <= '1';
                        else
                            part_compl_2(7)     <= '0'; 
                        end if;
                        if multiplicand(7)='0' then
                            part_compl_2(7)     <= '1';
                            part_compl_2(8)     <= '1';
                        else
                            part_compl_2(7)     <= '0'; 
                            part_compl_2(8)     <= '0';
                        end if;
                        
                        if start = '1' then
                            if multiplier(0) = '0' then
                                mult_reg(0)     <= zero;
                            else
                                mult_reg(0)     <= neg;    
                            end if;
                            if multiplier(1 downto 0) = "01" then
                                mult_reg(1)     <= pos;
                            elsif multiplier(1 downto 0) = "10" then
                                mult_reg(1)     <= neg;  
                            else
                                mult_reg(1)     <= zero;  
                            end if;
                            if multiplier(2 downto 1) = "01" then
                                mult_reg(2)     <= pos;
                            elsif multiplier(2 downto 1) = "10" then
                                mult_reg(2)     <= neg;  
                            else
                                mult_reg(2)     <= zero;  
                            end if;
                            if multiplier(3 downto 2) = "01" then
                                mult_reg(3)     <= pos;
                            elsif multiplier(3 downto 2) = "10" then
                                mult_reg(3)     <= neg;  
                            else
                                mult_reg(3)     <= zero;  
                            end if;
                            if multiplier(4 downto 3) = "01" then
                                mult_reg(4)     <= pos;
                            elsif multiplier(4 downto 3) = "10" then
                                mult_reg(4)     <= neg;  
                            else
                                mult_reg(4)     <= zero;  
                            end if;
                            if multiplier(5 downto 4) = "01" then
                                mult_reg(5)     <= pos;
                            elsif multiplier(5 downto 4) = "10" then
                                mult_reg(5)     <= neg;  
                            else
                                mult_reg(5)     <= zero;  
                            end if;
                            if multiplier(6 downto 5) = "01" then
                                mult_reg(6)     <= pos;
                            elsif multiplier(6 downto 5) = "10" then
                                mult_reg(6)     <= neg;  
                            else
                                mult_reg(6)     <= zero;  
                            end if;
                            if multiplier(7 downto 6) = "01" then
                                mult_reg(7)     <= pos;
                            elsif multiplier(7 downto 6) = "10" then
                                mult_reg(7)     <= neg;  
                            else
                                mult_reg(7)     <= zero;  
                            end if;
                            state <= S_BUSY;
                       end if;
                    end if;
                    
                when S_BUSY =>
                    if multiplicand = "00000000" or multiplier = "00000000" then
                        prod_reg <= (others => '0');
                    else
                        if mult_reg(0)= pos then
                            prod_reg(15 downto 0)   <= multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand ;
                        elsif mult_reg(0)= zero then
                            prod_reg(15 downto 0)   <= (others => '0');
                        elsif mult_reg(0)= neg then
                            prod_reg(15 downto 0)   <= compl_2(8) & compl_2(8) & compl_2(8) & compl_2(8) & compl_2(8) & compl_2(8) & compl_2(8) & compl_2(8) & compl_2(7 downto 0) ;
                        end if;
                        if mult_reg(1)= pos then
                            prod_reg(31 downto 16)  <=  multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand  & "0";
                        elsif mult_reg(1)= zero then
                            prod_reg(31 downto 16)  <= (others => '0');
                        elsif mult_reg(1)= neg then
                            prod_reg(31 downto 16)  <=  compl_2(8) & compl_2(8) & compl_2(8) & compl_2(8) & compl_2(8) & compl_2(8) & compl_2(8) & compl_2(7 downto 0)       & "0" ;
                        end if;
                        if mult_reg(2)= pos then
                            prod_reg(47 downto 32)  <=  multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand  & "00";
                        elsif mult_reg(2)= zero then
                            prod_reg(47 downto 32)  <= (others => '0');
                        elsif mult_reg(2)= neg then
                            prod_reg(47 downto 32)  <=  compl_2(8) & compl_2(8) & compl_2(8) & compl_2(8) & compl_2(8) & compl_2(8) & compl_2(7 downto 0)       & "00";
                        end if;
                        if mult_reg(3)= pos then
                            prod_reg(63 downto 48)  <=  multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand  & "000";
                        elsif mult_reg(3)= zero then
                            prod_reg(63 downto 48)  <= (others => '0');
                        elsif mult_reg(3)= neg then
                            prod_reg(63 downto 48)  <=  compl_2(8) & compl_2(8) & compl_2(8) & compl_2(8) & compl_2(8) & compl_2(7 downto 0)       & "000";
                        end if;
                        if mult_reg(4)= pos then
                            prod_reg(79 downto 64)  <=  multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand  & "0000";
                        elsif mult_reg(4)= zero then
                            prod_reg(79 downto 64)  <= (others => '0');
                        elsif mult_reg(4)= neg then
                            prod_reg(79 downto 64)  <=  compl_2(8) & compl_2(8) & compl_2(8) & compl_2(8) & compl_2(7 downto 0)       & "0000";
                        end if;
                        if mult_reg(5)= pos then
                            prod_reg(95 downto 80)  <=  multiplicand(7) & multiplicand(7) & multiplicand(7) & multiplicand  & "00000";
                        elsif mult_reg(5)= zero then
                            prod_reg(95 downto 80)  <= (others => '0');
                        elsif mult_reg(5)= neg then
                            prod_reg(95 downto 80)  <=  compl_2(8) & compl_2(8) & compl_2(8) & compl_2(7 downto 0)       & "00000";
                        end if;
                        if mult_reg(6)= pos then
                            prod_reg(111 downto 96) <=  multiplicand(7) & multiplicand(7) & multiplicand  & "000000";
                        elsif mult_reg(6)= zero then
                            prod_reg(111 downto 96) <= (others => '0');
                        elsif mult_reg(6)= neg then
                            prod_reg(111 downto 96) <=  compl_2(8) & compl_2(8) & compl_2(7 downto 0)       & "000000";
                        end if;
                        if mult_reg(7)= pos then
                            prod_reg(127 downto 112)<=  multiplicand(7) & multiplicand  & "0000000";
                        elsif mult_reg(7)= zero then
                            prod_reg(127 downto 112)<= (others => '0');
                        elsif mult_reg(7)= neg then
                            prod_reg(127 downto 112)<=  compl_2(8) & compl_2(7 downto 0)       & "0000000";
                        end if;
                    end if;
                    state                       <= S_DONE;
                when S_DONE =>
                    product                     <= sum_reg(111 downto 96);
                    done                        <= '1';
                    state                       <= S_IDLE;
            end case;
        end if;
    end process;
end multiplier_radix2_arch;

--cla 2 bit
library IEEE;
use IEEE.std_logic_1164.all;

entity cla2 is
    port(
        a    : in  std_logic_vector(1 downto 0);
        b    : in  std_logic_vector(1 downto 0);
        cin  : in  std_logic;
        sum  : out std_logic_vector(1 downto 0);
        cout : out std_logic
    );
end cla2;

architecture cla2_arch of cla2 is
    signal g : std_logic_vector(1 downto 0);
    signal p : std_logic_vector(1 downto 0);
    signal c : std_logic_vector(2 downto 0);
begin
    g       <= a and b;
    p       <= a xor b;
    c(0)    <= cin;
    c(1)    <= g(0) or (p(0) and c(0));
    c(2)    <= g(1) or (p(1) and (g(0) or (p(0) and c(0))));
    cout    <= c(2);
    sum(0)  <= p(0) xor c(0);
    sum(1)  <= p(1) xor c(1);
end cla2_arch;

--cla 4 bit
library IEEE;
use IEEE.std_logic_1164.all;

entity cla4 is
    port(
        a    : in  std_logic_vector(3 downto 0);
        b    : in  std_logic_vector(3 downto 0);
        cin  : in  std_logic;
        sum  : out std_logic_vector(3 downto 0);
        cout : out std_logic
    );
end cla4;

architecture cla4_arch of cla4 is
     signal c : std_logic_vector(1 downto 0);
    component cla2 is
        port(
            a    : in  std_logic_vector(1 downto 0);
            b    : in  std_logic_vector(1 downto 0);
            cin  : in  std_logic;
            sum  : out std_logic_vector(1 downto 0);
            cout : out std_logic
        );
    end component;
begin
    cla0 : cla2 port map(
            a    => a(1 downto 0),
            b    => b(1 downto 0),
            cin  => cin,
            sum  => sum(1 downto 0),
            cout => c(0)
        );
    cla1 : cla2 port map(
            a    => a(3 downto 2),
            b    => b(3 downto 2),
            cin  => c(0),
            sum  => sum(3 downto 2),
            cout => c(1)
        );
    cout <= c(1);
end cla4_arch;

--cla 8 bit
library ieee;
use ieee.std_logic_1164.all;

entity cla8 is
    port(
        a    : in  std_logic_vector(7 downto 0);
        b    : in  std_logic_vector(7 downto 0);
        cin  : in  std_logic;
        sum  : out std_logic_vector(7 downto 0);
        cout : out std_logic
    );
end cla8;

architecture cla8_arch of cla8 is
    signal c : std_logic_vector(1 downto 0);
    component cla4 is
        port(
            a    : in  std_logic_vector(3 downto 0);
            b    : in  std_logic_vector(3 downto 0);
            cin  : in  std_logic;
            sum  : out std_logic_vector(3 downto 0);
            cout : out std_logic
        );
    end component;
begin
    cla0 : cla4 port map(
            a    => a(3 downto 0),
            b    => b(3 downto 0),
            cin  => cin,
            sum  => sum(3 downto 0),
            cout => c(0)
        );
    cla1 : cla4 port map(
            a    => a(7 downto 4),
            b    => b(7 downto 4),
            cin  => c(0),
            sum  => sum(7 downto 4),
            cout => c(1)
        );
    cout <= c(1);
end cla8_arch;

--cla 16 bit
library IEEE;
use IEEE.std_logic_1164.all;

entity cla16 is
    port(
        a    : in  std_logic_vector(15 downto 0);
        b    : in  std_logic_vector(15 downto 0);
        cin  : in  std_logic;
        sum  : out std_logic_vector(15 downto 0);
        cout : out std_logic
    );
end cla16;

architecture cla16_arch of cla16 is
    signal c : std_logic_vector(1 downto 0);
    component cla8 is
        port(
            a    : in  std_logic_vector(7 downto 0);
            b    : in  std_logic_vector(7 downto 0);
            cin  : in  std_logic;
            sum  : out std_logic_vector(7 downto 0);
            cout : out std_logic
        );
    end component;
begin
    cla0 : cla8 port map(
            a    => a(7 downto 0),
            b    => b(7 downto 0),
            cin  => cin,
            sum  => sum(7 downto 0),
            cout => c(0)
        );
    cla1 : cla8 port map(
            a    => a(15 downto 8),
            b    => b(15 downto 8),
            cin  => c(0),
            sum  => sum(15 downto 8),
            cout => c(1)
        );
    cout <= c(1);
end cla16_arch;

--cla 18 bit
library IEEE;
use IEEE.std_logic_1164.all;

entity cla18 is
    port(
        a    : in  std_logic_vector(17 downto 0);
        b    : in  std_logic_vector(17 downto 0);
        cin  : in  std_logic;
        sum  : out std_logic_vector(17 downto 0);
        cout : out std_logic
    );
end cla18;

architecture cla18_arch of cla18 is
    signal c : std_logic_vector(1 downto 0);
    component cla16 is
        port(
            a    : in  std_logic_vector(15 downto 0);
            b    : in  std_logic_vector(15 downto 0);
            cin  : in  std_logic;
            sum  : out std_logic_vector(15 downto 0);
            cout : out std_logic
        );
    end component;
    component cla2 is
        port(
            a    : in  std_logic_vector(1 downto 0);
            b    : in  std_logic_vector(1 downto 0);
            cin  : in  std_logic;
            sum  : out std_logic_vector(1 downto 0);
            cout : out std_logic
        );
    end component;
begin
    cla0 : cla16 port map(
            a    => a(15 downto 0),
            b    => b(15 downto 0),
            cin  => cin,
            sum  => sum(15 downto 0),
            cout => c(0)
        );
    cla1 : cla2 port map(
            a    => a(17 downto 16),
            b    => b(17 downto 16),
            cin  => c(0),
            sum  => sum(17 downto 16),
            cout => c(1)
        );
    cout <= c(1);
end cla18_arch;

--counter_incrementer
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity inc16 is
    port( 
        input       : in std_logic_vector(15 downto 0);
        output      : out std_logic_vector(15 downto 0);
        overflow    : out std_logic
    );
end inc16;

architecture inc16_arch of inc16 is
    component cla16 is
        port(
            a    : in  std_logic_vector(15 downto 0);
            b    : in  std_logic_vector(15 downto 0);
            cin  : in  std_logic;
            sum  : out std_logic_vector(15 downto 0);
            cout : out std_logic
        );
    end component;
begin
    cla0 : cla16 port map(
            a    => input,
            b    => "0000000000000001",
            cin  => '0',
            sum  => output,
            cout => overflow
        );
 end inc16_arch;


--shift_register 56 bit
library IEEE;
use IEEE.std_logic_1164.all;

entity shift_reg_56 is
    port(
        input       : in std_logic_vector(7 downto 0);
        output      : out std_logic_vector (55 downto 0);
        empty_shift : in std_logic;
        enable      : in std_logic;
        i_clk       : in std_logic;
        i_rst       : in std_logic
    );
end shift_reg_56;

architecture shift_reg_56_arch of shift_reg_56 is
signal stored_value : std_logic_vector (55 downto 0);
begin
    output                          <= stored_value;

    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            stored_value            <= (others => '0');
        elsif rising_edge(i_clk) then
            if enable = '1' then
                if empty_shift = '0' then
                    stored_value    <= stored_value(47 downto 0) & input;
                else
                    stored_value    <= stored_value(47 downto 0) & "00000000";
                end if;
            end if;
        end if;
    end process;

end architecture shift_reg_56_arch;


--shift_register 16 bit
library IEEE;
use IEEE.std_logic_1164.all;

entity shift_reg_16 is
    port(
        input       : in std_logic_vector(7 downto 0);
        output      : out std_logic_vector (15 downto 0);
        enable      : in std_logic;
        i_clk       : in std_logic;
        i_rst       : in std_logic
    );
end shift_reg_16;

architecture shift_reg_16_arch of shift_reg_16 is
signal stored_value : std_logic_vector (15 downto 0);
begin
    output                          <= stored_value;
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            stored_value            <= (others => '0');
        elsif rising_edge(i_clk) then
            if enable = '1' then
                stored_value        <= stored_value(7 downto 0) & input;
            end if;
        end if;
    end process;

end architecture shift_reg_16_arch;

--fsm
library IEEE;
use IEEE.std_logic_1164.all;

entity fsm is
    port (
        i_clk                       : in std_logic;
        i_rst                       : in std_logic;
        i_start                     : in std_logic;
        i_add                       : in std_logic_vector(15 downto 0);
        o_done                      : out std_logic;
        o_mem_addr                  : out std_logic_vector(15 downto 0);
        i_mem_data                  : in std_logic_vector(7 downto 0);
        o_mem_data                  : out std_logic_vector(7 downto 0);
        o_mem_we                    : out std_logic;
        o_mem_en                    : out std_logic
    );
end fsm; 

architecture fsm_arch of fsm is
--SIGNALS
    type S is (S0,SL,SF,SCS,SC,SVS,SVR,SVP,SVW,SVRS,SD);
    type FILTER is (F3,F5);
    
    -- fsm_state
    signal curr_state               : S;
    
    -- mem_control
    signal next_c                   : std_logic;
    signal next_a                   : std_logic;
    signal write                    : std_logic;
    
    -- pointers and registers
    signal coefficients_pos0        : std_logic_vector(15 downto 0); --stores coefficients initial addres
    signal coefficients_pos         : std_logic_vector(15 downto 0); --stores current coefficients pointer addres
    signal coefficients_pos_next    : std_logic_vector(15 downto 0); --stores next coefficients pointer addres
    signal coef_pos_choosen         : std_logic_vector(15 downto 0); --stores coefficients addres shift (0 if filter 3, 7 if filter 5)
    signal addres                   : std_logic_vector(15 downto 0); --mem_add, start:i_adda, increase up to i_add + lenght
    signal addres0                  : std_logic_vector(15 downto 0); --initial i_add value
    signal next_addres              : std_logic_vector(15 downto 0); --next addres pointer
    signal counter_stop             : std_logic_vector(15 downto 0); --sequence_length+4
    signal writer_pointer0          : std_logic_vector(15 downto 0); --sequence_length+17+position
    signal writer_pointer           : std_logic_vector(15 downto 0); --sequence_length+17+position
    signal writer_pointer_next      : std_logic_vector(15 downto 0); --sequence_length+17+position+1
    signal total_length             : std_logic_vector(15 downto 0); --sequence_length+17
    signal length                   : std_logic_vector(15 downto 0); --sequence_length
    signal value_pos0               : std_logic_vector(15 downto 0);
    signal counter                  : std_logic_vector(15 downto 0); --start:0, increase up to length, store current count
    signal counter_next             : std_logic_vector(15 downto 0); --start:0, increase up to length, store count to add up at next ckl_cicle
    signal secondary_counter        : std_logic_vector(15 downto 0); --start:0 
    signal secondary_counter_next   : std_logic_vector(15 downto 0); --start:0
    
    -- process_signals
    signal output16_5_neg           : std_logic_vector(15 downto 0);
    signal output16_3_neg           : std_logic_vector(15 downto 0);
    signal output16_5               : std_logic_vector(15 downto 0);
    signal output16_3               : std_logic_vector(15 downto 0);
    signal partial_output16_3       : std_logic_vector(15 downto 0);
    signal shifted_output           : std_logic_vector(63 downto 0);
    signal mult_output              : std_logic_vector(125 downto 0);
    signal start_multiply           : std_logic;
    signal done_multiply            : std_logic_vector(6 downto 0);
    signal sum_output               : std_logic_vector(107 downto 0);
    signal unused_cout              : std_logic_vector(20 downto 0); 
    
    -- shift_registers
    signal coef_reg                 : std_logic_vector(55 downto 0); --store all coefficients
    signal coef_reg_en              : std_logic; --enable coef_reg
    signal coef_reg_emt             : std_logic; --enable coef_reg
    signal val_reg                  : std_logic_vector(55 downto 0); --store up to 5 val
    signal val_reg_en               : std_logic; --enable val_reg
    signal val_reg_emt              : std_logic;
    signal length_reg_en            : std_logic; --enable length_reg
    
    signal stopper                  : std_logic;
    signal choosen_filter           : FILTER;
    signal reset_multiply           : std_logic;
    signal done                     : std_logic;
-- COMPONETS
    component inc16 is
        port(
            input                   : in std_logic_vector(15 downto 0);
            output                  : out std_logic_vector(15 downto 0);
            overflow                : out std_logic
        );
    end component inc16;
    
    component shift_reg_56 is
        port(
            input                   : in std_logic_vector(7 downto 0);
            output                  : out std_logic_vector(55 downto 0);
            enable                  : in std_logic;
            empty_shift             : in std_logic;
            i_clk                   : in std_logic;
            i_rst                   : in std_logic
        );
    end component shift_reg_56;
    
    component shift_reg_16 is
        port(
            input                   : in std_logic_vector(7 downto 0);
            output                  : out std_logic_vector(15 downto 0);
            enable                  : in std_logic;
            i_clk                   : in std_logic;
            i_rst                   : in std_logic
        );
    end component shift_reg_16;
    
    component cla18 is
        port(
            a                       : in  std_logic_vector(17 downto 0);
            b                       : in  std_logic_vector(17 downto 0);
            cin                     : in  std_logic;
            sum                     : out std_logic_vector(17 downto 0);
            cout                    : out std_logic
        );
    end component cla18; 
    
    component cla16 is
        port (
            a                       : in  std_logic_vector(15 downto 0);
            b                       : in  std_logic_vector(15 downto 0);
            cin                     : in  std_logic;
            sum                     : out std_logic_vector(15 downto 0);
            cout                    : out std_logic
        );
    end component cla16; 
    
    component multiplier_radix2 is
        port(
            clk                     : in  std_logic;
            rst                     : in  std_logic;
            start                   : in  std_logic;
            multiplicand            : in  std_logic_vector(7 downto 0);
            multiplier              : in  std_logic_vector(7 downto 0);
            product                 : out std_logic_vector(15 downto 0);
            done                    : out std_logic
        );
    end component multiplier_radix2;
begin
    process(output16_5(15 downto 0),output16_3(15 downto 0),output16_5_neg(15 downto 0),output16_3_neg(15 downto 0))
    begin
        case choosen_filter is
            when F3 => 
                if  output16_3(15)='1' then
                    if  output16_3_neg(15)='1' then
                        if  output16_3_neg(7)='0' then
                            o_mem_data      <= "10000000";
                        elsif  output16_3_neg(8)='0' then
                            o_mem_data      <= "10000000";
                        elsif  output16_3_neg(9)='0' then
                            o_mem_data      <= "10000000";
                        elsif  output16_3_neg(10)='0' then
                            o_mem_data      <= "10000000";
                        elsif  output16_3_neg(11)='0' then
                            o_mem_data      <= "10000000";
                        elsif  output16_3_neg(12)='0' then
                            o_mem_data      <= "10000000";
                        elsif  output16_3_neg(13)='0' then
                            o_mem_data      <= "10000000";
                        elsif  output16_3_neg(14)='0' then
                            o_mem_data      <= "10000000";
                        else
                            o_mem_data      <= output16_3_neg(15)   & output16_3_neg(6 downto 0);   
                        end if;  
                    else
                        o_mem_data          <= output16_3_neg(15)   & output16_3_neg(6 downto 0);   
                    end if;      
                else
                    if  output16_3(7)='1' then
                        o_mem_data          <= "01111111";
                    elsif  output16_3(8)='1' then
                        o_mem_data          <= "01111111";
                    elsif  output16_3(9)='1' then
                        o_mem_data          <= "01111111";
                    elsif  output16_3(10)='1' then
                        o_mem_data          <= "01111111";
                    elsif  output16_3(11)='1' then
                        o_mem_data          <= "01111111";
                    elsif  output16_3(12)='1' then
                        o_mem_data          <= "01111111";
                    elsif  output16_3(13)='1' then
                        o_mem_data          <= "01111111";
                    elsif  output16_3(14)='1' then
                        o_mem_data          <= "01111111";
                    else
                        o_mem_data          <= output16_3(15)   & output16_3(6 downto 0);   
                    end if;      
                end if;
            when F5 =>
                if  output16_5(15)='1' then
                    if  output16_5_neg(15)='1' then
                        if  output16_5_neg(7)='0' then
                            o_mem_data      <= "10000000";
                        elsif  output16_5_neg(8)='0' then
                            o_mem_data      <= "10000000";
                        elsif  output16_5_neg(9)='0' then
                            o_mem_data      <= "10000000";
                        elsif  output16_5_neg(10)='0' then
                            o_mem_data      <= "10000000";
                        elsif  output16_5_neg(11)='0' then
                            o_mem_data      <= "10000000";
                        elsif  output16_5_neg(12)='0' then
                            o_mem_data      <= "10000000";
                        elsif  output16_5_neg(13)='0' then
                            o_mem_data      <= "10000000";
                        elsif  output16_5_neg(14)='0' then
                            o_mem_data      <= "10000000";
                        else
                            o_mem_data      <= output16_5_neg(15)   & output16_5_neg(6 downto 0);   
                        end if;  
                    else 
                        o_mem_data          <= output16_5_neg(15)   & output16_5_neg(6 downto 0);   
                    end if;    
                else
                    if  output16_5(7)='1' then
                        o_mem_data          <= "01111111";
                    elsif  output16_5(8)='1' then
                        o_mem_data          <= "01111111";
                    elsif  output16_5(9)='1' then
                        o_mem_data          <= "01111111";
                    elsif  output16_5(10)='1' then
                        o_mem_data          <= "01111111";
                    elsif  output16_5(11)='1' then
                        o_mem_data          <= "01111111";
                    elsif  output16_5(12)='1' then
                        o_mem_data          <= "01111111";
                    elsif  output16_5(13)='1' then
                        o_mem_data          <= "01111111";
                    elsif  output16_5(14)='1' then
                        o_mem_data          <= "01111111";
                    else
                        o_mem_data          <= output16_5(15)   & output16_5(6 downto 0);   
                    end if;      
                end if;
        end case;
    end process;
    
    shifted_output(15 downto 0)             <= sum_output(107) & sum_output(107) & sum_output(107 downto 94);
    shifted_output(31 downto 16)            <= sum_output(107) & sum_output(107) & sum_output(107) & sum_output(107) & sum_output(107) & sum_output(107) & sum_output(107 downto 98);
    shifted_output(47 downto 32)            <= sum_output(107) & sum_output(107) & sum_output(107) & sum_output(107) & sum_output(107 downto 96);
    shifted_output(63 downto 48)            <= sum_output(107) & sum_output(107) & sum_output(107) & sum_output(107) & sum_output(107) & sum_output(107) & sum_output(107) & sum_output(107) & sum_output(107 downto 100);
    
    o_done                                  <= done;
-- multipliers
    mult_0:multiplier_radix2 port map(
        clk         => i_clk,
        rst         => reset_multiply,
        start       => start_multiply,
        multiplicand=> coef_reg(7 downto 0),
        multiplier  => val_reg(7 downto 0),
        product     => mult_output(15 downto 0),
        done        => done_multiply(0)
    );
     mult_1:multiplier_radix2 port map(
        clk         => i_clk,
        rst         => reset_multiply,
        start       => start_multiply,
        multiplicand=> coef_reg(15 downto 8),
        multiplier  => val_reg(15 downto 8),
        product     => mult_output(33 downto 18),
        done        => done_multiply(1)
    );
     mult_2:multiplier_radix2 port map(
        clk         => i_clk,
        rst         => reset_multiply,
        start       => start_multiply,
        multiplicand=> coef_reg(23 downto 16),
        multiplier  => val_reg(23 downto 16),
        product     => mult_output(51 downto 36),
        done        => done_multiply(2)
    );
     mult_3:multiplier_radix2 port map(
        clk         => i_clk,
        rst         => reset_multiply,
        start       => start_multiply,
        multiplicand=> coef_reg(31 downto 24),
        multiplier  => val_reg(31 downto 24),
        product     => mult_output(69 downto 54),
        done        => done_multiply(3)
    );
     mult_4:multiplier_radix2 port map(
        clk         => i_clk,
        rst         => reset_multiply,
        start       => start_multiply,
        multiplicand=> coef_reg(39 downto 32),
        multiplier  => val_reg(39 downto 32),
        product     => mult_output(87 downto 72),
        done        => done_multiply(4)
    );
     mult_5:multiplier_radix2 port map(
        clk         => i_clk,
        rst         => reset_multiply,
        start       => start_multiply,
        multiplicand=> coef_reg(47 downto 40),
        multiplier  => val_reg(47 downto 40),
        product     => mult_output(105 downto 90),
        done        => done_multiply(5)
    );
     mult_6:multiplier_radix2 port map(
        clk         => i_clk,
        rst         => reset_multiply,
        start       => start_multiply,
        multiplicand=> coef_reg(55 downto 48),
        multiplier  => val_reg(55 downto 48),
        product     => mult_output(123 downto 108),
        done        => done_multiply(6)
    );
    mult_output(125 downto 124)             <= (others=>mult_output(123));
    mult_output(107 downto 106)             <= (others=>mult_output(105));
    mult_output(89 downto 88)               <= (others=>mult_output(87));
    mult_output(71 downto 70)               <= (others=>mult_output(69));
    mult_output(53 downto 52)               <= (others=>mult_output(51));
    mult_output(35 downto 34)               <= (others=>mult_output(33));
    mult_output(17 downto 16)               <= (others=>mult_output(15));
-- cla   
    sum_01:cla18 port map(
        a           => mult_output(17 downto 0),
        b           => mult_output(35 downto 18),
        cin         => '0',
        sum         => sum_output(17 downto 0),
        cout        => unused_cout(0)
    );
    sum_012:cla18 port map(
        a           => sum_output(17 downto 0),
        b           => mult_output(53 downto 36),
        cin         => '0',
        sum         => sum_output(35 downto 18),
        cout        => unused_cout(1)
    );
    sum_0123:cla18 port map(
        a           => sum_output(35 downto 18),
        b           => mult_output(71 downto 54),
        cin         => '0',
        sum         => sum_output(53 downto 36),
        cout        => unused_cout(2)
    );
    sum_01234:cla18 port map(
        a           => sum_output(53 downto 36),
        b           => mult_output(89 downto 72),
        cin         => '0',
        sum         => sum_output(71 downto 54),
        cout        => unused_cout(3)
    );
    sum_012345:cla18 port map(
        a           => sum_output(71 downto 54),
        b           => mult_output(107 downto 90),
        cin             => '0',
        sum         => sum_output(89 downto 72),
        cout        => unused_cout(4)
    );
    sum_0123456:cla18 port map(
        a           => sum_output(89 downto 72),
        b           => mult_output(125 downto 108),
        cin         => '0',
        sum         => sum_output(107 downto 90),
        cout        => unused_cout(5)
    );

-- incrementers    
    inc16_counter:inc16 port map(
        input       => counter,
        output      => counter_next,
        overflow    => unused_cout(15)
    ); 
    
    inc16_secondary_counter:inc16 port map(
        input       => secondary_counter,
        output      => secondary_counter_next,
        overflow    => unused_cout(16)
    ); 
    
    inc16_addres:inc16 port map(
        input       => addres,
        output      => next_addres,
        overflow    => unused_cout(17)
    ); 
    
    inc16_wr_pointer:inc16 port map(
        input       => writer_pointer,
        output      => writer_pointer_next,
        overflow    => unused_cout(18)
    ); 
    
    inc16_coefficients_pos:inc16 port map(
        input       => coefficients_pos,
        output      => coefficients_pos_next,
        overflow    => unused_cout(19)
    );

-- pointers calculators    
    coefficients_pos0_calculator:cla16 port map(
        a           => addres0,
        b           => coef_pos_choosen,
        cin         => '0',
        sum         => coefficients_pos0,
        cout        => unused_cout(6)
    );  
    
    value_pos0_calculator:cla16 port map(
        a           => addres0,
        b           => "0000000000010001",
        cin         => '0',
        sum         => value_pos0,
        cout        => unused_cout(7)
    );
    
     writer_pointer0_calculator:cla16 port map(
        a           => addres0,
        b           => total_length,
        cin         => '0',
        sum         => writer_pointer0,
        cout        => unused_cout(20)
    );
    
    total_length_calculator:cla16 port map(
        a           => "0000000000010001",
        b           => length,
        cin         => '0',
        sum         => total_length,
        cout        => unused_cout(8)
    );
    
    reader_stop_calculator:cla16 port map(
        a           => "1111111111111011",
        b           => length,
        cin         => '0',
        sum         => counter_stop,
        cout        => unused_cout(9)
    );
    
    output16_3_calculator: cla16 port map(
        a           => output16_5,
        b           => partial_output16_3,
        cin         => '0',
        sum         => output16_3,
        cout        => unused_cout(10)
    );
    
    partial_output16_3_calculator: cla16 port map(
        a           => shifted_output(15 downto 0),
        b           => shifted_output(31 downto 16),
        cin         => '0',
        sum         => partial_output16_3,
        cout        => unused_cout(11)
    );
    
    output16_5_calculator: cla16 port map(
        a           => shifted_output(47 downto 32),
        b           => shifted_output(63 downto 48),
        cin         => '0',
        sum         => output16_5,
        cout        => unused_cout(12)
    );
    
    output16_3_negative_calculator: cla16 port map(
        a           => output16_3,
        b           => "0000000000000100",
        cin         => '0',
        sum         => output16_3_neg,
        cout        => unused_cout(13)
    );
    
    output16_5_negative_calculator: cla16 port map(
        a           => output16_5,
        b           => "0000000000000010",
        cin         => '0',
        sum         => output16_5_neg,
        cout        => unused_cout(14)
    );
    
    coef_reg_0:shift_reg_56 port map(
        input       => i_mem_data,
        output      => coef_reg,
        enable      => coef_reg_en,
        empty_shift => coef_reg_emt,
        i_clk       => i_clk,
        i_rst       => i_rst
    );
    
    val_reg_0:shift_reg_56 port map(
        input       => i_mem_data,
        output      => val_reg,
        enable      => val_reg_en,
        empty_shift => val_reg_emt,
        i_clk       => i_clk,
        i_rst       => i_rst
    );
    
    length_reg_0:shift_reg_16 port map(
        input       => i_mem_data,
        output      => length,
        enable      => length_reg_en,
        i_clk       => i_clk,
        i_rst       => i_rst
    );
    
    donoe_setter: process (i_start,i_clk,curr_state)
    begin
        if i_start='0' then
            done                            <= '0';
        elsif rising_edge(i_clk) then
            if curr_state=SD then
                done                        <= '1';
            end if;   
        end if;
    end process;
    
    fsm_deltha: process (i_clk, i_rst)
    begin
        reset_multiply                      <= '0';
        if i_rst='1' then
            addres0                         <= (others=>'0');
            addres                          <= (others=>'0');
            coef_pos_choosen                <= "0000000000000011";
            coefficients_pos                <= (others=>'0');
            counter                         <= (others=>'0');
            secondary_counter               <= (others=>'0');
            writer_pointer                  <= (others=>'0');
            choosen_filter                  <= F3;
            curr_state                      <= S0;
            reset_multiply                  <= '1';
            stopper                         <= '0';
        elsif rising_edge(i_clk) then
            if next_a = '1' then
                addres                      <= next_addres;
            end if;
    
            if next_c = '1' then
                coefficients_pos            <= coefficients_pos_next;
            end if;
    
            if write = '1' then
                writer_pointer              <= writer_pointer_next;
            end if;
             
            case curr_state is
                when S0     => --when start go to SL, initialising addres and enabling mem_read
                    if (i_start='1') and (done = '0') then
                        curr_state          <= SL;
                        addres0             <= i_add;
                        addres              <= i_add;
                    end if;
                when SL     => --go to SF 
                    secondary_counter       <= secondary_counter_next;
                    if secondary_counter = "0000000000000010" then
                        secondary_counter   <= (others=>'0');
                        curr_state          <= SF;
                    end if;
                when SF     => --check data_reg, if X then read again else go to SCS
                    writer_pointer          <= writer_pointer0;
                    curr_state              <= SCS;
                    addres                  <= value_pos0;
                    case i_mem_data(0) is
                        when '1' =>
                            coef_pos_choosen<= "0000000000001010"; --position 10
                            choosen_filter  <= F5;
                        when '0' =>
                            coef_pos_choosen<= "0000000000000011"; --position 3
                            choosen_filter  <= F3;
                        when others =>
                            coef_pos_choosen<= "0000000000000011"; --position 3
                            choosen_filter  <= F3;
                    end case;
                when SCS   => 
                    coefficients_pos        <= coefficients_pos0; 
                    curr_state              <= SC;
                when SC     =>
                    secondary_counter       <= secondary_counter_next;
                    if secondary_counter = "0000000000000111" then
                        secondary_counter   <= (others=>'0');
                        curr_state          <= SVS;
                    end if;
                when SVS    =>
                    secondary_counter       <= secondary_counter_next;
                    if secondary_counter = "0000000000000100" then
                        secondary_counter   <= (others=>'0');
                        curr_state          <= SVP;
                    end if;
                when SVR    =>
                    counter                 <= counter_next;
                    if stopper = '0' then
                        if counter = counter_stop then
                            stopper         <='1';
                        end if;
                        curr_state          <= SVP;
                    else
                        if counter = length then
                            counter         <= (others=>'0');
                            curr_state      <= SD;
                        else
                            curr_state      <= SVP;
                        end if;
                    end if;
                when SVP   =>
                    if done_multiply = "1111111" then
                        curr_state          <= SVW;
                    end if;
                when SVW   =>
                    curr_state              <= SVRS;
                when SVRS =>
                    reset_multiply          <= '1';
                    curr_state              <= SVR;
                when SD   =>
                    stopper                 <= '0';
                    curr_state              <= S0;
                        
            end case;
        end if;
    end process;
    
    fsm_lambda: process (curr_state,addres,coefficients_pos)
    begin
        next_c                              <= '0';
        next_a                              <= '0';
        write                               <= '0';
        start_multiply                      <= '0';
        length_reg_en                       <= '0'; 
        coef_reg_en                         <= '0';
        val_reg_en                          <= '0';
        coef_reg_emt                        <= '0';
        val_reg_emt                         <= '0';
        o_mem_en                            <= '1';
        o_mem_addr                          <= addres;
        o_mem_we                            <= '0';
        case curr_state is
            when S0     =>--base
                o_mem_en                    <= '0';
            when SL     =>--read first byte and shift
                next_a                      <= '1';
                length_reg_en               <= '1';
            when SF     =>-- cobine first byte with second than shift
                o_mem_addr                  <= (others => '0');
            when SCS    => 
                next_c                      <= '1';
                o_mem_addr                  <= coefficients_pos0; 
            when SC     =>--read coefficients populating coef_register
                o_mem_addr                  <= coefficients_pos;
                if secondary_counter /= "0000000000000111" then
                    next_c                  <= '1';
                else
                    o_mem_addr              <= (others => '0');
                end if;
                if choosen_filter = F3 and(secondary_counter = "0000000000000001" or secondary_counter = "0000000000000111") then
                    coef_reg_emt            <= '1';
                end if;
                coef_reg_en                 <= '1';
            when SVS    =>--read first 4 byte values populating val_register
                if secondary_counter /= "0000000000000100" then
                    next_a                  <= '1';
                else
                    o_mem_addr              <= (others => '0');
                end if;
                val_reg_en                  <= '1';
            when SVR    =>--read values populating val_register
                if stopper = '0' then
                    next_a                  <= '1';
                else
                    val_reg_emt             <= '1';
                end if;
                val_reg_en                  <= '1';
            when SVP    =>
                o_mem_addr                  <= writer_pointer;
                start_multiply              <= '1';
            when SVW   =>  
                o_mem_we                    <= '1'; 
                write                       <= '1';
                o_mem_addr                  <= writer_pointer;
            when SVRS   =>  
            when SD     =>
                o_mem_en                    <= '0';
        end case;
    end process;
end architecture fsm_arch;

--main_component
library IEEE;
use IEEE.std_logic_1164.all;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_add : in std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_data : out std_logic_vector(7 downto 0);
        o_mem_we : out std_logic;
        o_mem_en : out std_logic
    );
end project_reti_logiche; 

architecture project_reti_logiche_arch of project_reti_logiche is
component fsm is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_add : in std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_data : out std_logic_vector(7 downto 0);
        o_mem_we : out std_logic;
        o_mem_en : out std_logic
    );
end component fsm; 
begin
    fsm_0: fsm port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_start => i_start,
        i_add => i_add,
        o_done => o_done,
        o_mem_addr => o_mem_addr,
        i_mem_data => i_mem_data,
        o_mem_data=> o_mem_data,
        o_mem_we => o_mem_we,
        o_mem_en => o_mem_en
        );
end architecture project_reti_logiche_arch;
