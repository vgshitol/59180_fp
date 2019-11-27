`timescale 1ns / 1ps

module Testbench;

	parameter CLOCK_PERIOD = 20;
	parameter ITERATION_SIZE = 5;

	// Inputs
	reg clk,resetn;
	
	reg start;
	
	reg [0:383] state_in;
	wire [0:383] state_out;
	
	wire done_permutations;

	//generate clock
	always #(CLOCK_PERIOD/2) clk = ~clk;

	// Instantiate the Unit Under Test (UUT)

	XOODOO dut (.*);

	// Drive the testbench
	initial begin
		resetn=1'b1;
		clk = 1'b0;
		state_in = 1'b0;
		#(10*(CLOCK_PERIOD));
		resetn=1'b0;
		#(2*(CLOCK_PERIOD));
		resetn=1'b1;
		
		#(2*(CLOCK_PERIOD));
		start = 1'b1;
		
		#(2*(CLOCK_PERIOD));
		start = 1'b0;
		
		#(50*(CLOCK_PERIOD));
		$finish;
		
	end
	
	always@(posedge clk) begin
		if(done_permutations==1'b1) begin
			// $display("%h\n%h\n%h",state_out[0:127],state_out[128:255], state_out[256:383]);
		end
	end




endmodule
