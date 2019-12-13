module TOP(
	input wire clk, 
	input wire resetn, 
	input wire start, 
	input wire load,
	
	
	input wire [7:0] msg,
	input wire [11:0] msg_len, 

	
	
	output [7:0] hash, 
	//changed from reg to wire
	output valid,
	output busy
	);

	wire xoodoo_complete;
	wire xoodoo_enable;
	wire [383:0] state_in;
	wire [7:0] hash_len;
	wire [383:0] state_out;

	// Instantiate the Unit Under Test (UUT)
	XOODYAK dut1 (.clk(clk),.resetn(resetn),.start(start),.load(load),.xoodoo_complete(xoodoo_complete),.state_in(state_in),.msg(msg),
		.msg_len(msg_len),.xoodoo_enable (xoodoo_enable),.state_out(state_out),.hash(hash),.hash_len(hash_len),.valid(valid),.busy(busy));
	
	XOODOO dut2 (.clk(clk),.resetn(resetn),.enable_xoodoo(xoodoo_enable),.state_in(state_out),.state_out(state_in),.done_permutations(xoodoo_complete));


endmodule
