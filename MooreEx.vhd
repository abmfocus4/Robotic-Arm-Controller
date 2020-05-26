library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity MooreEx IS Port
(
 clk_input, rst_n, toggleex, enableex	: IN std_logic;
 howmuch								: in std_logic_vector(3 downto 0); 
 enclock, ret0_ext1, grapen, Extender_out	: OUT std_logic
 );
END ENTITY;
 

 Architecture SM of MooreEx is

 TYPE STATE_NAMES IS (Retracted, Retracting, Extended, Extending);   -- list all the STATE_NAMES values

 
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES


  BEGIN
 
 --------------------------------------------------------------------------------
 --State Machine:
 --------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS:
 
Register_Section: PROCESS (clk_input, rst_n, next_state)  -- this process synchronizes the activity to a clock
BEGIN
	IF (rst_n = '0') THEN
		current_state <= Retracted;
	ELSIF(rising_edge(clk_input)) THEN
		current_state <= next_State;
	END IF;
END PROCESS;	



-- TRANSITION LOGIC PROCESS

Transition_Section: PROCESS (toggleex, enableex, current_state) 

BEGIN
     CASE current_state IS
	  
         WHEN Retracted =>		
				IF(toggleex='1' AND enableex ='1') THEN
					next_state <= Extending;
				ELSE
					next_state <= Retracted;
				END IF;

				
		WHEN Retracting =>
		if (howmuch="0000") then
			next_State<= Retracted;	
		else
			next_State<= Retracting;
		END IF;
		
					
		when Extended =>
			if(toggleex = '1') then
				next_State <= Retracting;
			else
				next_State <= Extended;
			end if;
		
		
         WHEN Extending =>		
				IF (howmuch = "1111") THEN 
					next_state <= Extended; 
				else
					next_state <= Extending; 
				END IF; 
			
		
		WHEN OTHERS =>
               next_state <= Retracted;
 		END CASE;
 END PROCESS;

-- DECODER SECTION PROCESS

Decoder_Section: PROCESS (current_state) 

BEGIN
     CASE current_state IS
         WHEN Retracted =>		--extout, enclock, ret0_ext1, grapen
			enclock 	<= '1';
			ret0_ext1	<= '0';
			grapen 		<= '0';
			Extender_out <= '0';
			 
			
         WHEN Retracting =>		
			enclock 	<= '1';
			ret0_ext1	<= '1';
			grapen 		<= '0';
			Extender_out <= '1';

         WHEN Extended =>		
			enclock 	<= '1';
			ret0_ext1	<= '1';
			grapen 		<= '1';
			Extender_out <= '1';
			
         WHEN Extending =>		
			enclock 		<= '1';
			ret0_ext1	<= '1';
			grapen 		<= '0'; 
			Extender_out <= '1';

         WHEN others =>		
			enclock 	<= '1';
			ret0_ext1	<= '0';
			grapen 		<= '0';
			Extender_out <= '0';
			
			
	  END CASE;
 END PROCESS;

 END ARCHITECTURE SM;
