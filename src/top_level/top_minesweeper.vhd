--------------------------------------------------------------------------------
--
-- Title       : top_minesweeper.vhd
-- Design      : VGA
-- Author      : Kapitanov
-- Company     : InSys
-- 
-- Version     : 1.0
--------------------------------------------------------------------------------
--
-- Description : Top level for VGA controller ver. 1.0 based on Spartan3E Starter Kit
-- 
-- Xilinx Spartan3e - XC3S500E-4FG320C 
-- Switches, LEDs, VGA 640x480, Keyboard
--
-- SW<0> - RESET
-- SW<1> - ENABLE
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity top_minesweeper is
	generic	( 
		CHIPSCOPE_USE : boolean:=false
	);
	port(
		---- PS/2 IO ----
		PS2_CLK		:  in	std_logic;	-- CLK FROM PS/2 KEYBOARD
		PS2_DATA	:  in	std_logic;	-- DATA FROM PS/2 KEYBOAD	
		---- CLOCK 50 MHz ----
		CLK			:  in   std_logic;	-- MAIN CLOCK
		---- VGA SYNC ----
		VGA_HSYNC	:  out  std_logic;  -- Horiztonal sync
		VGA_VSYNC	:  out  std_logic;  -- Vertical sync
		VGA_R		:  out	std_logic;	-- RED
		VGA_G		:  out	std_logic;	-- GREEN
		VGA_B		:  out	std_logic;	-- BLUE
		---- LED Display ----
		LEDX		:  out	std_logic_vector(7 downto 0);	-- LEDs
		LEDY		:  out	std_logic_vector(7 downto 0);	-- LEDs	
		---- SWITCHES ----
--		SW			:  in	std_logic_vector(7 downto 2);	-- SWITCHES
		RESET		:  in   std_logic;  -- Asycnchronous reset: SW(0)
--		ENABLE		:  in	std_logic;	-- Enable logic: SW(1)
		---- BUTTONS ----
--		KB			:  in	std_logic_vector(5 downto 1); -- BUTTONS
		---- DOORBELL ----
		BELL		:  out	std_logic-- BELL
		);
end top_minesweeper;

architecture top_minesweeper of top_minesweeper is

------------- COMPONENT Declaration ------
 
signal ps2_clock	: std_logic;
signal ps2_din		: std_logic;

signal reset_vga	: std_logic;
signal rst			: std_logic;

signal RGB			: std_logic_vector(2 downto 0);

signal clk_fb		: std_logic;
signal clk0			: std_logic;
signal clk_in		: std_logic;
signal locked		: std_logic;
signal clk_dv		: std_logic;
signal rst_dcm		: std_logic;

signal v, h			: std_logic;

signal leds			: std_logic_vector(8 downto 1);

component ctrl_main_block is
	port(
		-- system signals
		reset		:  in	std_logic;	-- SW(0)
		clk			:  in   std_logic;	-- Pixel clk - DCM should generate 25 MHz freq;  
		-- ps/2 signals
		ps2_clk		:  in	std_logic;	-- PS/2 CLOCK
		ps2_data	:  in	std_logic;	-- PS/2 SERIAL DATA
		-- vga output signals
		h_vga		:  out	std_logic;	-- horizontal
		v_vga		:  out	std_logic;	-- vertical	
		rgb			:  out	std_logic_vector(2 downto 0); -- (R-G-B)
		-- test leds signals
		leds		:  out	std_logic_vector(8 downto 1)
		);
end component;

begin

x_MAIN_BLOCK : ctrl_main_block
	port map(
		clk			=> clk_dv,	-- 25 MHz freq;  
		reset		=> reset_vga,	
		
		ps2_clk		=> ps2_clock,
		ps2_data	=> ps2_din,
		
		h_vga		=> H,
		v_vga		=> V,
		rgb			=> RGB,
		
		leds		=> LEDS
	);
	
---------------- I/O BUFFERS ----------------

ps2c: ibuf port map(i => ps2_clk,  o => ps2_clock);
ps2d: ibuf port map(i => ps2_data, o => ps2_din);	

xreset: ibuf port map(i => reset, o => rst);
--
xBELL:	obuf port map(i => '1', o => BELL);

xVGA_v:	obuf port map(i => v, o => VGA_VSYNC);
xVGA_h:	obuf port map(i => h, o => VGA_HSYNC);	
	
xVGA_R:	obuf port map(i => RGB(2), o => VGA_R);
xVGA_G:	obuf port map(i => RGB(1), o => VGA_G);
xVGA_B:	obuf port map(i => RGB(0), o => VGA_B);


LEDX <= leds;
LEDY <= leds;

-- DCM CLK :
xclkfb:	bufg port map(i => clk0, o => clk_fb);
xclkin:	ibufg port map(i => clk,o => clk_in);

xsrl_reset: SRLC16
	generic map (
		init => x"0000"
	)
	port map(
		Q15	=> reset_vga,
		A0		=> '1',
		A1		=> '1',
		A2		=> '1',
		A3		=> '1',
		CLK	=> clk_in,
		D		=> rst -- '1',
	);	

rst_dcm <= not rst;	

xDCM_CLK_VGA : dcm
generic map(
		--DCM_AUTOCALIBRATION 	=> FALSE,	-- DCM ADV
		CLKDV_DIVIDE 			=> 2.0,		-- clk divide for CLKIN: Fdv = Fclkin / CLK_DIV
		CLKFX_DIVIDE 			=> 2,		-- clk divide for CLKFX and CLKFX180 : Ffx = (Fclkin * MULTIPLY) / CLKFX_DIV
		CLKFX_MULTIPLY 			=> 2,		-- clk multiply for CLKFX and CLKFX180 : Ffx = (Fclkin * MULTIPLY) / CLKFX_DIV
		CLKIN_DIVIDE_BY_2 		=> FALSE,	-- divide clk / 2 before DCM block
		CLKIN_PERIOD 			=> 20.0,	-- clk period in ns (for DRC)
		CLKOUT_PHASE_SHIFT 		=> "NONE",	-- phase shift mode: NONE, FIXED, VARIABLE		
		CLK_FEEDBACK 			=> "1X",	-- freq on the feedback clock: 1x, 2x, None
		DESKEW_ADJUST 			=> "SYSTEM_SYNCHRONOUS",	-- clk delay alignment
		DFS_FREQUENCY_MODE 		=> "LOW",	-- freq mode CLKFX and CLKFX180: LOW, HIGH
		DLL_FREQUENCY_MODE 		=> "LOW",	-- freq mode CLKIN: LOW, HIGH
		DUTY_CYCLE_CORRECTION 	=> TRUE,	-- 50% duty-cycle correction for the CLK0, CLK90, CLK180 and CLK270: TRUE, FALSE
		PHASE_SHIFT			 	=> 0		-- phase shift (with CLKOUT_PHASE_SHIFT): -255 to 255 
	)
	port map(
		clk0 		=> clk0,
--		clk180 		=> clk180,
--		clk270 		=> clk270,
--		clk2x 		=> clk2x,
--		clk2x180 	=> clk2x180,
--		clk90 		=> clk90,
		clkdv 		=> clk_dv,
--		clkfx 		=> clkfx,
--		clkfx180 	=> clkfx180,
		locked 		=> locked,
--		status 		=> status,
--		psdone 		=> psdone,	

		clkfb 		=> clk_fb,
		clkin 		=> clk_in,
--		dssen 		=> dssen,
--		psclk 		=> psclk,
		psen 		=> '0',
		psincdec 	=> '0',
		rst 		=> rst_dcm
	);

end top_minesweeper;