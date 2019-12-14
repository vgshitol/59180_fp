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
add wave -noupdate /Testbench/obs_hash_str
add wave -noupdate /Testbench/cmp
add wave -noupdate /Testbench/dut/dut1/state_register
add wave -noupdate /Testbench/dut/dut1/xoodoo_state_in
add wave -noupdate /Testbench/dut/dut1/xoodoo_reversed_state_in
add wave -noupdate /Testbench/dut/dut1/theta_plane
add wave -noupdate /Testbench/dut/dut1/theta_final_state
add wave -noupdate /Testbench/dut/dut1/theta_final_plane
add wave -noupdate /Testbench/dut/dut1/reversed_rc_wire
add wave -noupdate /Testbench/dut/dut1/rc_wire
add wave -noupdate /Testbench/dut/dut1/state_register
add wave -noupdate /Testbench/dut/dut1/xoodoo_state_out
add wave -noupdate /Testbench/dut/dut1/xoodoo_reversed_state_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {950000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 309
configure wave -valuecolwidth 308
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
WaveRestoreZoom {0 ps} {2440021 ps}
