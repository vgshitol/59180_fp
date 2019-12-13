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
add wave -noupdate /Testbench/dut/dut2/state_out
add wave -noupdate /Testbench/dut/dut2/state_in_reversed
add wave -noupdate /Testbench/dut/dut2/state_in
add wave -noupdate /Testbench/dut/dut2/resetn
add wave -noupdate /Testbench/dut/dut2/permute_state_out
add wave -noupdate /Testbench/dut/dut2/permute_state_in
add wave -noupdate /Testbench/dut/dut2/permute_done_permutations
add wave -noupdate /Testbench/dut/dut2/enable_xoodoo
add wave -noupdate /Testbench/dut/dut2/done_permutations
add wave -noupdate /Testbench/dut/dut2/clk
add wave -noupdate /Testbench/obs_hash_str
add wave -noupdate /Testbench/cmp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {181603678 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 432
configure wave -valuecolwidth 72
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
WaveRestoreZoom {178654865 ps} {187934156 ps}
