onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Testbench/dut/clk
add wave -noupdate /Testbench/dut/resetn
add wave -noupdate /Testbench/dut/start
add wave -noupdate /Testbench/dut/msg
add wave -noupdate /Testbench/dut/msg_len
add wave -noupdate /Testbench/dut/hash
add wave -noupdate /Testbench/dut/hash_len
add wave -noupdate /Testbench/dut/valid
add wave -noupdate /Testbench/dut/next_block_ready
add wave -noupdate /Testbench/dut/start_en
add wave -noupdate /Testbench/dut/counter_complete
add wave -noupdate /Testbench/dut/counter
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
