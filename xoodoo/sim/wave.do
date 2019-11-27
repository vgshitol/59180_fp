onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Testbench/dut/clk
add wave -noupdate /Testbench/dut/resetn
add wave -noupdate /Testbench/dut/load
add wave -noupdate /Testbench/dut/start
add wave -noupdate /Testbench/dut/r2_reg
add wave -noupdate /Testbench/dut/c1_reg
add wave -noupdate /Testbench/dut/c2_reg
add wave -noupdate /Testbench/dut/c1
add wave -noupdate /Testbench/dut/c2
add wave -noupdate /Testbench/dut/r2
add wave -noupdate /Testbench/dut/start_reg
add wave -noupdate /Testbench/dut/c1_mem
add wave -noupdate /Testbench/dut/message_out
add wave -noupdate /Testbench/dut/c2_mem
add wave -noupdate /Testbench/j
add wave -noupdate /Testbench/cmp
add wave -noupdate /Testbench/dut/depth_count
add wave -noupdate /Testbench/dut/breadth_count
add wave -noupdate /Testbench/dut/out_reg
add wave -noupdate /Testbench/dut/done_calc
add wave -noupdate -radix unsigned /Testbench/dut/out_count
add wave -noupdate /Testbench/dut/valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1326230000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 432
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {1326199053 ps} {1326628109 ps}
