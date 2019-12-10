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
		IDLE	 		= 4'd0,
		LOAD 	 		= 4'd1,
		ABSORB   		= 4'd2,
		ABSORB_XOODOO   = 4'd4,
		ABSORB_UP 		= 4'd5,
		ABSORB_DOWN 	= 4'd6,
		SQUEEZE  		= 4'd7,
		SQUEEZE_XOODOO  = 4'd8,
		SQUEEZE_UP 		= 4'd9,
		SQUEEZE_DOWN 	= 4'd10,
		EXTRACT  		= 4'd11;

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
	reg msg_len_red;
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
					if (counter_complete == 1) curr_state <= ABSORB_DOWN;
				end
				ABSORB_DOWN:
				begin
				 	$display("ABSORB DOWN");
				 	curr_state <= ABSORB_UP;
				end
				ABSORB_UP:
				begin
					$display("ABSORB UP");
					curr_state <= ABSORB_XOODOO;	
				end 
				ABSORB_XOODOO:
				begin
					$display("ABSORB XOODOO");
					if(next_msg_len==0 && counter_complete) curr_state <= SQUEEZE;
					else if(counter_complete) curr_state <= ABSORB;		
				end
				SQUEEZE:
				begin
					$display("SQUEEZE");
					curr_state <= SQUEEZE_UP; 
				end
				SQUEEZE_DOWN:
				begin
				 	$display("SQUEEZE DOWN");
				 	curr_state <= SQUEEZE_UP;
				end
				SQUEEZE_UP:
				begin
					$display("SQUEEZE UP");
					curr_state <= SQUEEZE_XOODOO;	
				end 
				SQUEEZE_XOODOO:
				begin
					$display("SQUEEZE XOODOO");
					if(counter_complete) curr_state <= EXTRACT;		
				end 
				EXTRACT:
				begin
					$display("EXTRACT");
					if(counter_complete && hash_len==31) curr_state <= IDLE;
					else if(counter_complete) curr_state <= SQUEEZE_DOWN;		
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
		else if(curr_state==ABSORB || curr_state==ABSORB_XOODOO || curr_state==SQUEEZE_XOODOO || curr_state==EXTRACT) counter <= counter + 1;
		else counter <= counter;

		if(curr_state == LOAD) counter_complete <= load_reg;
		else if(curr_state==ABSORB) counter_complete <= counter == 9'h0e; // state change at 0x0f
		//else if(curr_state==ABSORB && next_msg_len < 16) counter_complete <= counter == next_msg_len-1; //next_msg_len+1
		else if (curr_state==ABSORB_XOODOO || curr_state==SQUEEZE_XOODOO) counter_complete <= counter == 9'h12;
		else if (curr_state==EXTRACT) counter_complete <= counter == 9'h0e;
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

	// msg length modify after each round 
	always @(posedge clk or negedge resetn) begin
		if(~resetn) msg_len_red <= 0;
		else if(curr_state== ABSORB && msg_len_red == 0) msg_len_red <= 1;
		else msg_len_red <= 0;
	end

	// Reduce the Msg Length 
	always @(posedge clk or negedge resetn) begin
		if(~resetn) next_msg_len <= 0;
		else if (curr_state==LOAD) next_msg_len <= msg_len;
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
			load_reg <=0;
			msg_len_reg <= 0;
		end else begin
			cur_msg_reg <= msg;
			load_reg <= load;
			msg_len_reg <= msg_len;
		end
	end

	// load msg and rotate msg block
	always @(posedge clk or negedge resetn) begin
		if(~resetn) msg_in <= 0; 
		else if(load_reg==1) msg_in <= {cur_msg_reg,msg_in[1023:1]}; // feed msg 
		else if(curr_state==ABSORB) msg_in <= {msg_in[1022:0],msg_in[1023]}; // rotate msg 
		else msg_in <= msg_in;
	end

	// Create teh Data Block (16 Bytes --> 128 bits)
	always @(posedge clk or negedge resetn) begin
			if(~resetn || curr_state==ABSORB_XOODOO) next_block <= 0;
			else if (curr_state==ABSORB && next_msg_len >= 16) next_block <= {msg_in[1023],next_block[15:1]};
			else if (curr_state==ABSORB && next_msg_len < 16) next_block <= {((counter == next_msg_len) ? 01 : msg_in[1023]),next_block[15:1]};			
			else next_block <= next_block;
	end	
	
	// Down Operation and Xoodoo complete Update state register  
	always @(posedge clk or negedge resetn) begin : proc_down
		if(~resetn || curr_state==LOAD) state_register <= 0;
		else if (curr_state==ABSORB_DOWN) begin
			state_register[127:0]   <= state_register[127:0]^next_block;
			
			if(next_msg_len >= 16 ) state_register[128] <= state_register[128]^1;
			else state_register[128] <= state_register[128];

			state_register[375:129] <= state_register[375:129];
			state_register[376] 	<= state_register[376]^c_d;
			state_register[383:377] <= state_register[383:377];
		end
		else if (curr_state==ABSORB_XOODOO && xoodoo_complete) state_register <= state_in; 
		else if (curr_state==EXTRACT) state_register[127:0] <= {state_register[7:0],state_register[127:8]};
		else state_register <= state_register;
	end

	// C_D Update
	always @(posedge clk or negedge resetn) begin : proc_c_d
		if(~resetn || curr_state==LOAD) c_d <= 1;
		else if (curr_state==ABSORB_UP) c_d <= 0;
		else c_d <= c_d;
	end

	// Enable XOODOO and run xoodoo with updated vector
	always @(posedge clk or negedge resetn) begin : proc_
		if(~resetn) state_out <= 0;
		else if(curr_state==ABSORB_XOODOO) state_out <= state_register;
		else state_out <= state_out;
	end

	// Increase hash len
	always @(posedge clk or negedge resetn) begin
		if(~resetn) hash_len <= 0;
		else if (curr_state==EXTRACT) hash_len <= hash_len + 1;
		else hash_len <= hash_len;
	end

	// Output Hash 
	always @(posedge clk or negedge resetn) begin
		if(~resetn) hash <= 0;
		else if (curr_state==EXTRACT) hash <= state_register[7:0];
		else hash <= hash;
	end



endmodule
