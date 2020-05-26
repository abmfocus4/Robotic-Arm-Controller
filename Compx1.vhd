library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

entity Compx1 is port (

	A			: in std_logic;
	B			: in std_logic;
	
	greater	: out std_logic;
	equals	: out std_logic;
	lesser	: out std_logic
	);
	
end entity Compx1;

architecture Comp of Compx1 is 
begin 
	
	greater <= A AND NOT(B);
	equals <= A XNOR B;
	lesser <= NOT(A) AND B;
	
	
	
end Comp;
	