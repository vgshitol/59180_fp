`timescale 1ns / 1ps

module Testbench;

	parameter CLOCK_PERIOD = 20;
	parameter MSG_LEN = 1024;
	//parameter MSG_LEN = 19;
	
	// INPUT REGISTERS
	reg clk; 
	reg resetn; 
	reg start;
	reg load;
	reg [383:0] state_in;
	reg xoodoo_enable;
	reg [7:0] msg;
	reg [11:0] msg_len; 

	// OUTPUT REGISTERS
	wire xoodoo_complete;
	wire [383:0] state_out;
	wire [7:0] hash;
	wire [7:0] hash_len; 
	wire valid;

	// TB REGISTERS
	reg [8191:0] msg_str;
	reg [255:0] exp_hash_str;
	reg [255:0] obs_hash_str;
	
	//generate clock
	always #(CLOCK_PERIOD/2) clk = ~clk;

	// Instantiate the Unit Under Test (UUT)
	XOODYAK dut1 (.clk(clk),.resetn(resetn),.start(start),.load(load),.xoodoo_complete(xoodoo_complete),.state_in(state_in),.msg(msg),
		.msg_len(msg_len),.xoodoo_enable (xoodoo_enable),.state_out(state_out),.hash(hash),.hash_len(hash_len),.valid(valid));
	
	XOODOO dut2 (.clk(clk),.resetn(resetn),.enable_xoodoo(xoodoo_enable),.state_in(state_out),.state_out(state_in),.done_permutations(xoodoo_complete));

	integer i;
		
	// Drive the testbench
	initial begin
		resetn=1'b1;
		clk = 1'b0;
		msg_str = 8192'h000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E7F808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCDDDEDFE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E7F808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCDDDEDFE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E7F808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCDDDEDFE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E7F808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCDDDEDFE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF;
	    exp_hash_str = 256'hfcc4d63932d98c30cab597e60b7cca475bd9fbf984838c5cb5615c949f814615;
	   // msg_str = 8192'h000102030405060708090A0B0C0D0E0F101112;
	 	
	 	#(10*(CLOCK_PERIOD));
		
		resetn=1'b0;
		#(2*(CLOCK_PERIOD));
		
		resetn=1'b1;
		
		#(10*(CLOCK_PERIOD));

		msg_len = MSG_LEN;

		//#(CLOCK_PERIOD/2);
		load = 1;
		for (i=0;i<msg_len;i=i+1)
		begin
			msg=msg_str>>(i)*8;//(MSG_LEN-i-1)*8;
			#(CLOCK_PERIOD);
		end
		load = 0;

		#(5*CLOCK_PERIOD);
		start = 1;
		#(CLOCK_PERIOD);
		start = 0;

		#(3000*(CLOCK_PERIOD));

		$stop;
		
	end
	
	always@(posedge clk) begin
		if(~resetn || load) obs_hash_str <= 0;
		else if(valid==1'b1) begin
			 $display("VALID HIGH!");
			 obs_hash_str <= {obs_hash_str[247:0],hash};
		end
		else obs_hash_str <= obs_hash_str;
	end

	always@(posedge clk) begin
		if(obs_hash_str==exp_hash_str) begin
			 $display("XOODYAK COMPLETE!");
		end
	end


endmodule
