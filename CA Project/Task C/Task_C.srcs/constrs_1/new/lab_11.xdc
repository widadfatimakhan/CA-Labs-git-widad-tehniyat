## ============================================================================
## Project Task C - Constraint File for Digilent Basys3 (Artix-7)
## Top module: TopLevelFPGA
##
## Maps:
##   clk         -> W5  (100 MHz on-board oscillator)
##   reset       -> U18 (BTNC center button)
##   switch_in   -> 16 sliding switches SW0..SW15
##   leds        -> 16 LEDs LD0..LD15
## ============================================================================

## ---- Clock (100 MHz on W5) -------------------------------------------------
set_property PACKAGE_PIN W5 [get_ports clk]
    set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## ---- Reset (BTNC, async) ---------------------------------------------------
set_property PACKAGE_PIN U18 [get_ports reset]
    set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_false_path -from [get_ports reset]

## ---- Switches SW[15:0] -----------------------------------------------------
##  Port name MUST match top_level.v: switch_in[15:0]
set_property PACKAGE_PIN V17 [get_ports {switch_in[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[0]}]
set_property PACKAGE_PIN V16 [get_ports {switch_in[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[1]}]
set_property PACKAGE_PIN W16 [get_ports {switch_in[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[2]}]
set_property PACKAGE_PIN W17 [get_ports {switch_in[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[3]}]
set_property PACKAGE_PIN W15 [get_ports {switch_in[4]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[4]}]
set_property PACKAGE_PIN V15 [get_ports {switch_in[5]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[5]}]
set_property PACKAGE_PIN W14 [get_ports {switch_in[6]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[6]}]
set_property PACKAGE_PIN W13 [get_ports {switch_in[7]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[7]}]
set_property PACKAGE_PIN V2  [get_ports {switch_in[8]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[8]}]
set_property PACKAGE_PIN T3  [get_ports {switch_in[9]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[9]}]
set_property PACKAGE_PIN T2  [get_ports {switch_in[10]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[10]}]
set_property PACKAGE_PIN R3  [get_ports {switch_in[11]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[11]}]
set_property PACKAGE_PIN W2  [get_ports {switch_in[12]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[12]}]
set_property PACKAGE_PIN U1  [get_ports {switch_in[13]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[13]}]
set_property PACKAGE_PIN T1  [get_ports {switch_in[14]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[14]}]
set_property PACKAGE_PIN R2  [get_ports {switch_in[15]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[15]}]
set_false_path -from [get_ports {switch_in[*]}]

## ---- LEDs LD[15:0] ---------------------------------------------------------
set_property PACKAGE_PIN U16 [get_ports {leds[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[0]}]
set_property PACKAGE_PIN E19 [get_ports {leds[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[1]}]
set_property PACKAGE_PIN U19 [get_ports {leds[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[2]}]
set_property PACKAGE_PIN V19 [get_ports {leds[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[3]}]
set_property PACKAGE_PIN W18 [get_ports {leds[4]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[4]}]
set_property PACKAGE_PIN U15 [get_ports {leds[5]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[5]}]
set_property PACKAGE_PIN U14 [get_ports {leds[6]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[6]}]
set_property PACKAGE_PIN V14 [get_ports {leds[7]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[7]}]
set_property PACKAGE_PIN V13 [get_ports {leds[8]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[8]}]
set_property PACKAGE_PIN V3  [get_ports {leds[9]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[9]}]
set_property PACKAGE_PIN W3  [get_ports {leds[10]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[10]}]
set_property PACKAGE_PIN U3  [get_ports {leds[11]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[11]}]
set_property PACKAGE_PIN P3  [get_ports {leds[12]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[12]}]
set_property PACKAGE_PIN N3  [get_ports {leds[13]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[13]}]
set_property PACKAGE_PIN P1  [get_ports {leds[14]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[14]}]
set_property PACKAGE_PIN L1  [get_ports {leds[15]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[15]}]
