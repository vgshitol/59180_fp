TBENCHSRC	= testbench.v
SRCDIR		= ../src
X_DIR		= ../../xoodoo/src
SVERILOGSRC	= $(wildcard ./*.sv)
VERILOGTOP	= Testbench

# Mentor Graphics QuestaSim/ModelSim
sim:
	vlib work
	vlog $(X_DIR)/permute.v
	vlog $(X_DIR)/xoodoo.v
	vlog -sv $(SRCDIR)/xoodyak.v
	vlog -sv $(SRCDIR)/top.v
	vlog -sv $(TBENCHSRC)
	vsim $(VERILOGTOP) -c -do "run -all; exit;"

cli: sim
gui:
	vlib work
	vlog $(X_DIR)/permute.v
	vlog $(X_DIR)/xoodoo.v
	vlog -sv $(SRCDIR)/xoodyak.v
	vlog -sv $(SRCDIR)/top.v
	vlog -sv $(TBENCHSRC)
	vsim -novopt $(VERILOGTOP) -do "wave.do"

gui_old:
	vlib work
	vlog $(SRCDIR)/xoodoo.v
	vlog $(TBENCHSRC)
	vsim -novopt $(VERILOGTOP) -do "wave.do"

clean:
	-rm -rf work
	-rm -rf mti_lib
	-rm -f ram.bin
	-rm -f *.elf
	-rm -f *.o
	-rm -f transcript
	-rm -f vsim.wlf
	-rm -f *.txt
