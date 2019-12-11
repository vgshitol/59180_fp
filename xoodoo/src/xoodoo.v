module XOODOO(input clk, resetn, enable_xoodoo, input [0:383] state_in, output [0:383] state_out, output reg done_permutations);
	
	
	wire [0:383] permute_state_in;
	wire [0:383] permute_state_out;
	wire permute_done_permutations;
	
	genvar ii;
	generate
		for(ii=0;ii<384;ii=ii+8) begin
			assign permute_state_in[ii + 7] = state_in[ii];
			assign permute_state_in[ii + 6] = state_in[ii + 1];
			assign permute_state_in[ii + 5] = state_in[ii + 2];
			assign permute_state_in[ii + 4] = state_in[ii + 3];
			assign permute_state_in[ii + 3] = state_in[ii + 4];
			assign permute_state_in[ii + 2] = state_in[ii + 5];
			assign permute_state_in[ii + 1] = state_in[ii + 6];
			assign permute_state_in[ii] = state_in[ii + 7];
		end
	endgenerate
	
	always@(*) begin
		done_permutations = permute_done_permutations;
	end
	// always@(*) begin
		// assign state_out = permute_state_out;
	// end
	
	genvar oo;
	generate
		for(oo=0;oo<384;oo=oo+8) begin
			assign state_out[oo + 7] = permute_state_out[oo];
			assign state_out[oo + 6] = permute_state_out[oo + 1];
			assign state_out[oo + 5] = permute_state_out[oo + 2];
			assign state_out[oo + 4] = permute_state_out[oo + 3];
			assign state_out[oo + 3] = permute_state_out[oo + 4];
			assign state_out[oo + 2] = permute_state_out[oo + 5];
			assign state_out[oo + 1] = permute_state_out[oo + 6];
			assign state_out[oo] = permute_state_out[oo + 7];
		end
	endgenerate
	
	permute DUT(clk, resetn, enable_xoodoo, permute_state_in, permute_state_out, permute_done_permutations);


endmodule
