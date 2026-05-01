`timescale 1ns / 1ps

module memory#(parameter RAWIDTH = 2,  CAWIDTH = 2) //RAWIDTH=Row Adress Width and CAWIDTH=Column address width
				(
				// Clock and Reset
				input clk,
				input rst,

				//Column and Row address
				input [RAWIDTH-1:0]RA,
				input [CAWIDTH-1:0]CA,

				// Write Interface
				input we,
				input datain,

				// Read Interface
				input re,
				output reg dataout  //one bit data coming out from one cell
				);
//create memory model
localparam rDEPTH = 2**RAWIDTH;
localparam cDEPTH = 2**CAWIDTH;

reg [cDEPTH-1:0] memory [rDEPTH-1:0];

integer i,j;

always @(posedge clk)
begin
	if(rst)
	begin
		for(i=0; i < 2**RAWIDTH ;i=i+1)
			begin
			for(j=0; j < 2**CAWIDTH;j=j+1)
				begin
					memory[i][j] <= 0;
				end
			end
	end
	else
		begin
			if(we)
				memory[RA][CA] <= datain;
		end
end



always @ (posedge clk)
begin
	if(re)
		dataout <= memory[RA][CA];
end

endmodule   

module memory_SA_marchy#(parameter RAWIDTH = 2,  CAWIDTH = 2)
				(
				input clk,
				input rst,
				input [RAWIDTH-1:0]RA,
				input [CAWIDTH-1:0]CA,
				input we,
				input datain,
				input re,
				output reg dataout
				);

localparam rDEPTH = 2**RAWIDTH;
localparam cDEPTH = 2**CAWIDTH;

reg [cDEPTH-1:0] memory [rDEPTH-1:0];

integer i,j;

always @(posedge clk)
begin
	if(rst)
	begin
		for(i=0; i < 2**RAWIDTH ;i=i+1)
		begin
			for(j=0; j < 2**CAWIDTH;j=j+1)
			begin
				memory[i][j] <= 0;
			end
		end
	end
	else
	begin
		if(we)
			memory[RA][CA] <= datain;
	end

	memory[1][1] <= 0;
	memory[3][2] <= 1;
end

always @ (posedge clk)
begin
	if(re)
		dataout <= memory[RA][CA];
end

endmodule

module memory_T_marchy#(parameter RAWIDTH = 2,  CAWIDTH = 2)
				(
				input clk,
				input rst,
				input [RAWIDTH-1:0]RA,
				input [CAWIDTH-1:0]CA,
				input we,
				input datain,
				input re,
				output reg dataout
				);

localparam rDEPTH = 2**RAWIDTH;
localparam cDEPTH = 2**CAWIDTH;

reg [cDEPTH-1:0] memory [rDEPTH-1:0];

integer i,j;

always @(posedge clk)
begin
	if(rst)
	begin
		for(i=0; i < 2**RAWIDTH ;i=i+1)
		begin
			for(j=0; j < 2**CAWIDTH;j=j+1)
			begin
				memory[i][j] <= 0;
			end
		end
	end
	else
	begin
		if(we)
		begin
			if(RA == 0 && CA == 2 && memory[0][2] == 1'b1 && datain == 1'b0)
				memory[0][2] <= 1'b1; // 1-to-0 transition fault
			else if(RA == 2 && CA == 0 && memory[2][0] == 1'b0 && datain == 1'b1)
				memory[2][0] <= 1'b0; // 0-to-1 transition fault
			else
				memory[RA][CA] <= datain;
		end
	end
end




always @ (posedge clk)
begin
	if(re)
		dataout <= memory[RA][CA];
end

endmodule

module memory_InvC_marchy#(parameter RAWIDTH = 2,  CAWIDTH = 2)
				(
				input clk,
				input rst,
				input [RAWIDTH-1:0]RA,
				input [CAWIDTH-1:0]CA,
				input we,
				input datain,
				input re,
				output reg dataout
				);

localparam rDEPTH = 2**RAWIDTH;
localparam cDEPTH = 2**CAWIDTH;

reg [cDEPTH-1:0] memory [rDEPTH-1:0];

integer i,j;

always @(posedge clk)
begin
	if(rst)
	begin
		for(i=0; i < 2**RAWIDTH ;i=i+1)
		begin
			for(j=0; j < 2**CAWIDTH;j=j+1)
			begin
				memory[i][j] <= 0;
			end
		end
	end
	else
	begin
		if(we)
			memory[RA][CA] <= datain;
	end
end

// Inversion fault with victim cell address < aggressor cell address.
always@(memory[2][3])
begin
	memory[0][2] = ~memory[0][2];
end

always @ (posedge clk)
begin
	if(re)
		dataout <= memory[RA][CA];
end

endmodule




module MBIST_Controller#(parameter RAWIDTH = 2,  CAWIDTH = 2)
				(
				input clk,
				input rst,
				input Test,
				output reg status
				);

//internal registers
localparam integer maxsize = 2**RAWIDTH;
localparam integer CELL_COUNT = maxsize * maxsize;

reg [31:0]count;
reg element_done;
reg [1:0]element_operation;
reg fresh_state;
reg [3:0]state;

//signals and registers used to input the data into the memory through the system
reg [RAWIDTH-1:0] RA;
reg [CAWIDTH-1:0] CA;
reg we,re;
reg datain;
wire dataout;
integer i,j;

initial
begin
	count = 0;
	element_done = 0;
	element_operation = 0;
	fresh_state = 1;
	state = 3'd0;
	status = 0;
	RA = 0;
	CA = 0;
	we = 0;
	re = 0;
	datain = 0;
end

memory u(   //Clock and Reset
            .clk(clk),
            .rst(rst),
            //Row and Column Address
            .RA(RA),
            .CA(CA),
            //Write Interface
            .we(we),
            .datain(datain),
            //Read Interface
            .re(re),
            .dataout(dataout)
        );

// The memory acts on posedge clk, so this controller updates controls on negedge clk.
// This keeps RA, CA, we, re, and datain stable before the memory samples them.
always @(negedge clk)
begin
	if(rst || !Test)
	begin
		count = 0;
		element_done = 0;
		element_operation = 0;
		fresh_state = 1;
		state = 3'd0;
		status = 0;
		RA = 0;
		CA = 0;
		we = 0;
		re = 0;
		datain = 0;
	end
	else
	begin
		case(state)
			3'd0:
			begin
				// W0 (updown)
				if(fresh_state == 1)
				begin
					RA = 0;
					CA = 0;
					count = 0;
					fresh_state = 0;
					$display("W0 (updown) beginning");
				end
				else if(count == CELL_COUNT-1)
				begin
					we = 0;
					re = 0;
					count = 0;
					element_operation = 0;
					fresh_state = 1;
					state = 3'd1;
					$display("W0 (updown) done");
				end
				else
				begin
					count = count+1;
					if(CA == maxsize-1)
					begin
						RA = RA+1;
						CA = 0;
					end
					else
						CA = CA+1;
				end

				if(state == 3'd0)
				begin
					datain = 0;
					we = 1;
					re = 0;
				end
			end

			3'd1:
			begin
				// R0,W1,R1 (up)
				if(fresh_state == 1)
				begin
					$display("R0,W1,R1 (up) beginning");
					RA = 0;
					CA = 0;
					count = 0;
					element_done = 0;
					element_operation = 0;
					fresh_state = 0;
				end

				if(element_done && count == CELL_COUNT-1)
				begin
					we = 0;
					re = 0;
					count = 0;
					element_done = 0;
					element_operation = 0;
					fresh_state = 1;
					state = 3'd2;
					$display("R0,W1,R1 (up) done");
				end
				else
				begin
					if(element_done)
					begin
						element_done = 0;
						count = count+1;
						if(CA == maxsize-1)
						begin
							RA = RA+1;
							CA = 0;
						end
						else
							CA = CA+1;
					end

					case(element_operation)
						2'b00:
						begin
							//R0
							we = 0;
							re = 1;
							element_operation = 2'b01;
						end

						2'b01:
						begin
							//check R0, W1
							if(dataout !== 1'b0)
								status = 1;
							we = 1;
							re = 0;
							datain = 1;
							element_operation = 2'b10;
						end

						2'b10:
						begin
							//R1
							we = 0;
							re = 1;
							element_operation = 2'b11;
						end

						2'b11:
						begin
							//check R1
							if(dataout !== 1'b1)
								status = 1;
							we = 0;
							re = 0;
							element_done = 1;
							element_operation = 2'b00;
						end
					endcase
				end
			end

			3'd2:
			begin
				// R1,W0,R0 (down)
				if(fresh_state == 1)
				begin
					$display("R1,W0,R0 (down) beginning");
					RA = maxsize-1;
					CA = maxsize-1;
					count = 0;
					element_done = 0;
					element_operation = 0;
					fresh_state = 0;
				end

				if(element_done && count == CELL_COUNT-1)
				begin
					we = 0;
					re = 0;
					count = 0;
					element_done = 0;
					element_operation = 0;
					fresh_state = 1;
					state = 3'd3;
					$display("R1,W0,R0 (down) done");
				end
				else
				begin
					if(element_done)
					begin
						element_done = 0;
						count = count+1;
						if(CA == 0)
						begin
							RA = RA-1;
							CA = maxsize-1;
						end
						else
							CA = CA-1;
					end

					case(element_operation)
						2'b00:
						begin
							//R1
							we = 0;
							re = 1;
							element_operation = 2'b01;
						end

						2'b01:
						begin
							//check R1, W0
							if(dataout !== 1'b1)
								status = 1;
							we = 1;
							re = 0;
							datain = 0;
							element_operation = 2'b10;
						end

						2'b10:
						begin
							//R0
							we = 0;
							re = 1;
							element_operation = 2'b11;
						end

						2'b11:
						begin
							//check R0
							if(dataout !== 1'b0)
								status = 1;
							we = 0;
							re = 0;
							element_done = 1;
							element_operation = 2'b00;
						end
					endcase
				end
			end

			3'd3:
			begin
				// R0 (updown)
				if(fresh_state == 1)
				begin
					$display("R0 (updown) beginning");
					RA = 0;
					CA = 0;
					count = 0;
					element_done = 0;
					element_operation = 0;
					fresh_state = 0;
				end

				if(element_done && count == CELL_COUNT-1)
				begin
					we = 0;
					re = 0;
					$display("R0 (updown) done");
					if(status)
						$display("Memory Test Failed");
					else
						$display("Memory Test Passed");
					$finish;
				end
				else
				begin
					if(element_done)
					begin
						element_done = 0;
						count = count+1;
						if(CA == maxsize-1)
						begin
							RA = RA+1;
							CA = 0;
						end
						else
							CA = CA+1;
					end

					case(element_operation)
						2'b00:
						begin
							//R0
							we = 0;
							re = 1;
							element_operation = 2'b01;
						end

						2'b01:
						begin
							//check R0
							if(dataout !== 1'b0)
								status = 1;
							we = 0;
							re = 0;
							element_done = 1;
							element_operation = 2'b00;
						end
					endcase
				end
			end

			default:
			begin
				state = 3'd0;
				fresh_state = 1;
			end
		endcase
	end
end

//Print the test result
always @(Test, status)
begin
	if(Test)
		if(status)
		begin
			$display("Error found !!");
			$display("Memory Test Failed");
		end
end

always @(negedge clk)
begin
	if(Test)
	begin
		for(i=0; i<maxsize; i=i+1)
		begin
			for(j=0; j<maxsize; j=j+1)
			begin
				$write("%b",u.memory[i][j]);
			end
			$display();
		end
		$display();
	end
end

endmodule
