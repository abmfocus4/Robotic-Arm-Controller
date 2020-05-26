library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY Bin_Counter4bit is port
(
	Clock_main : in std_logic := '0';
	reset : in std_logic := '0';
	clk_en : in std_logic := '0';
	up1_down0 : in std_logic := '0';
	counter_bits : out std_logic_vector(3 downto 0)
);

end ENTITY;

ARCHITECTURE one of Bin_Counter4bit is
	signal ud_bin_counter : UNSIGNED(3 downto 0);
	
BEGIN 

process (clock_main, reset, Up1_down0) is 
begin 
	if (reset = '0') then 
			ud_bin_counter <= "0000"; 
	
	elsif (rising_edge(clock_main)) then 
	
		if((up1_down0 = '1') AND (clk_en = '1'))then 
			ud_bin_counter <= (ud_bin_counter + 1); 
		elsif ((up1_down0 = '0') AND (clk_en = '1')) then 
			ud_bin_counter <= (ud_bin_counter);
		END IF;	
			
		end if; 
		
		counter_bits <= std_logic_vector(ud_bin_counter);
		
end process; 
end; 
