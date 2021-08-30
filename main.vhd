----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:09:45 06/22/2021 
-- Design Name: 
-- Module Name:     - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;
use std.textio.all;

--use ieee.numeric_bit.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
 
port(
	clk : in std_logic;
	output : out std_logic
);
end main;

architecture Behavioral of main is

constant row : integer range 0 to 255 := 65;
constant col : integer range 0 to 255 := 100;

type memory is array (0 to (row*col)-1) of std_logic_vector (7 downto 0);
type hist_arr is array (0 to 255) of std_logic_vector(12 downto 0);
type map_arr is array (0 to 255) of std_logic_vector(20 downto 0);
type intensity_arr is array (0 to 255) of std_logic_vector(7 downto 0);

function Init_Ram (FileName : in string) return memory is

	File file1 : text is in FileName;
	variable line1 : line;
	variable RAM1 : memory;
	variable temp_row : bit_vector(7 downto 0);
	variable status : boolean;
	
begin 
	for i in 0 to (memory'length) - 1
	loop
		readline(file1,line1);
		read(line1,temp_row);
		RAM1(i):=to_stdlogicvector(temp_row);
	end loop; 
	return RAM1; 
end function;



--signal RAM:memory;
signal sig_RAM:memory:= Init_Ram("pixels.txt");
--procedure file_write(FileName : in String) is

file ramfile_wr : text;
--begin
--;
--end procedure;

type state is (start,calculate_hist,cumulative_hist, mapping,division, cast, write_file,ending);
signal mode : state := start;
--signal len_std:std_logic_vector(20 downto 0):=conv_std_logic_vector((row*col),21);


begin
process(clk,sig_RAM)

variable ramFileLine_wr : line;

variable RAM:memory:= sig_RAM;
variable cum_hist:hist_arr;
variable hist:hist_arr;
variable map_hist:map_arr;
variable x:integer:=61;
variable tmp:std_logic_vector(12 downto 0);
variable tmpp:std_logic_vector(20 downto 0):="111111111111111111111";
variable hist_index:integer:=0;
variable ram_index:integer:=0;

variable i_std:std_logic_vector(7 downto 0);
variable quotient:std_logic_vector(7 downto 0):="00000000";
variable len:integer;--:=(row*col);
variable intensity:intensity_arr;
variable out_var:std_logic:='0';
variable map_var:std_logic_vector(20 downto 0);
variable len_std:std_logic_vector(20 downto 0);--:=conv_std_logic_vector((row*col),21);
variable line2 : line;
variable data : integer;
begin
if(clk'event and clk='1') then
case mode is
when start=>
	--RAM<= Init_Ram("p.txt");
	hist(hist_index):="0000000000000";
	len:=(row*col);
	--len_std:=conv_std_logic_vector(len,21);
	mode<=calculate_hist;
when calculate_hist =>

	if(hist_index>=256) then
		hist_index:=0;
		ram_index:=0;
		cum_hist(hist_index):="0000000000000";
		mode<=cumulative_hist;
	else
		
		if(ram_index>=(row*col)) then
			 
			 hist_index:=hist_index+1;
			 ram_index:=0;

			 if(hist_index<=255) then
				hist(hist_index):="0000000000000";
				end if;
		 else
			i_std:=conv_std_logic_vector(hist_index,8);
	
			if(RAM(ram_index)=i_std)
			then
				--out_var:="0000000000000";
				
				hist(hist_index):=hist(hist_index)+"0000000000001";
				
			end if;
			ram_index:=ram_index+1;
		end if;
	
	end if;

	
	
when cumulative_hist =>

--	out_var:=hist(120);
	if(hist_index=0) then
		cum_hist(hist_index):=hist(hist_index);
		hist_index:=hist_index+1;
		if(hist_index<=255) then
		cum_hist(hist_index):="0000000000000";
		end if;
	elsif(  hist_index<=255) then
		cum_hist(hist_index):=hist(hist_index);
		hist_index:=hist_index-1;
		tmp:=cum_hist(hist_index);
		hist_index:=hist_index+1;
		cum_hist(hist_index):=cum_hist(hist_index)+tmp;
		hist_index:=hist_index+1;
	
	elsif(hist_index>=256) then
		hist_index:=0;
		ram_index:=0;
	   mode<=mapping;
	end if;
	
when mapping =>
--	out_var:=cum_hist(120);

	if(hist_index>=256) then
		hist_index:=0;
		ram_index:=0;
	   mode<=division;
	elsif(hist_index<=255) then
	map_var:="000000000000000000000";
	map_var(20 downto 8):=cum_hist(hist_index);
		map_hist(hist_index):= map_var;
		--out_var:=map_hist(hist_index);
		hist_index:=hist_index+1;
	end if;
	
when division =>

	--out_var:=map_hist(120);

	if(hist_index>=256) then
		hist_index:=0;
		ram_index:=0;
	   mode<=cast;
	elsif(hist_index<=255) then
		if(hist_index=255) then
				quotient:="11111111";
				map_hist(hist_index):="000000000000000000000";
			end if;
			----------------------------------------------------------------------------------------------------------------------
		if(map_hist(hist_index)>=conv_std_logic_vector(len,21)) then
			
			
				map_hist(hist_index):=std_logic_vector(unsigned(map_hist(hist_index)-conv_std_logic_vector(len,21)));
				--map_hist(hist_index):="000000000000000000000";
				if('0' & quotient < "011111111") then
					quotient:=quotient+"00000001";
				end if;
	
			
		else
			intensity(hist_index):=quotient;
			
			
			hist_index:=hist_index+1;
			
			--if(hist_index<=255) then
				--if( tmpp=map_hist(hist_index)) then
				--	intensity(hist_index):=quotient;
					--map_hist(hist_index):="000000000000000000000";
				--else
				quotient:="00000000";
				--end if;
				--tmpp:=map_hist(hist_index);

			--end if;


		
		end if;
	end if;
	
when cast =>
		

	--out_var:="11111111";
	hist_index:=conv_integer(unsigned(RAM(ram_index)));
	RAM(ram_index):=intensity(hist_index);
	ram_index:=ram_index+1;
	if(ram_index>=(row*col)) then
		
	   mode<=write_file;
		
	end if;
	
	


when write_file=>

-------------------------------------------------important-------------------------------
	--uncomment this part for implementation to get reults in p_out.txt and comment it for synthesize
	--file_open(ramfile_wr,"p_out.txt",write_mode);
	--for i in 0 to (memory'length) -1 loop
		--write(ramFileLine_wr,conv_integer(RAM(i)));
		--writeline(ramfile_wr,ramFileLine_wr);
	--end loop; 
	--file_close(ramfile_wr);
	
	out_var:='1';
	mode<=ending;	
when ending=>

end case;

end if;
output<=out_var;

end process;


end Behavioral;

