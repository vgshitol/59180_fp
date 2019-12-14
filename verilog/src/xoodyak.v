
module XOODYAK(
	input wire clk, 
	input wire resetn, 
	input wire start, 
	input wire [7:0] msg,
	input wire [11:0] msg_len, 

	output reg [7:0] hash, 
	output reg [7:0] hash_len, 
	output reg valid,
	output reg busy
	);

	parameter [3:0]
		IDLE	 		= 4'd0,
		ABSORB   		= 4'd2,
		ABSORB_XOODOO   = 4'd3,
		ABSORB_UP 		= 4'd4,
		ABSORB_DOWN 	= 4'd5,
		SQUEEZE  		= 4'd6,
		SQUEEZE_XOODOO  = 4'd7,
		SQUEEZE_UP 		= 4'd8,
		SQUEEZE_DOWN 	= 4'd9,
		EXTRACT  		= 4'd10,
		COMPLETE  		= 4'd11,
		S_A_X			= 4'd12,
		S_S_X			= 4'd13;


//	reg [1023:0][7:0] msg_in;
	
	reg [3:0] 		curr_state;
	reg 			start_en;
	reg 			next_block_ready;
	reg 			counter_complete;
	reg [8:0] 		counter;

	reg [383:0] 		state_register;

	reg [15:0][7:0] 	next_block; 

	reg [11:0] 		next_msg_len;

	reg c_d;

	reg [7:0] cur_msg_reg;
	reg [11:0] msg_len_reg;
	reg msg_len_red;

	// xoodoo variables 
	reg xoodoo_enable;
	reg xoodoo_complete;
	reg [383:0] state_in;
	reg [383:0] state_out;
	
	//Shlok variables
	wire [383:0] xoodoo_reversed_state_in = state_register;
	wire [0:383] xoodoo_state_in;

	wire [0:383] xoodoo_state_out;
	wire [383:0] xoodoo_reversed_state_out;
	genvar x;
	generate
		for(x=0;x<384;x=x+1) begin
			assign xoodoo_state_in[x] = xoodoo_reversed_state_in[x];
			assign xoodoo_reversed_state_out[x] = xoodoo_state_out[x];
		end
	endgenerate

	
		
	
	


`define display_fsm 1

	// state machine
	always @(posedge clk) 
	begin
		if (~resetn) 
		begin
				curr_state <= IDLE;
		end
		else 
		begin		
			case(curr_state)
				IDLE:
				begin
					// if(`display_fsm) $display("IDLE");
					if (start_en == 1) curr_state <= ABSORB;
				end
				ABSORB:
				begin
					if(`display_fsm) $display("ABSORB");
					if (counter_complete == 1) curr_state <= ABSORB_DOWN;
				end
				ABSORB_DOWN:
				begin
					if(`display_fsm) $display("ABSORB DOWN");
					curr_state <= ABSORB_UP;
				end
				ABSORB_UP:
				begin
					if(`display_fsm) $display("ABSORB UP");
					curr_state <= S_A_X;	
				end 
				S_A_X:
				begin
					if(`display_fsm) $display("Before XOODOO");
					if(next_msg_len==0) curr_state <= SQUEEZE;
				 	else curr_state <= ABSORB_XOODOO;		
				end				
				ABSORB_XOODOO:
				begin
					if(`display_fsm) $display("ABSORB XOODOO");
				 	if(counter_complete) curr_state <= ABSORB;		
				end
				SQUEEZE:
				begin
					if(`display_fsm) $display("SQUEEZE");
					curr_state <= SQUEEZE_UP; 
				end
				SQUEEZE_DOWN:
				begin
					if(`display_fsm) $display("SQUEEZE DOWN");
				 	curr_state <= SQUEEZE_UP;
				end
				SQUEEZE_UP:
				begin
					if(`display_fsm) $display("SQUEEZE UP");
					curr_state <= S_S_X;	
				end 
				S_S_X:
				begin
					if(`display_fsm) $display("Before XOODOO");
				 	curr_state <= SQUEEZE_XOODOO;		
				end				
				SQUEEZE_XOODOO:
				begin
					if(`display_fsm) $display("SQUEEZE XOODOO");
					if(counter_complete) curr_state <= EXTRACT;		
				end 
				EXTRACT:
				begin
					if(`display_fsm) $display("EXTRACT");
					if(counter_complete && hash_len==31) curr_state <= COMPLETE;
					else if(counter_complete) curr_state <= SQUEEZE_DOWN;		
				end
				COMPLETE:
				begin
					if(`display_fsm) $display("COMPLETE");
					if(counter_complete) curr_state <= IDLE;
					if(`display_fsm) $display("IDLE");
				end
				default: begin
			//		$display("DEFAULT");
					curr_state <= IDLE;
				end
			endcase
		end
	end

	// busy status 
	always @(posedge clk or negedge resetn) begin : proc_busy
		if(~resetn || (curr_state==IDLE && start_en) || (curr_state==ABSORB_XOODOO && counter_complete) || curr_state==ABSORB) begin
			busy <= 0;
		end else begin
			busy <= 1;
		end
	end
	// Conditional Counter
	always @(posedge clk or negedge resetn) begin 
		if(~resetn || counter_complete) counter <= 0;
		else if(curr_state==ABSORB || curr_state==ABSORB_XOODOO || curr_state==SQUEEZE_XOODOO || curr_state==EXTRACT || curr_state==COMPLETE) counter <= counter + 1;
		else counter <= counter;

		if(curr_state==ABSORB) counter_complete <= counter == 9'h0e; // state change at 0x0f
		//else if(curr_state==ABSORB && next_msg_len < 16) counter_complete <= counter == next_msg_len-1; //next_msg_len+1
		else if (curr_state==ABSORB_XOODOO || curr_state==SQUEEZE_XOODOO) counter_complete <= counter == 9'h0a;
		else if (curr_state==EXTRACT) counter_complete <= counter == 9'h0e;
		else if (curr_state==COMPLETE) counter_complete <= counter == 9'h04;
		else counter_complete <= counter == 9'hff;


		if(curr_state==ABSORB) next_block_ready <= counter == 9'h0f;
		else next_block_ready <= 0;

		if(curr_state==ABSORB_XOODOO || curr_state == SQUEEZE_XOODOO) xoodoo_enable <= counter == 9'h00;
		else xoodoo_enable <= 0;
	end	

	// Valid 
	always@(posedge clk)
		begin
			if(~resetn) valid <= 0;
			else valid <= curr_state==EXTRACT;
		end

	// Start Enable
	always@(posedge clk)
		begin
			if(~resetn | hash_len==31) start_en <= 0;
			else start_en <= start_en | start;
		end	

	// Reduce the Msg Length 
	always @(posedge clk or negedge resetn) begin
		if(~resetn) next_msg_len <= 0;
		else if (curr_state==IDLE) next_msg_len <= msg_len;
		// else if (curr_state==IDLE && start_en==1) next_msg_len <= next_msg_len;
		else if (curr_state==ABSORB_UP && next_msg_len >= 12'h010) next_msg_len <= next_msg_len - 12'h010;
		else if (curr_state==ABSORB_UP && next_msg_len < 12'h010) next_msg_len <= 0;
		else next_msg_len <= next_msg_len;
	end

// *************************************Data Path*************************************** 

	// Register the input msg byte 
	always @(posedge clk or negedge resetn) begin : proc_msg
		if(~resetn) begin
			cur_msg_reg <= 0;
			msg_len_reg <= 0;
		end else begin
			cur_msg_reg <= msg;
			msg_len_reg <= msg_len;
		end
	end

	// Create teh Data Block (16 Bytes --> 128 bits)
	always @(posedge clk or negedge resetn) begin
			if(~resetn || curr_state==ABSORB_XOODOO) next_block <= 0;
			else if (curr_state==ABSORB && next_msg_len >= 16) next_block <= {msg,next_block[15:1]};
			else if (curr_state==ABSORB && next_msg_len < 16) begin
				if(counter == next_msg_len) next_block <= {8'h01,next_block[15:1]};
				else if (counter < next_msg_len) next_block <= {msg,next_block[15:1]};
				else next_block <= {8'h00,next_block[15:1]};
			end			
			//else if (curr_state==SQUEEZE) next_block <= 8'h01;		
			else next_block <= next_block;
	end	
	
	// Down Operation and Xoodoo complete Update state register  
	always @(posedge clk or negedge resetn) begin : proc_down
		if(~resetn || curr_state==COMPLETE) state_register <= 0;
		else if (curr_state==ABSORB_DOWN) begin
			state_register[127:0]   <= state_register[127:0]^next_block;
			
			if(next_msg_len >= 16 ) state_register[128] <= state_register[128]^1;
			else state_register[128] <= state_register[128];

			state_register[375:129] <= state_register[375:129];
			state_register[376] 	<= state_register[376]^c_d;
			state_register[383:377] <= state_register[383:377];
		end
		else if (curr_state==SQUEEZE_DOWN) begin
			state_register[0]   <= state_register[0]^1;
			state_register[383:1] <= state_register[383:1];
		end
		else if ((curr_state==ABSORB_XOODOO || curr_state==SQUEEZE_XOODOO)) state_register <= xoodoo_reversed_state_out; 
		// else if (curr_state==SQUEEZE_XOODOO && xoodoo_complete) state_register <= state_in; 
		else if (curr_state==EXTRACT) state_register[127:0] <= {state_register[7:0],state_register[127:8]};
		else state_register <= state_register;
	end

	// C_D Update
	always @(posedge clk or negedge resetn) begin : proc_c_d
		if(~resetn || curr_state==COMPLETE) c_d <= 1;
		else if (curr_state==ABSORB_UP) c_d <= 0;
		else c_d <= c_d;
	end



	// Increase hash len
	always @(posedge clk or negedge resetn) begin
		if(~resetn || curr_state==COMPLETE) hash_len <= 0;
		else if (curr_state==EXTRACT) hash_len <= hash_len + 1;
		else hash_len <= hash_len;
	end

	// Output Hash 
	always @(posedge clk or negedge resetn) begin
		if(~resetn) hash <= 0;
		else if (curr_state==EXTRACT) hash <= state_register[7:0];
		else hash <= hash;
	end

/*
	// Enable XOODOO and run xoodoo with updated vector
	always @(posedge clk or negedge resetn) begin : proc_
		if(~resetn) state_out <= 0;
		else if(curr_state==ABSORB_XOODOO || curr_state==SQUEEZE_XOODOO) state_out <= state_register;
		else state_out <= state_out;
	end
*/


//Shlok Control_In
	reg done_calc;
	reg [3:0] rc_count;
	reg start_reg;

	localparam  [143:0] RC ={
		12'h58,
		12'h38,
		12'h3C0,
		12'hD0,
		12'h120,
		12'h14,
		12'h60,
		12'h2C,
		12'h380,
		12'hF0,
		12'h1A0,
		12'h12
	};
	always@(posedge clk) begin
		xoodoo_complete <= done_calc;
	end
/*
	always@(posedge clk) begin
		if(resetn==1'b0) begin
			rc_count <= 4'd11;
			start_reg <= 1'b0;
			$display("Reset rc_count and start_reg");
		end
		else if(xoodoo_enable == 1'b1 && start_reg == 1'b0) begin
			rc_count <= 4'd11;
			start_reg <= xoodoo_enable;
			$display("\n\n**********************XOODOO_ENABLE is HIGH**********************\n\n");	
			$display("Load in state_register to theta_state_in wire");
		end
		else if(done_calc==1'b0 && rc_count>0 && start_reg == 1'b1) begin
			rc_count <= rc_count - 1'b1;
			$display("Load in state_register to final_state_in wire");
			// $display("RC_wire=%0h and west_final_state[0:11]=%0h at %0t",rc_wire,I_final_state[0:11],$time);
		end
		else begin
			rc_count <= 4'd11;
			start_reg <= 1'b0;
			if(start_reg == 1'b1) $display("Reset start_reg");
			$display("Reset rc_count as done_calc");
		end
		
		
		
		
	end
*/




	
	
//Shlok Xoodoo IN
	
	// Theta
	wire [0:127] theta_plane;
	assign theta_plane = xoodoo_state_in[0:127] ^ xoodoo_state_in[128:255] ^ xoodoo_state_in[256:383];	
	
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
	assign theta_final_state[0:127] = xoodoo_state_in[0:127] ^ theta_final_plane;
	assign theta_final_state[128:255] = xoodoo_state_in[128:255] ^ theta_final_plane;
	assign theta_final_state[256:383] = xoodoo_state_in[256:383] ^ theta_final_plane;
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
	
	// I starts
	wire [11:0] reversed_rc_wire;
	wire [0:11] rc_wire;
	assign reversed_rc_wire = RC[12*rc_count +:11];
	genvar r;
	generate
	for(r=0;r<12;r=r+1) begin
		assign rc_wire[r] = reversed_rc_wire[r];
	end
	endgenerate
	wire [0:383] I_final_state;
	assign I_final_state[0:11] = west_final_state[0:11] ^ rc_wire[0:11];
	assign I_final_state[12:383] = west_final_state[12:383];
	
	// I ends
	
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
	
	
	wire [0:383] next_round_in = east_final_state[0:383];
	assign xoodoo_state_out = east_final_state[0:383];

/*


	always@(posedge clk) begin
		if(xoodoo_enable == 1'b1 && start_xoodoo==1'b0) begin
			$display("\nStart so State_theta_in[0:127]=%0h at time=%0t",state_in[0:383],$time);
			start_xoodoo <= 1'b1;
			
		end
		else if(start_xoodoo==1'b1 && done_calc==1'b0) begin
			// $display("\n State_theta_in[0:127]=%0h at time=%0t",next_round_in[0:127],$time);
			state_theta_in <= next_round_in;
		end
		
	end
*/

	always@(posedge clk) begin
		if((curr_state == S_A_X) || curr_state == S_S_X) begin
			rc_count <= 4'd11;
			start_reg <= 1'b0;
			$display("RESET DECREMENT COUNTER %d",rc_count);	
		end
		else if((curr_state == ABSORB_XOODOO || curr_state == SQUEEZE_XOODOO) && rc_count > 0) begin
			rc_count <= rc_count - 1'b1;
			start_reg <= 1'b1;
			$display("DECREMENT COUNTER %d and values is %h",rc_count, reversed_rc_wire);	
		end
		else if((curr_state == ABSORB_XOODOO || curr_state == SQUEEZE_XOODOO) && rc_count==1'b0) begin
			rc_count <= 4'd11;
			start_reg <= 1'b0;
			$display("DECREMENT COUNTER %d and values is %h",rc_count, reversed_rc_wire);	
		end	
		
	end
		
		
	always@(posedge clk) begin
		if(resetn==1'b0) begin
			done_calc <= 1'b0;
			$display("Reset done_calc");
		end
		else if(xoodoo_enable == 1'b1 && start_reg == 1'b0) begin
			done_calc <= 1'b0;
			$display("Reset done_calc");
		end
		else if(rc_count == 1'b0 && done_calc==1'b0) begin
			done_calc <= 1'b1;
			$display("Set done_calc");
			//$display("Hardware");
			//$display("%h\n%h\n%h",next_round_in[0:127],next_round_in[128:255], next_round_in[256:383]);
			// $display("Done_calc:%b at %0t", done_calc,$time);
		end
		else begin
			done_calc <= 1'b0;
		//	$display("Reset done_calc");
		end

	end

endmodule
