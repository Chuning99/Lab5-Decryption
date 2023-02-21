// CSE 140L -- lab 5 

module top_level_5b(
	input			clk,
					init, 
	output logic   	done
				   );

// memory interface 
	logic          	write_en;
	logic   [7:0] 	raddr, 
					waddr,
					data_in;
	logic	[7:0] 	data_out; 
  
// program counter             
	logic	[15:0] 	cycle_ct = 0;

// LFSR interface
	logic 	load_LFSR,
			LFSR_en;
	logic	[4:0] 	LFSR_ptrn[6];           // the 6 possible maximal length LFSR patterns
	assign 	LFSR_ptrn[0] = 5'h1E;
	assign 	LFSR_ptrn[1] = 5'h1D;
	assign 	LFSR_ptrn[2] = 5'h1B;
	assign 	LFSR_ptrn[3] = 5'h17;
	assign 	LFSR_ptrn[4] = 5'h14;
	assign 	LFSR_ptrn[5] = 5'h12;
	logic [4:0]    temp_data;
	logic	[4:0] 	start;                  // LFSR starting state
	logic	[4:0] 	compare_bit;            // Compare LFSR with initial
	logic	[4:0] 	LFSR_state[6];          // current states of the 6 LFSRs
	logic	[2:0] 	foundit;                // got a match for one LFSR
	logic	[5:0] 	match;					// index of foundit
	int i;
  
// instantiate submodules
// data memory -- fill in the connections
	dat_mem dm1(
					.clk	 ,
					.write_en,
					.raddr	 ,
					.waddr	 ,
					.data_in ,
					.data_out
				);                   // instantiate data memory

// 6 parallel LFSRs -- fill in the missing connections													  
	lfsr5 l0(
				.clk	   (clk) , 
				.en   	(LFSR_en)  ,     // 1: advance LFSR on rising clk
				.init 	(load_LFSR),	      // 1: initialize LFSR
				.taps 	(5'h1E),  // tap pattern for LFSR
				.start	(start) ,	  // starting state for LFSR
				.state	(LFSR_state[0])	// LFSR state = LFSR output 
			 );
	lfsr5 l1(
				.clk	   (clk) , 
				.en   	(LFSR_en)  ,     // 1: advance LFSR on rising clk
				.init 	(load_LFSR),	      // 1: initialize LFSR
				.taps 	(5'h1D),  // tap pattern for LFSR
				.start	(start) ,	  // starting state for LFSR
				.state	(LFSR_state[1])	// LFSR state = LFSR output 
			 );
	lfsr5 l2(
				.clk	   (clk) , 
				.en   	(LFSR_en)  ,     // 1: advance LFSR on rising clk
				.init 	(load_LFSR),	      // 1: initialize LFSR
				.taps 	(5'h1B),  // tap pattern for LFSR
				.start	(start) ,	  // starting state for LFSR
				.state	(LFSR_state[2])	// LFSR state = LFSR output 
			 );
	lfsr5 l3(
				.clk	   (clk) , 
				.en   	(LFSR_en)  ,     // 1: advance LFSR on rising clk
				.init 	(load_LFSR),	      // 1: initialize LFSR
				.taps 	(5'h17),  // tap pattern for LFSR
				.start	(start) ,	  // starting state for LFSR
				.state	(LFSR_state[3])	// LFSR state = LFSR output 
			 );
	lfsr5 l4(
				.clk	   (clk) , 
				.en   	(LFSR_en)  ,     // 1: advance LFSR on rising clk
				.init 	(load_LFSR),	      // 1: initialize LFSR
				.taps 	(5'h14),  // tap pattern for LFSR
				.start	(start) ,	  // starting state for LFSR
				.state	(LFSR_state[4])	// LFSR state = LFSR output 
			 );
	lfsr5 l5(
				.clk	   (clk) , 
				.en   	(LFSR_en)  ,     // 1: advance LFSR on rising clk
				.init 	(load_LFSR),	      // 1: initialize LFSR
				.taps 	(5'h12),  // tap pattern for LFSR
				.start	(start) ,	  // starting state for LFSR
				.state	(LFSR_state[5])	// LFSR state = LFSR output 
			 );
			 

// program counter and matching to correct LFSR
	always @(posedge clk) begin  :clock_loop										 
		if(init) begin
			cycle_ct <= 'b0;
			match    <= 6'h3F;
		end
		else begin
			cycle_ct <= cycle_ct + 1;
			if(cycle_ct>='d2 && cycle_ct<= 'd6) begin			// decide cycle_ct range that requires checking		
			  temp_data = data_out[4:0];  
				for(i=0; i<6; i++) begin
				   if(({5'b0,LFSR_state[i]} ^ temp_data)!= 5'h7E) begin
					   match[i] <= 0;			// which LFSR state conforms to our test bench LFSR 
               end						
				end
			end
		end
	end  
  
// this block remaps a one-hot 6-bit code into a 3-bit binary count
// acts like a priority encoder from MSB to LSB 
	always_comb begin
		case(match)
			6'b10_0000: foundit = 'd5;	    // because bit [5] was set
			6'b01_0000: foundit = 'd4;	    // because bit [5] was set
			6'b00_1000: foundit = 'd3;	    // because bit [5] was set
			6'b00_0100: foundit = 'd2;	    // because bit [5] was set
			6'b00_0010: foundit = 'd1;	    // because bit [5] was set
			6'b00_0001: foundit = 'd0;	    // because bit [5] was set
			default: foundit = 0;           // covers bit[0] match and no match cases
		endcase
	end


	always_comb begin 
		//defaults
		load_LFSR = 'b0; 
		LFSR_en   = 'b0;   
		write_en  = 'b0;
		done      = 'b0;
		start = 'b0;
		data_in = 'b0;
		case(cycle_ct)
			0: begin 
				raddr     = 'd128;   // starting address for encrypted data to be loaded into device
				waddr     = 'd192;   // starting address for storing decrypted results into data mem
			   done      =  'b0;
			end		       // no op
			1: begin 
				load_LFSR = 'b1;	  // initialize the 6 LFSRs
				raddr     = 'd128;
				start = data_out ^ 8'h7E;
				waddr     = 'd192;
				done      =  'b0;
			end		       // no op
			2  : begin				   
				LFSR_en   = 'b1;	   
				raddr     = 'd128;
				waddr     = 'd192;
				done      =  'b0;
			end
			3  : begin			       
				LFSR_en   = 'b1;
				raddr     = 'd129;			
				waddr     = 'd192;
				done      =  'b0;
			end
			72  : begin
			  
				raddr     =	'd128;   // send acknowledge back to test bench to halt simulation
				waddr     = 'd192;
				done      = 'b1; 
				
			end
			default: begin	         
				LFSR_en   = 'b1;
				raddr = 'd128 + cycle_ct -'d2; 
				if(cycle_ct > 'd8) begin   // turn on write enable
					write_en = 'b1;
							 // advance memory write address pointer
					waddr = 'd192 + cycle_ct - 'd9;
				end
				else begin
				   write_en = 'b0;
					waddr = 'd128;
					end
		   	data_in = data_out^LFSR_state[foundit];
				done = 'b0;
			end
		endcase
	end

endmodule


