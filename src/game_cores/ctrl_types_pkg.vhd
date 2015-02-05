--------------------------------------------------------------------------------
--
-- Title       : ctrl_types_pkg.vhd
-- Design      : VGA
-- Author      : Kapitanov
-- Company     : InSys
-- 
-- Version     : 1.0
--------------------------------------------------------------------------------
--
-- Description : Main types and components
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package ctrl_types_pkg is
	
	type data8x8		is array (7 downto 0) of std_logic_vector(7 downto 0);
	type data3x8		is array (7 downto 0) of std_logic_vector(2 downto 0);

	type array8x1		is array (7 downto 0) of std_logic;
	type array8x8		is array (7 downto 0) of array8x1;
	
	type key_data is record
		WSAD		: std_logic_vector(3 downto 0); 	
		ENTER		: std_logic;	
		SPACE		: std_logic;
		ESC			: std_logic;
		kY			: std_logic;
		kN			: std_logic;	
	end record;	
	
	component ctrl_key_decoder is
		port(
			-- system signals	
			clk		:  in 	std_logic;		-- SYSTEM CLOCK
			-- keyboard in: 
			ps2_clk	:  in 	std_logic;		-- PS/2 CLK
			ps2_data:  in	std_logic;		-- PS/2 DATA		
			-- keyboard out: 
			keys_out	:  out	key_data;	-- KEY DATA
			new_key		:  out	std_logic	-- DETECT NEW KEY
		);
	end component;
	
	component vga_ctrl640x480 is
		port(
			clk		:  in   std_logic;	-- pixel clk - DCM should generate 25 MHz freq;  
			reset	:  in   std_logic;  -- asycnchronous reset
			h_sync	:  out  std_logic;  -- horiztonal sync pulse
			v_sync	:  out  std_logic;  -- vertical sync pulse
			disp	:  out  std_logic;	-- display enable '1'
			x_out	:  out	std_logic_vector(9 downto 0);	-- x axis
			y_out	:  out  std_logic_vector(8 downto 0)	-- y axis
		);
	end component;	
	
	component ctrl_game_block is
		port(
			-- system signals:
			clk			:  in 	std_logic;
			reset		:  in	std_logic;
			-- keyboard: 
			push_keys	:  in	key_data;
			-- vga XoY coordinates:
			display		:  in	std_logic;
			x_char		:  in	std_logic_vector(9 downto 0); -- X line: 0:79
			y_char		:  in	std_logic_vector(8 downto 0); -- Y line: 0:29
			-- out color scheme:
			rgb			:  out	std_logic_vector(2 downto 0);
			leds		:  out	std_logic_vector(8 downto 1)
		);
	end component;	
  
end ctrl_types_pkg;