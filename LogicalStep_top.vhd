
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


ENTITY LogicalStep_Lab4_top IS
   PORT
	(
   clkin_50			: in	std_logic;
	rst_n			: in	std_logic;
	pb				: in	std_logic_vector(3 downto 0);
 	sw   			: in  std_logic_vector(7 downto 0); 	-- The switch inputs
	leds			: out std_logic_vector(7 downto 0);		-- for displaying the switch content
	seg7_data 		: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  	: out	std_logic;							-- seg7 digi selectors
	seg7_char2  	: out	std_logic							-- seg7 digi selectors
	);
END LogicalStep_Lab4_top;

-------------------------------------------------------------------------------------

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS

--Components 


Component Bidir_shift_reg port 
	(
        CLK		     	: in  std_logic := '0';
        RESET_n      	: in  std_logic := '0';
		CLK_EN			: in  std_logic := '0';
		LEFT0_RIGHT1	: in std_logic  :='0';
 		REG_BITS		: out	std_logic_vector(3 downto 0)
    );
   end Component;
	
---------------------------------------------------------------------

Component Bin_Counter4bit port --Bin_Counter4bit
(
	Clock_main : in std_logic := '0';
	reset : in std_logic := '0';
	clk_en : in std_logic := '0';
	up1_down0 : in std_logic := '0';
	counter_bits : out std_logic_vector(3 downto 0)
);
end Component;
---------------------------------------------------------------------
	
Component compx4 port
	(
		Operand_A 	: in std_logic_vector(3 downto 0);
		Operand_B 	: in std_logic_vector(3 downto 0);
		
		A_equals_B	: out std_logic;
		A_greater_B	: out std_logic;
		A_lesser_B	: out std_logic
	
	);
	
end Component;

---------------------------------------------------------------------

Component segment7_mux port 
	(
		clk        : in  std_logic := '0';
		DIN2 		: in  std_logic_vector(6 downto 0);	
		DIN1 		: in  std_logic_vector(6 downto 0);
		DOUT			: out	std_logic_vector(6 downto 0);
		DIG2			: out	std_logic;
		DIG1			: out	std_logic
        );
end Component; 

-----------------------------------------------------------------------

Component SevenSegment port 
(  
   hex	   	:  in  std_logic_vector(3 downto 0);   -- The 4 bit data to be displayed
   sevenseg :  out std_logic_vector(6 downto 0)    -- 7-bit outputs to a 7-segment
); 
end Component;

--------------------------------------------------------------------------
--Mealy

component Mealy port(
clk, rst_n : in std_logic;

X_EQ, X_GT, X_LS : in std_logic;

Y_EQ, Y_GT, Y_LS: in std_logic;

X_Motion, Y_Motion : in std_logic;

Extender_Out : IN std_logic;

Clk_en_X, Clk_en_Y : out std_logic;

Extender_Enable : out std_logic;

Error : out std_logic;

Up_Down_X, Up_Down_Y : out std_logic

);

END component;

---------------------------------------------------------------------------

--Moore State Machine 1
component MooreEx Port
(
 clk_input, rst_n, toggleex, enableex	: IN std_logic;
 howmuch								: in std_logic_vector(3 downto 0); 
 enclock, ret0_ext1, grapen, Extender_out	: OUT std_logic
 );
END component;

-----------------------------------------------------------------------------

--Moore State Machine 2
component MooreGrap port
(
 clk_input, rst_n, togglegrap, enablegrap	: IN std_logic;
 openorclose 										:OUT std_logic
 );
 
 end component;
--------------------------------------------------------------------------------

--Display Mux
component display port 
(
Error_clk 		: in std_logic; 
pushbutton  		 		: in std_logic;  
initial_dist 					: in std_logic_vector(3 downto 0);
final_dist 						: in std_logic_vector (3 downto 0);  
display1	  	 		 		: out std_logic_vector(3 downto 0);
Error_info 						: in std_logic;
light_switch : out std_logic

  ); 
end component;

----------------------------------------------------------------------------------------------------
	CONSTANT	SIM							:  boolean := FALSE; 	-- set to TRUE for simulation runs otherwise keep at 0.
   CONSTANT CLK_DIV_SIZE				: 	INTEGER := 26;    -- size of vectors for the counters

   SIGNAL 	Main_CLK						:  STD_LOGIC; 			-- main clock to drive sequencing of State Machine

	SIGNAL 	bin_counterX				:  UNSIGNED(CLK_DIV_SIZE-1 downto 0); -- := to_unsigned(0,CLK_DIV_SIZE); -- reset binary counter to zero
	SIGNAL 	bin_counterY				:  UNSIGNED(CLK_DIV_SIZE-1 downto 0);
	
-----------------------------------------------------------------------------------------------------------
-- Signals made by use

signal counterBitsX: std_logic_vector(7 downto 4);

signal counterBitsY: std_logic_vector(3 downto 0);

signal HexX : std_logic_vector(3 downto 0);

signal HexY : std_logic_vector(3 downto 0);

signal Error_Mealy : std_logic;
signal dummy_led: std_logic;

signal Seg7_X : std_logic_vector(6 downto 0);
signal Seg7_Y : std_logic_vector(6 downto 0);


signal X_equals: std_logic;
signal X_great : std_logic;
signal X_less: std_logic;


signal Y_equals: std_logic;
signal Y_great: std_logic;
signal Y_less: std_logic;

signal Ext_Out: std_logic;

signal clock_en_X: std_logic;
signal clock_en_Y : std_logic;

signal Ext_en: std_logic;

signal updownX : std_logic;
signal updownY : std_logic;

signal Shift_en: std_logic;
signal leftright: std_logic;

signal Grapple_en:std_logic;

signal bidirled : std_logic_vector(3 downto 0);

signal pb_bar : std_logic_vector(3 downto 0); 
signal X : std_logic_vector(3 downto 0); 
signal y : std_logic_vector(3 downto 0); 
----------------------------------------------------------------------------------------------------
BEGIN

-- CLOCKING GENERATOR WHICH DIVIDES THE INPUT CLOCK DOWN TO A LOWER FREQUENCY

BinCLKX: PROCESS(clkin_50, rst_n) is
   BEGIN
		IF (rising_edge(clkin_50)) THEN -- binary counter increments on rising clock edge
         bin_counterX <= bin_counterX + 1;
      END IF;
   END PROCESS;

Clock_SourceX:
				Main_Clk <= 
				clkin_50 when sim = FALSE else				            -- for simulations only
				std_logic(bin_counterX(23));								-- for real FPGA operation
				


BinCLKY: PROCESS(clkin_50, rst_n) is
   BEGIN
		IF (rising_edge(clkin_50)) THEN -- binary counter increments on rising clock edge
         bin_counterY <= bin_counterY + 1;
      END IF;
   END PROCESS;

Clock_SourceY:
				Main_Clk <= 
				clkin_50 when sim = FALSE else				            -- for simulations only
				std_logic(bin_counterY(23));								-- for real FPGA operation
				
				
---------------------------------------------------------------------------------------------------


pb_bar <= NOT(pb);
X <= sw(7 downto 4);
Y <= sw(3 downto 0);

--leds mapping 

leds(7 downto 4) <= bidirled; 
--leds(0) <= errorlight; 
---------------------------------------------------------------------------------------------------

INST1 : display port map (Main_CLK, pb_bar(3), X, CounterbitsX, HexX, Error_Mealy, leds(0) );

INST2 : display port map (Main_CLK, pb_bar(2), Y, CounterbitsY, HexY, Error_Mealy, dummy_led );
----------------------------
INST3 : SevenSegment port map (hexX, Seg7_X);

INST4 : SevenSegment port map (hexY, Seg7_Y);

INST5 : segment7_mux port map (clkin_50, Seg7_X, Seg7_Y, seg7_data, seg7_char1, seg7_char2);
-----------------------------
INST6 : compx4 	port map (X, counterbitsX, X_equals, X_great, X_less); 
INST7 : compx4 	port map (Y, counterbitsY, Y_equals, Y_great, Y_less);
------------------------------
INST8  : Mealy port map (Main_Clk, rst_n, X_equals, X_great, X_less, Y_equals, Y_great, Y_less, pb_bar(3), pb_bar(2), Ext_Out, clock_en_X, clock_en_Y, Ext_en, Error_Mealy, updownX, updownY);	

INST9 : Bin_Counter4bit port map (Main_Clk, rst_n, clock_en_X, updownX, counterbitsX);	
INST10 : Bin_Counter4bit port map (Main_Clk, rst_n, clock_en_Y, updownY, counterbitsY);	

-------------------------------
INST11 : MooreEx port map (Main_Clk, rst_n, pb_bar(1), Ext_en, bidirled, Shift_en, leftright, Grapple_en, Ext_Out);	
	
INST12 : Bidir_shift_reg port map (Main_clk, rst_n, Shift_en, leftright, bidirled);
-------------------------------

INST13 : MooreGrap port map (Main_Clk, rst_n, pb_bar(0), Grapple_en, leds(3));						
---------------------------------------------------------------------------------------------------

END SimpleCircuit;
