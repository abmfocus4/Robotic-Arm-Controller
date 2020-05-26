library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity display is port (
Error_clk 		: in std_logic; 
pushbutton  		 		: in std_logic;  
initial_dist 					: in std_logic_vector(3 downto 0);
final_dist 						: in std_logic_vector (3 downto 0);  
display1	  	 		 		: out std_logic_vector(3 downto 0);
Error_info 						: in std_logic;
light_switch : out std_logic

  ); 
end entity display;

architecture display of display is 


begin 

errorlight: process(Error_clk, Error_info)
	
	begin 
	
	if (Error_info = '1' and Error_clk = '1') then 
	display1 <= "1010"; 
	light_switch <= '1'; 
	
	elsif (Error_info = '1' and Error_clk = '0') then 
	display1 <= "0000"; 
	light_switch <= '1';
	
	elsif (Error_info = '0' and pushbutton = '1') then 
			display1 <= final_dist; 
			light_switch <= '0';
			
	elsif (Error_info = '0' and pushbutton = '0') then 
		display1 <= initial_dist; 
		light_switch <= '0';
	else 
	display1 <= initial_dist; 
		
	end if; 
			
	end process; 
							
end display;