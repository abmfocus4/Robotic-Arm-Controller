library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity compx4 is port(
	Operand_A 	: in std_logic_vector(3 downto 0);
	Operand_B 	: in std_logic_vector(3 downto 0);
	
	A_equals_B	: out std_logic;
	A_greater_B	: out std_logic;
	A_lesser_B	: out std_logic
	
	);
	
end entity compx4;

architecture Comp4 of compx4 is 
--COMPONENT USED--
--------------------------------------------

component Compx1 port(

	A			: in std_logic;
	B			: in std_logic;
	
	greater	: out std_logic;
	equals	: out std_logic;
	lesser	: out std_logic
);
end component;


----------------------------------
--SIGNAL CREATION--
----------------------------------

signal greater3: std_logic;
signal equals3: std_logic;
signal lesser3 : std_logic;

signal greater2: std_logic;
signal equals2: std_logic;
signal lesser2 : std_logic;

signal greater1: std_logic;
signal equals1: std_logic;
signal lesser1: std_logic;

signal greater0: std_logic;
signal equals0: std_logic;
signal lesser0: std_logic;

----------------------------------
begin 

INST1: Compx1 port map (Operand_A(3), Operand_B(3),greater3,equals3,lesser3);
INST2: Compx1 port map (Operand_A(2), Operand_B(2),greater2,equals2,lesser2);
INST3: Compx1 port map (Operand_A(1), Operand_B(1),greater1,equals1,lesser1);
INST4: Compx1 port map (Operand_A(0), Operand_B(0),greater0,equals0,lesser0);

A_greater_B <= greater3 OR (equals3 AND greater2) OR (equals3 AND equals2 AND greater1) OR (equals3 AND equals2 AND equals1 AND greater0);
A_lesser_B <= lesser3 OR (equals3 AND lesser2) OR (equals3 AND equals2 AND lesser1) OR (equals3 AND equals2 AND equals1 AND lesser0);
A_equals_B <= equals3 AND equals2 AND equals1 AND equals0;

end Comp4;


	
