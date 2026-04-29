## ============================================================================
## Lab 11 Part B - Constraint File
## Target: Digilent Basys3 (Artix-7 XC7A35T-1CPG236C)
## Top module: Top  (wraps ClockDivider + TopLevelProcessor)
## ============================================================================

## ----------------------------------------------------------------------------
## 1.  System Clock  -  W5  (100 MHz oscillator)
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN W5 [get_ports clk]
    set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -name sys_clk_pin -period 10.000 -waveform {0.000 5.000} [get_ports clk]

## ----------------------------------------------------------------------------
## 2.  Reset  -  BTNC  (active HIGH, async)
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN U18 [get_ports reset]
    set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_false_path -from [get_ports reset]

## ----------------------------------------------------------------------------
## 3.  Switches  SW[5:0]  (SW0 = LSB)
## ----------------------------------------------------------------------------
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
set_false_path -from [get_ports {switch_in[*]}]

## ----------------------------------------------------------------------------
## 4.  LEDs  LD[5:0]
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN U16 [get_ports {led_out[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led_out[0]}]
set_property PACKAGE_PIN E19 [get_ports {led_out[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led_out[1]}]
set_property PACKAGE_PIN U19 [get_ports {led_out[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led_out[2]}]
set_property PACKAGE_PIN V19 [get_ports {led_out[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led_out[3]}]
set_property PACKAGE_PIN W18 [get_ports {led_out[4]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led_out[4]}]
set_property PACKAGE_PIN U15 [get_ports {led_out[5]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led_out[5]}]

## ----------------------------------------------------------------------------
## 5.  LED write-enable indicator  -  LD15
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN L1 [get_ports led_write_en]
    set_property IOSTANDARD LVCMOS33 [get_ports led_write_en]

## ----------------------------------------------------------------------------
## 6.  7-Segment cathodes  seg[6:0]  (active LOW)
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg[4]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

## ----------------------------------------------------------------------------
## 7.  Decimal point  (always OFF)
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN V7 [get_ports dp]
    set_property IOSTANDARD LVCMOS33 [get_ports dp]

## ----------------------------------------------------------------------------
## 8.  7-Segment anodes  an[3:0]  (active LOW)
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN U2 [get_ports {an[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]
