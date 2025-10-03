constraint:
## =================== CLOCK 100 MHz ===================
set_property PACKAGE_PIN W5 [get_ports {clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]
create_clock -name sys_clk -period 10.000 [get_ports {clk}]

## =================== BOTONES (ENs y RST) =============
## BTNC -> rst
set_property PACKAGE_PIN U18 [get_ports {rst}]
set_property IOSTANDARD LVCMOS33 [get_ports {rst}]
set_property PULLDOWN true [get_ports {rst}]

## BTNU -> en_a
set_property PACKAGE_PIN T18 [get_ports {en_a}]
set_property IOSTANDARD LVCMOS33 [get_ports {en_a}]
set_property PULLDOWN true [get_ports {en_a}]

## BTND -> en_b
set_property PACKAGE_PIN U17 [get_ports {en_b}]
set_property IOSTANDARD LVCMOS33 [get_ports {en_b}]
set_property PULLDOWN true [get_ports {en_b}]

## BTNR -> en_op
set_property PACKAGE_PIN T17 [get_ports {en_op}]
set_property IOSTANDARD LVCMOS33 [get_ports {en_op}]
set_property PULLDOWN true [get_ports {en_op}]

## =================== SWITCHES (UN ÚNICO BUS) =========
## sw[7:0] -> SW0..SW7
set_property PACKAGE_PIN V17 [get_ports {sw[0]}]   ;# SW0 (LSB)
set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
set_property PACKAGE_PIN V16 [get_ports {sw[1]}]   ;# SW1
set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
set_property PACKAGE_PIN W16 [get_ports {sw[2]}]   ;# SW2
set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
set_property PACKAGE_PIN W17 [get_ports {sw[3]}]   ;# SW3
set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]
set_property PACKAGE_PIN W15 [get_ports {sw[4]}]   ;# SW4
set_property IOSTANDARD LVCMOS33 [get_ports {sw[4]}]
set_property PACKAGE_PIN V15 [get_ports {sw[5]}]   ;# SW5
set_property IOSTANDARD LVCMOS33 [get_ports {sw[5]}]
set_property PACKAGE_PIN W14 [get_ports {sw[6]}]   ;# SW6
set_property IOSTANDARD LVCMOS33 [get_ports {sw[6]}]
set_property PACKAGE_PIN W13 [get_ports {sw[7]}]   ;# SW7 (MSB)
set_property IOSTANDARD LVCMOS33 [get_ports {sw[7]}]

## =================== LEDS (salidas) ==================
## y[7:0] -> LD0..LD7
set_property PACKAGE_PIN U16 [get_ports {y[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {y[0]}]
set_property PACKAGE_PIN E19 [get_ports {y[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {y[1]}]
set_property PACKAGE_PIN U19 [get_ports {y[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {y[2]}]
set_property PACKAGE_PIN V19 [get_ports {y[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {y[3]}]
set_property PACKAGE_PIN W18 [get_ports {y[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {y[4]}]
set_property PACKAGE_PIN U15 [get_ports {y[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {y[5]}]
set_property PACKAGE_PIN U14 [get_ports {y[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {y[6]}]
set_property PACKAGE_PIN V14 [get_ports {y[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {y[7]}]

## Flags -> LD8..LD12
set_property PACKAGE_PIN V13 [get_ports {carry}]
set_property IOSTANDARD LVCMOS33 [get_ports {carry}]
set_property PACKAGE_PIN V3  [get_ports {borrow}]
set_property IOSTANDARD LVCMOS33 [get_ports {borrow}]
set_property PACKAGE_PIN W3  [get_ports {overflow}]
set_property IOSTANDARD LVCMOS33 [get_ports {overflow}]
set_property PACKAGE_PIN U3  [get_ports {zero}]
set_property IOSTANDARD LVCMOS33 [get_ports {zero}]
set_property PACKAGE_PIN P3  [get_ports {neg}]
set_property IOSTANDARD LVCMOS33 [get_ports {neg}]