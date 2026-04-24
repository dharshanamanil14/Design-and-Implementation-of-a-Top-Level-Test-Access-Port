`timescale 1ns / 1ps

//(1)Transaction of only bit is allowed(i.e datain and dataout are of 1 bit each) 
//   since march algorithm is primarily useful for cell testing.
//(2)4x4 memory array created. A cell can be selected by giving both row address(RA)
//   and column address(CA)
//(3)fault opcode: 00=stuck-at, 01=transition, 10=inversion coupling, 11=normal


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

	memory[0][1] <= 1;
	memory[0][0] <= 0;
	memory[3][0] <= 1;
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
			memory[RA][CA] <= datain;
	end
end

always @(negedge memory[1][3])
begin
	memory[1][3] = ~memory[1][3];
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

module memory_fault_select#(parameter RAWIDTH = 2,  CAWIDTH = 2)
				(
				input clk,
				input rst,
				input [RAWIDTH-1:0]RA,
				input [CAWIDTH-1:0]CA,
				input we,
				input datain,
				input re,
				input [1:0] fault,
				output reg dataout
				);

wire normal_dataout;
wire sa_dataout;
wire transition_dataout;
wire inversion_dataout;

memory #(
	.RAWIDTH(RAWIDTH),
	.CAWIDTH(CAWIDTH)
) u_memory (
	.clk(clk),
	.rst(rst),
	.RA(RA),
	.CA(CA),
	.we(we && (fault == 2'b11)),
	.datain(datain),
	.re(re && (fault == 2'b11)),
	.dataout(normal_dataout)
);

memory_SA_marchy #(
	.RAWIDTH(RAWIDTH),
	.CAWIDTH(CAWIDTH)
) u_memory_sa (
	.clk(clk),
	.rst(rst),
	.RA(RA),
	.CA(CA),
	.we(we && (fault == 2'b00)),
	.datain(datain),
	.re(re && (fault == 2'b00)),
	.dataout(sa_dataout)
);

memory_T_marchy #(
	.RAWIDTH(RAWIDTH),
	.CAWIDTH(CAWIDTH)
) u_memory_t (
	.clk(clk),
	.rst(rst),
	.RA(RA),
	.CA(CA),
	.we(we && (fault == 2'b01)),
	.datain(datain),
	.re(re && (fault == 2'b01)),
	.dataout(transition_dataout)
);

memory_InvC_marchy #(
	.RAWIDTH(RAWIDTH),
	.CAWIDTH(CAWIDTH)
) u_memory_invc (
	.clk(clk),
	.rst(rst),
	.RA(RA),
	.CA(CA),
	.we(we && (fault == 2'b10)),
	.datain(datain),
	.re(re && (fault == 2'b10)),
	.dataout(inversion_dataout)
);

always @*
begin
	case(fault)
		2'b00: dataout = sa_dataout;
		2'b01: dataout = transition_dataout;
		2'b10: dataout = inversion_dataout;
		default: dataout = normal_dataout;
	endcase
end

endmodule

module MarchY #(parameter RAWIDTH = 2, CAWIDTH = 2)
				(
				input clk,
				input rst,
				input start,
				input [1:0] fault,
				output reg done,
				output reg fail,
				output reg [RAWIDTH-1:0] RA,
				output reg [CAWIDTH-1:0] CA,
				output reg we,
				output reg re,
				output reg datain,
				output dataout
				);

localparam ROWS = 2**RAWIDTH;
localparam COLS = 2**CAWIDTH;
localparam CELL_COUNT = ROWS * COLS;

reg Test;
reg [3:0] state;
reg [3:0] nextstate;
reg [31:0] count;
reg element_done;
reg [1:0] element_operation;
reg fresh_state;

memory_fault_select #(
	.RAWIDTH(RAWIDTH),
	.CAWIDTH(CAWIDTH)
) mem_inst (
	.clk(clk),
	.rst(rst),
	.RA(RA),
	.CA(CA),
	.we(we),
	.datain(datain),
	.re(re),
	.fault(fault),
	.dataout(dataout)
);

// Drive the memory interface from the current March element and operation.
always @*
begin
	we = 0;
	re = 0;
	datain = 0;

	if(Test && !fresh_state && !element_done)
	begin
		case(state)
			3'd0:
			begin
				// W0 (updown)
				we = 1;
				datain = 0;
			end

			3'd1:
			begin
				// R0,W1,R1 (up)
				case(element_operation)
					2'b00: re = 1;                       // R0
					2'b01: begin we = 1; datain = 1; end // W1
					2'b10: re = 1;                       // R1
					2'b11: re = 1;                       // check R1
				endcase
			end

			3'd2:
			begin
				// R1,W0,R0 (down)
				case(element_operation)
					2'b00: re = 1;                       // R1
					2'b01: begin we = 1; datain = 0; end // W0
					2'b10: re = 1;                       // R0
					2'b11: re = 1;                       // check R0
				endcase
			end

			3'd3:
			begin
				// R0 (updown)
				re = 1;
			end
		endcase
	end
end

always @(posedge clk)
begin
	if(rst)
	begin
		Test <= 0;
		done <= 0;
		fail <= 0;
		state <= 3'd0;
		nextstate <= 3'd0;
		RA <= 0;
		CA <= 0;
		count <= 0;
		element_done <= 0;
		element_operation <= 0;
		fresh_state <= 1;
	end
	else if(!start)
	begin
		Test <= 0;
		done <= 0;
		fail <= 0;
		state <= 3'd0;
		nextstate <= 3'd0;
		RA <= 0;
		CA <= 0;
		count <= 0;
		element_done <= 0;
		element_operation <= 0;
		fresh_state <= 1;
	end
	else if(!Test && !done)
	begin
		Test <= 1;
		done <= 0;
		fail <= 0;
		state <= 3'd0;
		nextstate <= 3'd0;
		RA <= 0;
		CA <= 0;
		count <= 0;
		element_done <= 0;
		element_operation <= 0;
		fresh_state <= 1;
	end
	else if(Test)
	begin
		case(state)
			3'd0:
			begin
				// W0 (updown)
				if(fresh_state == 1)
				begin
					// Set the address to the first cell.
					RA <= 0;
					CA <= 0;
					count <= 0;
					element_done <= 0;
					fresh_state <= 0;
				end
				else if(element_done)
				begin
					element_done <= 0;
					if(count == CELL_COUNT-1)
					begin
						// W0 (updown) done.
						nextstate <= 3'd1;
						state <= 3'd1;
						fresh_state <= 1;
					end
					else
					begin
						count <= count + 1;
						if(CA == COLS-1)
						begin
							RA <= RA + 1'b1;
							CA <= 0;
						end
						else
							CA <= CA + 1'b1;
					end
				end
				else
				begin
					// W0 is issued by the memory control block in this cycle.
					element_done <= 1;
				end
			end

			3'd1:
			begin
				// R0,W1,R1 (up)
				if(fresh_state == 1)
				begin
					// Set the address to the first cell.
					RA <= 0;
					CA <= 0;
					count <= 0;
					element_done <= 0;
					element_operation <= 0;
					fresh_state <= 0;
				end
				else if(element_done)
				begin
					element_done <= 0;
					element_operation <= 0;
					if(count == CELL_COUNT-1)
					begin
						// R0,W1,R1 (up) done.
						nextstate <= 3'd2;
						state <= 3'd2;
						fresh_state <= 1;
					end
					else
					begin
						count <= count + 1;
						if(CA == COLS-1)
						begin
							RA <= RA + 1'b1;
							CA <= 0;
						end
						else
							CA <= CA + 1'b1;
					end
				end
				else
				begin
					case(element_operation)
						2'b00:
						begin
							// R0: read is issued in this cycle.
							element_operation <= 2'b01;
						end

						2'b01:
						begin
							// Check R0, then W1 is issued in this cycle.
							if(dataout != 0)
								fail <= 1;
							element_operation <= 2'b10;
						end

						2'b10:
						begin
							// R1: read is issued in this cycle.
							element_operation <= 2'b11;
						end

						2'b11:
						begin
							// Check R1.
							if(dataout != 1)
								fail <= 1;
							element_done <= 1;
						end
					endcase
				end
			end

			3'd2:
			begin
				// R1,W0,R0 (down)
				if(fresh_state == 1)
				begin
					// Set the address to the last cell.
					RA <= ROWS-1;
					CA <= COLS-1;
					count <= 0;
					element_done <= 0;
					element_operation <= 0;
					fresh_state <= 0;
				end
				else if(element_done)
				begin
					element_done <= 0;
					element_operation <= 0;
					if(count == CELL_COUNT-1)
					begin
						// R1,W0,R0 (down) done.
						nextstate <= 3'd3;
						state <= 3'd3;
						fresh_state <= 1;
					end
					else
					begin
						count <= count + 1;
						if(CA == 0)
						begin
							RA <= RA - 1'b1;
							CA <= COLS-1;
						end
						else
							CA <= CA - 1'b1;
					end
				end
				else
				begin
					case(element_operation)
						2'b00:
						begin
							// R1: read is issued in this cycle.
							element_operation <= 2'b01;
						end

						2'b01:
						begin
							// Check R1, then W0 is issued in this cycle.
							if(dataout != 1)
								fail <= 1;
							element_operation <= 2'b10;
						end

						2'b10:
						begin
							// R0: read is issued in this cycle.
							element_operation <= 2'b11;
						end

						2'b11:
						begin
							// Check R0.
							if(dataout != 0)
								fail <= 1;
							element_done <= 1;
						end
					endcase
				end
			end

			3'd3:
			begin
				// R0 (updown)
				if(fresh_state == 1)
				begin
					// Set the address to the first cell.
					RA <= 0;
					CA <= 0;
					count <= 0;
					element_done <= 0;
					element_operation <= 0;
					fresh_state <= 0;
				end
				else if(element_done)
				begin
					element_done <= 0;
					if(count == CELL_COUNT-1)
					begin
						// R0 (updown) done.
						Test <= 0;
						done <= 1;
						nextstate <= 3'd4;
						state <= 3'd4;
					end
					else
					begin
						count <= count + 1;
						if(CA == COLS-1)
						begin
							RA <= RA + 1'b1;
							CA <= 0;
						end
						else
							CA <= CA + 1'b1;
					end
				end
				else
				begin
					case(element_operation)
						2'b00:
						begin
							// R0: read is issued in this cycle.
							element_operation <= 2'b01;
						end

						2'b01:
						begin
							// Check R0.
							if(dataout != 0)
								fail <= 1;
							element_done <= 1;
							element_operation <= 2'b00;
						end
					endcase
				end
			end

			3'd4:
			begin
				// Test complete. Hold done/fail until start is deasserted.
				Test <= 0;
				done <= 1;
			end
		endcase
	end
end

endmodule
