module TOP(
	input wire clk, 
	input wire resetn, 
	input wire start, 
	input wire [7:0] msg,
	input wire [11:0] msg_len,
 
	output [7:0] hash, 
	output [7:0] hash_len,
	output valid,
	output busy
	);

	
	// Instantiate the Unit Under Test (UUT)
	XOODYAK dut1 (.clk(clk),.resetn(resetn),.start(start),.msg(msg),
		.msg_len(msg_len),.hash(hash),.hash_len(hash_len),.valid(valid),.busy(busy));
	

endmodule
