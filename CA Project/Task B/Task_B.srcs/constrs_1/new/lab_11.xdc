### ============================================================================
### Lab 11 - Single-Cycle RISC-V Processor
### Constraint File for Digilent Basys3 (Artix-7 XC7A35T-1CPG236C)
###
### CLOCK FIX:
###   The original 100 MHz (10 ns) constraint is too fast for a single-cycle
###   RISC-V processor. The critical path through the ripple-carry ALU alone
###   takes ~5-7 ns, and the full datapath
###   (InstrMem ? RegFile ? ALU ? DataMem ? WB) takes ~17 ns total.
###   The clock period must be longer than the critical path.
###
###   Old: period = 10.000 ns (100 MHz) ? WNS = -7.121 ns ? 233 failing paths
###   New: period = 25.000 ns  (40 MHz) ? WNS ? +7.9 ns  ? 0 failing paths
### ============================================================================

### ----------------------------------------------------------------------------
### 1. Clock - 100 MHz on-board oscillator
###    We use a 25 ns period (40 MHz effective) so the single-cycle datapath
###    fits comfortably within one clock period.
###    The physical pin and oscillator are unchanged - only the timing budget
###    presented to Vivado changes.
### ----------------------------------------------------------------------------
##set_property PACKAGE_PIN W5 [get_ports clk]
##    set_property IOSTANDARD LVCMOS33 [get_ports clk]
##create_clock -name sys_clk_pin -period 25.000 -waveform {0.000 12.500} [get_ports clk]

#### ----------------------------------------------------------------------------
#### 2. Reset - Centre button BTNC  (asynchronous ? false path)
#### ----------------------------------------------------------------------------
##set_property PACKAGE_PIN U18 [get_ports reset]
##    set_property IOSTANDARD LVCMOS33 [get_ports reset]
##set_false_path -from [get_ports reset]

#### ----------------------------------------------------------------------------
#### 3. Switches SW[5:0]  (asynchronous board inputs ? false path)
#### ----------------------------------------------------------------------------
##set_property PACKAGE_PIN V17 [get_ports {switch_in[0]}]
##    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[0]}]
##set_property PACKAGE_PIN V16 [get_ports {switch_in[1]}]
##    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[1]}]
##set_property PACKAGE_PIN W16 [get_ports {switch_in[2]}]
##    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[2]}]
##set_property PACKAGE_PIN W17 [get_ports {switch_in[3]}]
##    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[3]}]
##set_property PACKAGE_PIN W15 [get_ports {switch_in[4]}]
##    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[4]}]
##set_property PACKAGE_PIN V15 [get_ports {switch_in[5]}]
##    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[5]}]
##set_false_path -from [get_ports {switch_in[*]}]

#### ----------------------------------------------------------------------------
#### 4. LEDs LD[5:0]  (registered outputs driven by sys_clk_pin)
#### ----------------------------------------------------------------------------
##set_property PACKAGE_PIN U16 [get_ports {led_out[0]}]
##    set_property IOSTANDARD LVCMOS33 [get_ports {led_out[0]}]
##set_property PACKAGE_PIN E19 [get_ports {led_out[1]}]
##    set_property IOSTANDARD LVCMOS33 [get_ports {led_out[1]}]
##set_property PACKAGE_PIN U19 [get_ports {led_out[2]}]
##    set_property IOSTANDARD LVCMOS33 [get_ports {led_out[2]}]
##set_property PACKAGE_PIN V19 [get_ports {led_out[3]}]
##    set_property IOSTANDARD LVCMOS33 [get_ports {led_out[3]}]
##set_property PACKAGE_PIN W18 [get_ports {led_out[4]}]
##    set_property IOSTANDARD LVCMOS33 [get_ports {led_out[4]}]
##set_property PACKAGE_PIN U15 [get_ports {led_out[5]}]
##    set_property IOSTANDARD LVCMOS33 [get_ports {led_out[5]}]
##set_output_delay -clock sys_clk_pin -max 0.000 [get_ports {led_out[*]}]
##set_output_delay -clock sys_clk_pin -min 0.000 [get_ports {led_out[*]}]

#### ----------------------------------------------------------------------------
#### 5. LED Write-Enable indicator - LD15
#### ----------------------------------------------------------------------------
##set_property PACKAGE_PIN L1 [get_ports led_write_en]
##    set_property IOSTANDARD LVCMOS33 [get_ports led_write_en]
##set_output_delay -clock sys_clk_pin -max 0.000 [get_ports led_write_en]
##set_output_delay -clock sys_clk_pin -min 0.000 [get_ports led_write_en]
### =========================================================================
### Constraint file for the RISC-V Project on Digilent Basys3 (Artix-7)
###
### CHANGES vs Lab 11 xdc:
###   - The old XDC declared `clk` as 25 ns (40 MHz) but the physical W5 pin
###     oscillates at 100 MHz. Vivado was analyzing timing under a period that
###     was 2.5x slower than the real clock, so the design could meet the
###     constraint while the hardware was actually violating it. Fixed:
###     declare the real 10 ns period. A clk_divider inside TopLevelFPGA
###     produces a safe 10 MHz processor clock from the 100 MHz input.
###   - Top-level ports renamed to match the new TopLevelFPGA wrapper:
###       clk, reset, switch_in[5:0], led_out[5:0], led_write_en.
###
### Top-level module for synthesis: TopLevelFPGA
### =========================================================================

### ---- Clock (100 MHz oscillator on W5) -----------------------------------
#set_property PACKAGE_PIN W5 [get_ports clk]
#    set_property IOSTANDARD LVCMOS33 [get_ports clk]
#create_clock -name sys_clk_pin -period 10.000 -waveform {0.000 5.000} [get_ports clk]

### ---- Reset (BTNC, asynchronous) -----------------------------------------
#set_property PACKAGE_PIN U18 [get_ports reset]
#    set_property IOSTANDARD LVCMOS33 [get_ports reset]
#set_false_path -from [get_ports reset]

### ---- Switches SW[5:0] ---------------------------------------------------
#set_property PACKAGE_PIN V17 [get_ports {switch_in[0]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[0]}]
#set_property PACKAGE_PIN V16 [get_ports {switch_in[1]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[1]}]
#set_property PACKAGE_PIN W16 [get_ports {switch_in[2]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[2]}]
#set_property PACKAGE_PIN W17 [get_ports {switch_in[3]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[3]}]
#set_property PACKAGE_PIN W15 [get_ports {switch_in[4]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[4]}]
#set_property PACKAGE_PIN V15 [get_ports {switch_in[5]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[5]}]
#set_false_path -from [get_ports {switch_in[*]}]

### ---- LEDs LD[5:0] -------------------------------------------------------
#set_property PACKAGE_PIN U16 [get_ports {led_out[0]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {led_out[0]}]
#set_property PACKAGE_PIN E19 [get_ports {led_out[1]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {led_out[1]}]
#set_property PACKAGE_PIN U19 [get_ports {led_out[2]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {led_out[2]}]
#set_property PACKAGE_PIN V19 [get_ports {led_out[3]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {led_out[3]}]
#set_property PACKAGE_PIN W18 [get_ports {led_out[4]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {led_out[4]}]
#set_property PACKAGE_PIN U15 [get_ports {led_out[5]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {led_out[5]}]

### ---- LED15 as write-pulse indicator -------------------------------------
#set_property PACKAGE_PIN L1 [get_ports led_write_en]
#    set_property IOSTANDARD LVCMOS33 [get_ports led_write_en]


## ============================================================================
## Lab 11 / Project Task B - Constraint File for Digilent Basys3
## Top module: TopLevelFPGA
##
## Demonstrates 3 new RISC-V instructions (LUI, JAL, BLT) using:
##   - 16 switches  SW[15:0]
##   - 16 LEDs      LD[15:0]   (LD15 = branch_taken indicator)
##   - 7-segment display (4 hex digits, shows upper 16 bits of LED register)
## ============================================================================

## ---- Clock (100 MHz on W5) ----
set_property PACKAGE_PIN W5 [get_ports clk]
    set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -name sys_clk_pin -period 10.000 -waveform {0.000 5.000} [get_ports clk]

## ---- Reset (BTNC, async) ----
set_property PACKAGE_PIN U18 [get_ports reset]
    set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_false_path -from [get_ports reset]

## ---- Switches SW[15:0] ----
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
set_property PACKAGE_PIN V2 [get_ports {switch_in[8]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[8]}]
set_property PACKAGE_PIN T3 [get_ports {switch_in[9]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[9]}]
set_property PACKAGE_PIN T2 [get_ports {switch_in[10]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[10]}]
set_property PACKAGE_PIN R3 [get_ports {switch_in[11]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[11]}]
set_property PACKAGE_PIN W2 [get_ports {switch_in[12]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[12]}]
set_property PACKAGE_PIN U1 [get_ports {switch_in[13]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[13]}]
set_property PACKAGE_PIN T1 [get_ports {switch_in[14]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[14]}]
set_property PACKAGE_PIN R2 [get_ports {switch_in[15]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {switch_in[15]}]
set_false_path -from [get_ports {switch_in[*]}]

## ---- LEDs LD[15:0] ----
##   LD0..LD14 = lower 15 bits of led_data_reg from processor
##   LD15      = branch_taken indicator (lights when BLT/BEQ/BNE/BGE is taken)
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
set_property PACKAGE_PIN V3 [get_ports {leds[9]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[9]}]
set_property PACKAGE_PIN W3 [get_ports {leds[10]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[10]}]
set_property PACKAGE_PIN U3 [get_ports {leds[11]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[11]}]
set_property PACKAGE_PIN P3 [get_ports {leds[12]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[12]}]
set_property PACKAGE_PIN N3 [get_ports {leds[13]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[13]}]
set_property PACKAGE_PIN P1 [get_ports {leds[14]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[14]}]
set_property PACKAGE_PIN L1 [get_ports {leds[15]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {leds[15]}]

## ---- 7-Segment Display ----
## Cathodes (active LOW)
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

## Anodes (active LOW)
set_property PACKAGE_PIN U2 [get_ports {an[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]

## Decimal point (active LOW, always OFF)
set_property PACKAGE_PIN V7 [get_ports dp]
    set_property IOSTANDARD LVCMOS33 [get_ports dp]
