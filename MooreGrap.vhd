library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity MooreGrap IS Port
(
 clk_input, rst_n, togglegrap, enablegrap	: IN std_logic;
 openorclose 										:OUT std_logic
 );
END ENTITY;
 

 Architecture SM of MooreGrap is

 TYPE STATE_NAMES IS (S0, S1);   -- list all the STATE_NAMES values

 
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES


  BEGIN
 
 --------------------------------------------------------------------------------
 --State Machine:
 --------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS:
 
Register_Section: PROCESS (clk_input, rst_n, next_state)  -- this process synchronizes the activity to a clock
BEGIN
	IF (rst_n = '0') THEN
		current_state <= S0;
	ELSIF(rising_edge(clk_input)) THEN
		current_state <= next_State;
	END IF;
END PROCESS;	



-- TRANSITION LOGIC PROCESS

Transition_Section: PROCESS (togglegrap, current_state) 

BEGIN
     CASE current_state IS
         WHEN S0 =>		
				IF(togglegrap='1'AND enablegrap = '1') THEN
					next_state <= S1;
				ELSE
					next_state <= S0;
				END IF;

         WHEN S1 =>		
				IF (togglegrap = '1' and enablegrap = '1') THEN 
					next_state <= S1; 
				ELSE 
					next_state <= S0; 
				END IF; 

		WHEN OTHERS =>
               next_state <= S0;
 		END CASE;
 END PROCESS;

-- DECODER SECTION PROCESS

Decoder_Section: PROCESS ( current_state) 

BEGIN
     CASE current_state IS
         WHEN S0 =>		--extout, enclock, ret0_ext1, grapen
			openorclose 		<= '0';

			
         WHEN S1 =>		
			openorclose 		<= '1';

				
         WHEN others =>		
 			openorclose 		<= '0';

	  END CASE;
 END PROCESS;

 END ARCHITECTURE SM;