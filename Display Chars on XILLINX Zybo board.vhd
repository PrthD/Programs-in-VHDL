----------------------------------------------------------------------------------
-- Company:     University of Alberta
-- Engineer:    Behdad Goodarzy
-- 
-- Create Date: 10/18/2021 09:43:23 AM
-- Design Name: ECE210 - lab3 parts 3 & 4
-- Module Name: SevenSegments - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SevenSegments2digits is
    Port ( 
            clk:        in STD_LOGIC;                                       					--clk
            CC :        out STD_LOGIC;                                      					--Common cathode input to select respective 7-segment digit.
            out_7seg :  out STD_LOGIC_VECTOR (6 downto 0));                 					--Other 7 inputs for 7-segment digits
end SevenSegments2digits;

architecture Behavioral of SevenSegments2digits is
--constants
constant clk_divider_forOneHz :positive :=128000000;											--128000000 for implementation 				--3 for testbench		--used for generating 1Hz from internal clk for counter
constant clk_divider_for7seg :positive :=640000;												--640000 for implementation 				--1 for testbench		--used for generating 100Hz from internal clk for SevenSegments
constant countwidth :positive :=32;																--32 for implementation 					--8 for testbench
constant max_SevenSeg_Count :positive :=12;								    					--last 2 digits of your student ID
--signals
signal count: std_logic_vector(countwidth-1 downto 0);											--for generating 1Hz from internal clk for up counting
signal count_7seg: std_logic_vector(countwidth-1 downto 0);										--for generating 200Hz from internal clk for 7segments
signal clk_out_7seg: std_logic:='0';															--Clock used as the control signal for 
signal SevenSeg_Count: integer range 0 to max_SevenSeg_Count;
signal SevenSeg_show: std_logic_vector(7 downto 0);						    					--8-bit vector, 4 MSBs would be the first digit and 4 LSBs would be the second digit counter in decimal

begin

    CLK_Gen: process(clk)																		--Process will generate Clocks used for up counting 1Hz and 7Segmant CC 128Hz
																								--SevenSeg_Count every (clk_divider_forOneHz) should increase. If SevenSeg_Count is equal to max_SevenSeg_Count it should go back to 0
    begin
		if rising_edge(clk) then
			--write you code here
			
			--**This first if statement downconverts the 128MHz system clock signal to a 1Hz signal, this allows you to perform some other code once per second
			--**The first if condition should "count" 128 million clock ticks (i.e. the number of clock ticks per second)
			if (count <clk_divider_foroneHz) then 
			    count  <= count + '1';
			else
				--**The "count" should be reset to zero so this code can run again once another 128 million ticks has passed
				count<=(others =>'0');
				
				--**This if statement should increment the variable being used to keep track of the "count" to be displayed on the "Seven seg" display
				--**Take note of the variable type used to keep track of this value. Recall the difference between syntax for assigning integers and boolean variables in VHDL
				if (SevenSeg_Count < max_SevenSeg_count) then
					SevenSeg_Count <= SevenSeg_Count + 1 ;
				else
				--**The "count" on the "Seven seg" display should reset to zero once you've reached your target end number so it will repeat all over again
					SevenSeg_Count <= 0 ;
				end if;    
			end if;		     

			--**Since we need to display on both the left display for the 10s place and the right display for the 1s place, we need to switch between displaying on each screen at some fairly fast and inperceptible frequency
			--**Here, similar to the earlier 1Hz generation, to update the "7 seg" display, we will "count" 640 thousand clock ticks to access the else conditon once every 5ms (i.e. at 200Hz)
			if (count_7seg < clk_divider_for7seg) then
				count_7seg <= count_7seg +'1' ;
			else
			--**Reset this "count" to zero so that the other "7 seg" dispay can be updated every 5ms
				count_7seg <= (others => '0') ;
				
			--**This variable is analogous to CC in Pt 1 and Pt2 to switch between the two displays	
				clk_out_7seg <= not clk_out_7seg;
			end if;
		end if;
		
    end process;
    
    decimal_to_binary: process (SevenSeg_Count)	            									--SevenSeg_show is 8 bits, write a code to show 4 MSBs on the left 7segmentand 4 LSBs on right 7segment.
																								--SevenSeg_Count is an integer that needs to be converted to a vector format
	    begin
	       SevenSeg_show(7 downto 4) <= std_logic_vector(to_unsigned(SevenSeg_Count / 10,4));	--first digit of the last 2-digits of student ID is assigned to SevenSeg_show(7 downto 4)
	       SevenSeg_show(3 downto 0) <= std_logic_vector(to_unsigned(SevenSeg_Count rem 10,4));	--second digit of the last 2-digits of student ID is assigned to SevenSeg_show(7 downto 4)
        end process;
        
    Decoder_8bitsto2SevenSegments: process (clk_out_7seg, SevenSeg_show)						--SevenSeg_show is 8 bits, write a code to show 4 MSBs on the left 7segmentand 4 LSBs on right 7segment.
																								--Hint: While clk_out_7seg is '1' you are displaying 4 digits on one segment and while it is '0' you are displaying on the other one.
        begin																					--Here students can call a component from part 2 of the lab
		
		-- **The code you must write here will look very similar to your code for Pt 2
		-- **Change sw to either SevenSeg_show(7 downto 4) or SevenSeg_show(3 downto 0) depending on if you want to update the 10s place or the 1s place respectively
		-- **At the end of this process block, remember to set CC to either 0 or 1 in order to switch between the two displays
		
		    if (SevenSeg_show(3 downto 0)="0000") then out_7seg <= "0111111";
            elsif (SevenSeg_show(3 downto 0)="0001") then out_7seg <= "0000110";
            elsif (SevenSeg_show(3 downto 0)="0010") then out_7seg <= "1011011";
            elsif (SevenSeg_show(3 downto 0)="0011") then out_7seg <= "1001111";
            elsif (SevenSeg_show(3 downto 0)="0100") then out_7seg <= "1100110";
            elsif (SevenSeg_show(3 downto 0)="0101") then out_7seg <= "1101101";
            elsif (SevenSeg_show(3 downto 0)="0110") then out_7seg <= "1111101";
            elsif (SevenSeg_show(3 downto 0)="0111") then out_7seg <= "0000111";
            elsif (SevenSeg_show(3 downto 0)="1000") then out_7seg <= "1111111";
            elsif (SevenSeg_show(3 downto 0)="1001") then out_7seg <= "1101111";
            else out_7seg <= "0000000";
            end if;
        CC <= '0';
        
            if (SevenSeg_show(7 downto 4)="0000") then out_7seg <= "0111111";
            elsif (SevenSeg_show(7 downto 4)="0001") then out_7seg <= "0000110";
            elsif (SevenSeg_show(7 downto 4)="0010") then out_7seg <= "1011011";
            elsif (SevenSeg_show(7 downto 4)="0011") then out_7seg <= "1001111";
            elsif (SevenSeg_show(7 downto 4)="0100") then out_7seg <= "1100110";
            elsif (SevenSeg_show(7 downto 4)="0101") then out_7seg <= "1101101";
            elsif (SevenSeg_show(7 downto 4)="0110") then out_7seg <= "1111101";
            elsif (SevenSeg_show(7 downto 4)="0111") then out_7seg <= "0000111";
            elsif (SevenSeg_show(7 downto 4)="1000") then out_7seg <= "1111111";
            elsif (SevenSeg_show(7 downto 4)="1001") then out_7seg <= "1101111";
            else out_7seg <= "0000000";
            end if;
        CC <= '1';
        
 
            
    end process;
    
end Behavioral;