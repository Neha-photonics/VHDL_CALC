###############################################################################
# Clock - on-board 100 MHz oscillator
###############################################################################
set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33 } [get_ports { clk_100MHz }]
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5} \
             [get_ports { clk_100MHz }]

###############################################################################
# Keypad (4 × 4) on PMOD JB
# rows = JB pins 10?7    (inputs, pull-ups on)
# cols = JB pins 4?1     (outputs)
###############################################################################
# rows[3:0]  - JB10, JB9, JB8, JB7
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 PULLUP TRUE } [get_ports { rows[0] }]  ;# JB10
set_property -dict { PACKAGE_PIN G13 IOSTANDARD LVCMOS33 PULLUP TRUE } [get_ports { rows[1] }]  ;# JB9
set_property -dict { PACKAGE_PIN F13 IOSTANDARD LVCMOS33 PULLUP TRUE } [get_ports { rows[2] }]  ;# JB8
set_property -dict { PACKAGE_PIN E16 IOSTANDARD LVCMOS33 PULLUP TRUE } [get_ports { rows[3] }]  ;# JB7

# cols[3:0]  - JB4, JB3, JB2, JB1
set_property -dict { PACKAGE_PIN H14 IOSTANDARD LVCMOS33 } [get_ports { cols[3] }]  ;# JB4
set_property -dict { PACKAGE_PIN G16 IOSTANDARD LVCMOS33 } [get_ports { cols[2] }]  ;# JB3
set_property -dict { PACKAGE_PIN F16 IOSTANDARD LVCMOS33 } [get_ports { cols[1] }]  ;# JB2
set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS33 } [get_ports { cols[0] }]  ;# JB1

###############################################################################
# 7-segment display (common-anode, active-LOW)
# seg bus order in HDL = g f e d c b a   (seg[6]..seg[0])
###############################################################################
# cathodes (segments)
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports { seg[6] }]  ;# CG (g)
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports { seg[5] }]  ;# CF (f)
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports { seg[4] }]  ;# CE (e)
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports { seg[3] }]  ;# CD (d)
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports { seg[2] }]  ;# CC (c)
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports { seg[1] }]  ;# CB (b)
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { seg[0] }]  ;# CA (a)

# anodes - we light only the right-most digit (others stay OFF in logic)
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports { an[0] }]   ;# AN0 (rightmost)
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports { an[1] }]   ;# AN1
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports { an[2] }]   ;# AN2
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports { an[3] }]   ;# AN3
###############################################################################
# End of constraints
###############################################################################

