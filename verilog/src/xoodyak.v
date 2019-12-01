module XOODYAK(
	input wire clk, 
	input wire resetn, 
	input wire start, 
	input wire load,
	input wire xoodoo_complete,
	input wire [383:0] state_in,
	input wire [7:0] msg,
	input wire [11:0] msg_len, 

	output reg xoodoo_enable,
	output reg [383:0] state_out,
	output reg [7:0] hash, 
	output reg [7:0] hash_len, 
	output reg valid
	);

	parameter [3:0]
		IDLE	 = 4'd0,
		LOAD 	 = 4'd1,
		ABSORB   = 4'd2,
		SQUEEZE  = 4'd3,
		XOODOO   = 4'd4,
		UP 		 = 4'd5,
		DOWN 	 = 4'd6,
		EXTRACT  = 4'd7;

	reg [1023:0][7:0] msg_in;
	
	reg [3:0] 		curr_state;
	reg 			start_en;
	reg 			next_block_ready;
	
	reg 			counter_complete;
	reg [8:0] 		counter;

	reg [383:0] 	state_register;

	reg [15:0][7:0] next_block; 

	reg [11:0] 		next_msg_len;

	reg c_d;

	reg [7:0] cur_msg_reg;
	reg [11:0] msg_len_reg;
	reg load_reg;

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
					$display("IDLE");
					if (load_reg == 1) curr_state <= LOAD;	
					if (start_en == 1) curr_state <= ABSORB;
				end
				LOAD:
				begin
					$display("LOAD");
					if (start_en == 1) curr_state <= ABSORB;
					else if (load_reg == 0) curr_state <= IDLE;
				end
				ABSORB:
				begin
					$display("ABSORB");
					if (counter_complete == 1) curr_state <= DOWN;
				end
				SQUEEZE:
				begin
					$display("SQUEEZE");
					if(counter_complete) curr_state <= SQUEEZE; 
				end
				DOWN:
				begin
				 	$display("DOWN");
				 	curr_state <= UP;
				end
				UP:
				begin
					$display("UP");
					if(counter_complete) curr_state <= XOODOO;	
				end 
				XOODOO:
				begin
					$display("XOODOO");
					if(counter_complete) curr_state <= ABSORB;		
				end
				default: begin
					$display("DEFAULT");
					curr_state <= IDLE;
				end
			endcase
		end
	end

	// Conditional Counter
	always @(posedge clk or negedge resetn) begin 
		if(~resetn || counter_complete) counter <= 0;
		else if(curr_state==ABSORB || curr_state==UP || curr_state==XOODOO || curr_state==DOWN) counter <= counter + 1;
		else counter <= counter;

		if(curr_state == LOAD) counter_complete <= load_reg;
		else if(curr_state==ABSORB && next_msg_len >= 16) counter_complete <= counter == 9'h0e; // state change at 0x0f
		else if(curr_state==ABSORB && next_msg_len < 16) counter_complete <= counter == next_msg_len; //next_msg_len+1
		else if (curr_state==DOWN || curr_state==UP) counter_complete <= counter == 9'h00;
		else if (curr_state==XOODOO) counter_complete <= counter == 9'h12;
		else counter_complete <= counter == 9'hff;

		if(curr_state==ABSORB) next_block_ready <= counter == 9'h0f;
		else next_block_ready <= 0;

		if(curr_state==XOODOO) xoodoo_enable <= counter == 9'h00;
		else xoodoo_enable <= 0;
	end	

	// Valid 
	always@(posedge clk)
		begin
			if(~resetn) valid <= 0;
			else valid <= !(counter == 9'hff) && curr_state==EXTRACT;
		end

	// Start Enable
	always@(posedge clk)
		begin
			if(~resetn) start_en <= 0;
			else start_en <= start_en | start;
		end	

	// Reduce the Msg Length 
	always @(posedge clk or negedge resetn) begin
		if(~resetn) next_msg_len <= 0;
		else if (curr_state==LOAD) next_msg_len <= msg_len - 12'h010;
		else if(curr_state==ABSORB && next_block_ready) next_msg_len <= next_msg_len-12'h010;
		else next_msg_len <= next_msg_len;
	end


// *************************************Data Path*************************************** 

	// Register the input msg byte 
	always @(posedge clk or negedge resetn) begin : proc_msg
		if(~resetn) begin
			cur_msg_reg <= 0;
			load_reg <=0;
		end else begin
			cur_msg_reg <= msg;
			load_reg <= load;
		end
	end

	always @(posedge clk or negedge resetn) begin
		if(~resetn) msg_in <= 0;
		else if(load_reg==1) msg_in <= {cur_msg_reg,msg_in[1023:1]};
		else if(curr_state==ABSORB) msg_in <= {msg_in[0], msg_in[1023:1]};
		else msg_in <= msg_in;
	end

	// Create teh Data Block (16 Bytes --> 128 bits)
	always @(posedge clk or negedge resetn) begin
			if(~resetn) next_block <= 0;
			else if (curr_state==ABSORB && next_msg_len >= 16) next_block <= {msg_in[0],next_block[15:1]};
			else if (curr_state==ABSORB && next_msg_len < 16) next_block <= {((counter == next_msg_len) ? 01 : msg_in[0]),next_block[15:1]};			
			else next_block <= next_block;
	end	
	
	// Down Operation and Xoodoo complete Update state register  
	always @(posedge clk or negedge resetn) begin : proc_down
		if(~resetn || curr_state==LOAD) state_register <= 0;
		else if (curr_state==DOWN) begin
			state_register[127:0]   <= state_register[127:0]^next_block;
			
			if(next_msg_len >= 16 ) state_register[128] <= state_register[128]^1;
			else state_register[128] <= state_register[128];

			state_register[375:129] <= state_register[375:129];
			state_register[376] 	<= state_register[376]^c_d;
			state_register[383:377] <= state_register[383:377];
		end
		else if (curr_state==XOODOO && xoodoo_complete) state_register <= state_in; 
		else state_register <= state_register;
	end

	// C_D Update
	always @(posedge clk or negedge resetn) begin : proc_c_d
		if(~resetn || curr_state==LOAD) c_d <= 1;
		else if (curr_state==UP) c_d <= 0;
		else c_d <= c_d;
	end

	// Enable XOODOO and run xoodoo with updated vector
	always @(posedge clk or negedge resetn) begin : proc_
		if(~resetn) state_out <= 0;
		else if(curr_state==XOODOO) state_out <= state_register;
		else state_out <= state_out;
	end

endmodule
