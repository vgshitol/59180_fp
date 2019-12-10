TBENCHSRC	= testbench.v
SRCDIR		= ../src
SVERILOGSRC	= $(wildcard ./*.sv)
VERILOGTOP	= Testbench

# Mentor Graphics QuestaSim/ModelSim
sim:
	vlib work
	vlog $(SRCDIR)/xoodoo.v
	vlog $(TBENCHSRC)
	vsim $(VERILOGTOP) -c -do "run -all; exit;"

cli: sim

gui:
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
