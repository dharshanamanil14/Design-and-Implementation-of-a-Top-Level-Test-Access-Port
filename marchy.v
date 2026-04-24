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
				output [RAWIDTH-1:0] RA,
				output [CAWIDTH-1:0] CA,
				output we,
				output re,
				output datain,
				output dataout
				);

localparam ROWS = 2**RAWIDTH;
localparam COLS = 2**CAWIDTH;

localparam S_IDLE           = 4'd0;
localparam S_W0             = 4'd1;
localparam S_UP_R0_WAIT     = 4'd2;
localparam S_UP_R0_CHECK    = 4'd3;
localparam S_UP_W1          = 4'd4;
localparam S_UP_R1_WAIT     = 4'd5;
localparam S_UP_R1_CHECK    = 4'd6;
localparam S_DOWN_R1_WAIT   = 4'd7;
localparam S_DOWN_R1_CHECK  = 4'd8;
localparam S_DOWN_W0        = 4'd9;
localparam S_DOWN_R0_WAIT   = 4'd10;
localparam S_DOWN_R0_CHECK  = 4'd11;
localparam S_FINAL_R0_WAIT  = 4'd12;
localparam S_FINAL_R0_CHECK = 4'd13;
localparam S_DONE           = 4'd14;

reg [3:0] state;
reg [RAWIDTH-1:0] row_addr;
reg [CAWIDTH-1:0] col_addr;
reg we_reg;
reg re_reg;
reg datain_reg;

assign RA = row_addr;
assign CA = col_addr;
assign we = we_reg;
assign re = re_reg;
assign datain = datain_reg;

memory_fault_select #(
	.RAWIDTH(RAWIDTH),
	.CAWIDTH(CAWIDTH)
) mem_inst (
	.clk(clk),
	.rst(rst),
	.RA(row_addr),
	.CA(col_addr),
	.we(we_reg),
	.datain(datain_reg),
	.re(re_reg),
	.fault(fault),
	.dataout(dataout)
);

always @(posedge clk)
begin
	if(rst)
	begin
		state <= S_IDLE;
		row_addr <= 0;
		col_addr <= 0;
		we_reg <= 0;
		re_reg <= 0;
		datain_reg <= 0;
		done <= 0;
		fail <= 0;
	end
	else
	begin
		case(state)
			S_IDLE:
			begin
				done <= 0;
				we_reg <= 0;
				re_reg <= 0;
				datain_reg <= 0;
				row_addr <= 0;
				col_addr <= 0;
				if(start)
				begin
					fail <= 0;
					we_reg <= 1;
					datain_reg <= 0;
					state <= S_W0;
				end
			end

			S_W0:
			begin
				we_reg <= 1;
				re_reg <= 0;
				datain_reg <= 0;
				if((row_addr == ROWS-1) && (col_addr == COLS-1))
				begin
					row_addr <= 0;
					col_addr <= 0;
					we_reg <= 0;
					re_reg <= 1;
					state <= S_UP_R0_WAIT;
				end
				else if(col_addr == COLS-1)
				begin
					row_addr <= row_addr + 1'b1;
					col_addr <= 0;
				end
				else
				begin
					col_addr <= col_addr + 1'b1;
				end
			end

			S_UP_R0_WAIT:
			begin
				we_reg <= 0;
				re_reg <= 1;
				state <= S_UP_R0_CHECK;
			end

			S_UP_R0_CHECK:
			begin
				if(dataout != 1'b0)
					fail <= 1;
				we_reg <= 1;
				re_reg <= 0;
				datain_reg <= 1;
				state <= S_UP_W1;
			end

			S_UP_W1:
			begin
				we_reg <= 0;
				re_reg <= 1;
				state <= S_UP_R1_WAIT;
			end

			S_UP_R1_WAIT:
			begin
				we_reg <= 0;
				re_reg <= 1;
				state <= S_UP_R1_CHECK;
			end

			S_UP_R1_CHECK:
			begin
				if(dataout != 1'b1)
					fail <= 1;

				if((row_addr == ROWS-1) && (col_addr == COLS-1))
				begin
					row_addr <= ROWS-1;
					col_addr <= COLS-1;
					state <= S_DOWN_R1_WAIT;
				end
				else
				begin
					if(col_addr == COLS-1)
					begin
						row_addr <= row_addr + 1'b1;
						col_addr <= 0;
					end
					else
					begin
						col_addr <= col_addr + 1'b1;
					end
					state <= S_UP_R0_WAIT;
				end
				we_reg <= 0;
				re_reg <= 1;
			end

			S_DOWN_R1_WAIT:
			begin
				we_reg <= 0;
				re_reg <= 1;
				state <= S_DOWN_R1_CHECK;
			end

			S_DOWN_R1_CHECK:
			begin
				if(dataout != 1'b1)
					fail <= 1;
				we_reg <= 1;
				re_reg <= 0;
				datain_reg <= 0;
				state <= S_DOWN_W0;
			end

			S_DOWN_W0:
			begin
				we_reg <= 0;
				re_reg <= 1;
				state <= S_DOWN_R0_WAIT;
			end

			S_DOWN_R0_WAIT:
			begin
				we_reg <= 0;
				re_reg <= 1;
				state <= S_DOWN_R0_CHECK;
			end

			S_DOWN_R0_CHECK:
			begin
				if(dataout != 1'b0)
					fail <= 1;

				if((row_addr == 0) && (col_addr == 0))
				begin
					row_addr <= 0;
					col_addr <= 0;
					state <= S_FINAL_R0_WAIT;
				end
				else
				begin
					if(col_addr == 0)
					begin
						row_addr <= row_addr - 1'b1;
						col_addr <= COLS-1;
					end
					else
					begin
						col_addr <= col_addr - 1'b1;
					end
					state <= S_DOWN_R1_WAIT;
				end
				we_reg <= 0;
				re_reg <= 1;
			end

			S_FINAL_R0_WAIT:
			begin
				we_reg <= 0;
				re_reg <= 1;
				state <= S_FINAL_R0_CHECK;
			end

			S_FINAL_R0_CHECK:
			begin
				if(dataout != 1'b0)
					fail <= 1;

				if((row_addr == ROWS-1) && (col_addr == COLS-1))
				begin
					we_reg <= 0;
					re_reg <= 0;
					done <= 1;
					state <= S_DONE;
				end
				else
				begin
					if(col_addr == COLS-1)
					begin
						row_addr <= row_addr + 1'b1;
						col_addr <= 0;
					end
					else
					begin
						col_addr <= col_addr + 1'b1;
					end
					we_reg <= 0;
					re_reg <= 1;
					state <= S_FINAL_R0_WAIT;
				end
			end

			S_DONE:
			begin
				we_reg <= 0;
				re_reg <= 0;
				if(!start)
					state <= S_IDLE;
			end

			default:
			begin
				state <= S_IDLE;
				we_reg <= 0;
				re_reg <= 0;
				done <= 0;
			end
		endcase
	end
end

endmodule
