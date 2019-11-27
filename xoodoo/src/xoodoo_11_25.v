module XOODOO(input clk, resetn, start, input [0:383] state_in, output reg [0:383] state_out, output reg done_permutations);

	reg [0:383] state;
	reg start_reg;
	reg done_calc;
	reg [3:0] rc_count;
	
	localparam  [383:0] RC ={
		32'h58,
		32'h38,
		32'h3C0,
		32'hD0,
		32'h120,
		32'h14,
		32'h60,
		32'h2C,
		32'h380,
		32'hF0,
		32'h1A0,
		32'h12
	};
	

	
	
	
	
	// Theta	
	reg [0:383] state_theta_in;
	wire [0:383] next_round_in;
	reg [3:0] rc_addr_wire;
	
	
	// Theta
	wire [0:127] theta_plane;
	assign theta_plane = state_theta_in[0:127] ^ state_theta_in[128:255] ^ state_theta_in[256:383];
	
	wire [0:31] theta_lane_0 = theta_plane[0:31];
	wire [0:31] theta_lane_1 = theta_plane[32:63];
	wire [0:31] theta_lane_2 = theta_plane[64:95];
	wire [0:31] theta_lane_3 = theta_plane[96:127];
	
	wire [0:31] theta_lane_0_z_5 = {theta_lane_0[27:31],theta_lane_0[0:26]};
	wire [0:31] theta_lane_1_z_5 = {theta_lane_1[27:31],theta_lane_1[0:26]};
	wire [0:31] theta_lane_2_z_5 = {theta_lane_2[27:31],theta_lane_2[0:26]};
	wire [0:31] theta_lane_3_z_5 = {theta_lane_3[27:31],theta_lane_3[0:26]};
	
	wire [0:31] theta_lane_0_z_5_x_1 = theta_lane_3_z_5;
	wire [0:31] theta_lane_1_z_5_x_1 = theta_lane_0_z_5;
	wire [0:31] theta_lane_2_z_5_x_1 = theta_lane_1_z_5;
	wire [0:31] theta_lane_3_z_5_x_1 = theta_lane_2_z_5;
	
	wire [0:31] theta_lane_0_z_14 = {theta_lane_0[18:31],theta_lane_0[0:17]};
	wire [0:31] theta_lane_1_z_14 = {theta_lane_1[18:31],theta_lane_1[0:17]};
	wire [0:31] theta_lane_2_z_14 = {theta_lane_2[18:31],theta_lane_2[0:17]};
	wire [0:31] theta_lane_3_z_14 = {theta_lane_3[18:31],theta_lane_3[0:17]};
	
	wire [0:31] theta_lane_0_z_14_x_1 = theta_lane_3_z_14;
	wire [0:31] theta_lane_1_z_14_x_1 = theta_lane_0_z_14;
	wire [0:31] theta_lane_2_z_14_x_1 = theta_lane_1_z_14;
	wire [0:31] theta_lane_3_z_14_x_1 = theta_lane_2_z_14;
	
	wire [0:31] theta_lane_0_final = theta_lane_0_z_5_x_1[0:31] ^ theta_lane_0_z_14_x_1[0:31];
	wire [0:31] theta_lane_1_final = theta_lane_1_z_5_x_1[0:31] ^ theta_lane_1_z_14_x_1[0:31];
	wire [0:31] theta_lane_2_final = theta_lane_2_z_5_x_1[0:31] ^ theta_lane_2_z_14_x_1[0:31];
	wire [0:31] theta_lane_3_final = theta_lane_3_z_5_x_1[0:31] ^ theta_lane_3_z_14_x_1[0:31];
	
	wire [0:127] theta_final_plane = {theta_lane_0_final,theta_lane_1_final,theta_lane_2_final,theta_lane_3_final};

	wire [0:383] theta_final_state;
	assign theta_final_state[0:127] = state_theta_in[0:127] ^ theta_final_plane;
	assign theta_final_state[128:255] = state_theta_in[128:255] ^ theta_final_plane;
	assign theta_final_state[256:383] = state_theta_in[256:383] ^ theta_final_plane;
	// Theta Ends
	
	
	//West
	wire [0:31] west_plane_1_lane_0 = theta_final_state[128:159];
	wire [0:31] west_plane_1_lane_1 = theta_final_state[160:191];
	wire [0:31] west_plane_1_lane_2 = theta_final_state[192:223];
	wire [0:31] west_plane_1_lane_3 = theta_final_state[224:255];
	
	wire [0:31] west_plane_1_lane_0_x_1 = west_plane_1_lane_3[0:31];
	wire [0:31] west_plane_1_lane_1_x_1 = west_plane_1_lane_0[0:31];
	wire [0:31] west_plane_1_lane_2_x_1 = west_plane_1_lane_1[0:31];
	wire [0:31] west_plane_1_lane_3_x_1 = west_plane_1_lane_2[0:31];
	
	wire [0:127] west_plane_1_final = {west_plane_1_lane_0_x_1,west_plane_1_lane_1_x_1,west_plane_1_lane_2_x_1,west_plane_1_lane_3_x_1};
	
	// Plane 2
	wire[0:31] west_plane_2_lane_0 = theta_final_state[256:287];
	wire[0:31] west_plane_2_lane_1 = theta_final_state[288:319];
	wire[0:31] west_plane_2_lane_2 = theta_final_state[320:351];
	wire[0:31] west_plane_2_lane_3 = theta_final_state[352:383];
	
	wire [0:31] west_plane_2_lane_0_z_11 = {west_plane_2_lane_0[21:31],west_plane_2_lane_0[0:20]};
	wire [0:31] west_plane_2_lane_1_z_11 = {west_plane_2_lane_1[21:31],west_plane_2_lane_1[0:20]};
	wire [0:31] west_plane_2_lane_2_z_11 = {west_plane_2_lane_2[21:31],west_plane_2_lane_2[0:20]};
	wire [0:31] west_plane_2_lane_3_z_11 = {west_plane_2_lane_3[21:31],west_plane_2_lane_3[0:20]};
	
	wire  [0:127] west_plane_2_final = {west_plane_2_lane_0_z_11,west_plane_2_lane_1_z_11,west_plane_2_lane_2_z_11,west_plane_2_lane_3_z_11};
	
	
	
	
	// Output of West
	wire [0:383] west_final_state;
	assign west_final_state	[0:127] =  theta_final_state[0:127];
	assign west_final_state	[128:255] =  west_plane_1_final[0:127];
	assign west_final_state	[256:383] =  west_plane_2_final[0:127];
	//West ends
	
	

	
	always@(posedge clk) begin
		if(resetn==1'b0) begin
			done_calc <= 1'b0;
		end
		else if(start == 1'b1) begin
			done_calc <= 1'b0;
		end
		else if(rc_count == 1'b1 && done_calc==1'b0) begin
			done_calc <= 1'b1;
			state_out <= next_round_in;
			// $display("Done_calc at %0t",$time);
		end
		else begin
			done_calc <= 1'b0;
		end
	end
	
	always@(posedge clk) begin
		if(resetn == 1'b0)begin
			done_permutations <= 1'b0;
		end
		else if(start == 1'b1) begin
			done_permutations <= 1'b0;
		end
		else if(done_calc == 1'b1 && done_permutations==1'b0) begin
			done_permutations <= 1'b1;
			// $display("done_permutations	at %0t",$time);
		end
		else begin
			done_permutations <= 1'b0;
		end
	end
		
	always@(posedge clk or negedge resetn) begin
		if(resetn == 1'b0) begin
			start_reg <= 1'b0;
		end
		else if(start==1'b1 & start_reg==1'b0)begin
			start_reg <= 1'b1;
		end
		else if(done_calc == 1'b1) begin
			start_reg <= 1'b0;
		end
		
	end
	
	always@(posedge clk) begin
		if(resetn==1'b0) begin
			rc_count <= 4'd11;
		end
		else if(start == 1'b1 || start_reg == 1'b0) begin
			rc_count <= 4'd11;
		end
		else if(done_calc==1'b0 && rc_count>0) begin
			rc_count <= rc_count - 1'b1;
			// $display("RC_wire=%0h and west_final_state[0:11]=%0h at %0t",rc_wire,I_final_state[0:11],$time);
		end
		
	end
	
	always@(posedge clk) begin
		if(resetn == 1'b0) begin
			state_theta_in <= 384'd0;
		end
		else if(start == 1'b1 && start_reg==1'b0) begin
			$display("\nStart so State_theta_in[0:127]=%0h at time=%0t",state_in[0:127],$time);
			state_theta_in <= state_in;
		end
		else if(start_reg==1'b1 && done_calc==1'b0) begin
			// $display("\n State_theta_in[0:127]=%0h at time=%0t",next_round_in[0:127],$time);
			state_theta_in <= next_round_in;
		end
		
	end
	
	//Debug
	
	always@(*) begin
		if(resetn==1'b0) begin
			rc_addr_wire = 4'd11;
		end
		else if(start == 1'b1 || start_reg == 1'b0) begin
			rc_addr_wire = 4'd11;
		end
		else if(done_calc==1'b0 && rc_count>0) begin
			rc_addr_wire = rc_count - 1'b1;
			// $display("RC_wire=%0h and west_final_state[0:11]=%0h at %0t",rc_wire,I_final_state[0:11],$time);
		end
	end
	
	//I starts
	
	reg [0:31] rc_wire;
	wire [0:31] reversed_rc_wire;
	
	assign reversed_rc_wire[0:31] = RC[32*rc_addr_wire +:31];
	
	genvar count;
	generate
			for(count=0;count<32;count=count+1) begin
				always@(*) begin
					rc_wire[count]=reversed_rc_wire[31-count];
				end				
			end
	endgenerate

	wire [0:383] I_final_state;
	assign I_final_state[0:31] = west_final_state[0:31] ^ rc_wire[0:31];
	assign I_final_state[32:383] = west_final_state[32:383];
	
	
	//X starts
	wire [0:127] X_plane_0 = I_final_state[0:127];
	wire [0:127] X_plane_1 = I_final_state[128:255];
	wire [0:127] X_plane_2 = I_final_state[256:383];

	wire [0:127] X_plane_0_not = ~I_final_state[0:127];
	wire [0:127] X_plane_1_not = ~I_final_state[128:255];
	wire [0:127] X_plane_2_not = ~I_final_state[256:383];
	
	wire [0:383] X_final_state;
	assign X_final_state[0:127] = X_plane_0 ^ (X_plane_1_not & X_plane_2);
	assign X_final_state[128:255] = X_plane_1 ^ (X_plane_2_not & X_plane_0);
	assign X_final_state[256:383] = X_plane_2 ^ (X_plane_0_not & X_plane_1);
	
	//X ends
	
	// East starts
	wire [0:127] east_plane_1 = X_final_state[128:255];
	wire [0:127] east_plane_2 = X_final_state[256:383];
	
	wire [0:31] east_plane_1_lane_0 = east_plane_1[0:31];
	wire [0:31] east_plane_1_lane_1 = east_plane_1[32:63];
	wire [0:31] east_plane_1_lane_2 = east_plane_1[64:95];
	wire [0:31] east_plane_1_lane_3 = east_plane_1[96:127];
	
	wire [0:31] east_plane_1_lane_0_z_1 = {east_plane_1_lane_0[31],east_plane_1_lane_0[0:30]};
	wire [0:31] east_plane_1_lane_1_z_1 = {east_plane_1_lane_1[31],east_plane_1_lane_1[0:30]};
	wire [0:31] east_plane_1_lane_2_z_1 = {east_plane_1_lane_2[31],east_plane_1_lane_2[0:30]};
	wire [0:31] east_plane_1_lane_3_z_1 = {east_plane_1_lane_3[31],east_plane_1_lane_3[0:30]};
	
	wire [0:127] east_plane_1_final = {east_plane_1_lane_0_z_1, east_plane_1_lane_1_z_1, east_plane_1_lane_2_z_1, east_plane_1_lane_3_z_1};
	

	wire [0:31] east_plane_2_lane_0 = east_plane_2[0:31];
	wire [0:31] east_plane_2_lane_1 = east_plane_2[32:63];
	wire [0:31] east_plane_2_lane_2 = east_plane_2[64:95];
	wire [0:31] east_plane_2_lane_3 = east_plane_2[96:127];

	wire [0:31] east_plane_2_lane_0_z_8 = {east_plane_2_lane_0[24:31],east_plane_2_lane_0[0:23]};
	wire [0:31] east_plane_2_lane_1_z_8 = {east_plane_2_lane_1[24:31],east_plane_2_lane_1[0:23]};
	wire [0:31] east_plane_2_lane_2_z_8 = {east_plane_2_lane_2[24:31],east_plane_2_lane_2[0:23]};
	wire [0:31] east_plane_2_lane_3_z_8 = {east_plane_2_lane_3[24:31],east_plane_2_lane_3[0:23]};	
	
	wire [0:31] east_plane_2_lane_0_z_8_x_2 = east_plane_2_lane_2_z_8[0:31];
	wire [0:31] east_plane_2_lane_1_z_8_x_2 = east_plane_2_lane_3_z_8[0:31];
	wire [0:31] east_plane_2_lane_2_z_8_x_2 = east_plane_2_lane_0_z_8[0:31];
	wire [0:31] east_plane_2_lane_3_z_8_x_2 = east_plane_2_lane_1_z_8[0:31];	
	
	wire [0:127] east_plane_2_final = {east_plane_2_lane_0_z_8_x_2, east_plane_2_lane_1_z_8_x_2, east_plane_2_lane_2_z_8_x_2, east_plane_2_lane_3_z_8_x_2};	
	
	wire [0:383] east_final_state;
	assign east_final_state[0:127] = X_final_state[0:127];
	assign east_final_state[128:255] = east_plane_1_final[0:127];
	assign east_final_state[256:383] = east_plane_2_final[0:127];
	
	
	assign next_round_in[0:383] = east_final_state[0:383];
	
	always@(posedge clk) begin
		if(done_calc==1'b0 && resetn==1'b1 && (start_reg==1'b1)) begin
			
			
			// if(11-rc_addr_wire < 4) begin
				// $display("\n\n\n%0t",$time);
				// $display("State_theta_in\n%h\n%h\n%h",state_theta_in[0:127], state_theta_in[128:255], state_theta_in[256:383]);
				// $display("b= %0d",11-rc_addr_wire);
				// $display("Theta");

				// // $display("Theta_Plane");
				// // $display("%h\t%h\t%h\t%h",theta_lane_0, theta_lane_1, theta_lane_2, theta_lane_3);
				// // $display("theta_plane_z_5");
				// // $display("%h\t%h\t%h\t%h",theta_lane_0_z_5, theta_lane_1_z_5, theta_lane_2_z_5, theta_lane_3_z_5);
				// // $display("theta_plane_z_5_x_1");
				// // $display("%h\t%h\t%h\t%h",theta_lane_0_z_5_x_1,theta_lane_1_z_5_x_1, theta_lane_2_z_5_x_1, theta_lane_3_z_5_x_1);
				// // $display("theta_plane_z_14");
				// // $display("%h\t%h\t%h\t%h",theta_lane_0_z_14, theta_lane_1_z_14, theta_lane_2_z_14, theta_lane_3_z_14);
				// // $display("theta_plane_z_14_x_1");
				// // $display("%h\t%h\t%h\t%h",theta_lane_0_z_14_x_1, theta_lane_1_z_14_x_1, theta_lane_2_z_14_x_1, theta_lane_3_z_14_x_1);

				// $display("After theta");
				// $display("%h\n%h\n%h",theta_final_state[0:127],theta_final_state[128:255], theta_final_state[256:383]);
				
				// $display("West");
				// $display("After West");
				// $display("%h\n%h\n%h",west_final_state[0:127],west_final_state[128:255], west_final_state[256:383]);
				
				// $display("I");
				// $display("RC_wire=%h and RC_addr_wire=%h", rc_wire[0:31], RC[32*rc_addr_wire +:31]);
				// $display("%h\n%h\n%h",I_final_state[0:127],I_final_state[128:255], I_final_state[256:383]);
				// // $display("%h", I_final_state);
				
				// $display("After X");
				// $display("%h\n%h\n%h",X_final_state[0:127],X_final_state[128:255], X_final_state[256:383]);
				// // $display("%h", X_final_state);
				
				// $display("After east");
				// $display("%h\n%h\n%h",east_final_state[0:127],east_final_state[128:255], east_final_state[256:383]);
			// end

			
			
		end
		
	end


endmodule
