
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

                     
entity Mealy is port(

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

end entity Mealy;

architecture Mealy of Mealy is 

TYPE STATE_NAMES IS (Stationary, In_Motion, Warning);   	-- list all the STATE_NAMES values


 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES
signal x_comp: std_logic_vector(2 downto 0); 
signal y_comp: std_logic_vector(2 downto 0); 

begin

 --------------------------------------------------------------------------------
 --State Machine:
 --------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS:

Register_Section: PROCESS (clk, rst_n, next_state)  -- this process synchronizes the activity to a clock
BEGIN
	IF (rst_n = '0') THEN
		current_state <= Stationary;
	ELSIF(rising_edge(clk)) THEN
		current_state <= next_State;
	END IF;
END PROCESS;

X_comp <= (X_EQ & X_GT & X_LS);
Y_comp <= (Y_EQ & Y_GT & Y_LS);


-----------------------------------------------------------------------------------------

Transition_Section: PROCESS (current_state, x_motion, y_motion, x_comp, y_comp, Extender_Out)
BEGIN
     CASE current_state is
	 
         WHEN Stationary =>
				IF((x_motion = '1' or y_motion = '1') and (Extender_Out = '0')) THEN
					next_state <= In_Motion;
					
				elsif((x_motion = '1' or y_motion = '1') and (Extender_Out = '1')) then
					next_state <= Warning;
					
					ELSE
					next_state <= Stationary;
				END IF;
				
				
------------------------------------------------------------
			WHEN In_Motion =>
				if ((x_comp = "100" and y_comp = "100") or (x_motion = '0' and y_motion = '0')) then
					next_State <= stationary;
				
				elsif(Extender_Out = '1' and (x_motion = '1' or y_motion = '1')) then
					next_State <= Warning;
					
				else
					next_State <= In_Motion;
					end if;
	------------------------------------------------------------
	
			WHEN Warning =>
				if(Extender_Out = '1') then
					next_State <= Warning;
				else
					next_State <= Stationary;
				end if;
				
				
			end case;
			
			
	end Process;

	----------------------------------------------------------------------------------------
	Mealy_Decoder_Section: PROCESS (current_state, x_motion, y_motion, x_comp, y_comp, Extender_Out)

BEGIN
------------------------------------------------------------------------------------------------
    IF (current_state = Stationary) THEN --stationary
        if ((x_motion = '1' and x_comp(2) = '1') or (x_motion = '0')) then 
		Clk_en_X <= '0'; 
		else 
		Clk_en_X <= '1'; 
		end if; 
		----------------------
		if ((y_motion = '1' and y_comp(2) = '1') or (y_motion = '0')) then 
		Clk_en_y <= '0'; 
		else 
		Clk_en_Y <= '1'; 
		end if; 
		----------------------
		if ((x_comp(2) = '1') and (y_comp(2) = '1')) then 
		Extender_Enable <= '1'; 
		else 
		Extender_Enable <= '0'; 
		end if; 
		----------------------
		error <= '0'; 
	END If; 
	
	
---------------------------------------------------------------------------------------
	IF (current_state = In_Motion) THEN --In_Motion
		
		if (x_comp(2) = '0' and x_motion = '1') then 
		Clk_en_X <= '1'; 
		else 
			Clk_en_X <= '0'; 
		end if; 
		-----------------------
		if (y_comp(2) = '0' and y_motion = '1') then 
		Clk_en_Y <= '1'; 
		else 
		Clk_en_Y <= '0'; 
		end if; 
		-----------------------
		if (x_comp(1) = '0') then --x
		Up_Down_X <= '1'; 
		
		elsif (x_comp(0) = '0') then 
		Up_Down_X <= '0'; 
		
		elsif (x_comp(2) = '1') then 
		Up_Down_X <= '0'; 
		end if; 
		-----------------------
		if (y_comp(1) = '0') then --y
		Up_Down_y <= '1'; 
		
		elsif (y_comp(0) = '0') then 
		Up_Down_y <= '0'; 
		
		elsif (y_comp(2) = '1') then 
		Up_Down_y <= '0'; 
		end if; 

---------------------------------------------------------------------------------------
	ELSIF (current_state = Warning) THEN
		Error <= '1'; 
		Extender_Enable <= '0';
---------------------------------------------------------------------------------------
    ELSE  
		--Extender_Enable <= '1';
		Clk_en_X <= '0'; 
		Clk_en_Y <= '0'; 
		Extender_Enable <= '0'; 
    END IF;

 END PROCESS;

 END ARCHITECTURE Mealy;























