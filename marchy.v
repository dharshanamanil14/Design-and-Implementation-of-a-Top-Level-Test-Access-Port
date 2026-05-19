`timescale 1ns / 1ps

module ram #(
    parameter AWIDTH = 4
) (
    clk,
    reset,
    wr_addr,
    rd_addr,
    data_in,
    data_out,
    we,
    re,
    fault
);

    input we, re, clk, reset;
    input [1:0] fault;
    input [AWIDTH-1:0] wr_addr;
    input [AWIDTH-1:0] rd_addr;
    input data_in;
    output reg data_out;

    integer i;
    integer j;

    reg [3:0] memory [3:0];
    // reg [1:0] wr_addr[3:2];
    // reg [1:0] wr_addr[1:0];
    // reg [1:0] rd_addr[3:2];
    // reg [1:0] rd_addr[1:0];
    // {4'b0000,4'b0000,4'b0000,4'b0000};

    always @(posedge clk) begin
        if (reset) begin
            // rd_addr[3:2] <= 0;
            // rd_addr[1:0] <= 0;
            data_out <= 0;
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < 4; j = j + 1) begin
                    memory[i][j] <= 1;
                end
            end
        end else begin
            if (re) begin
                // rd_addr[3:2] <= rd_addr[3:2];
                // rd_addr[1:0] <= rd_addr[1:0];
                data_out <= memory[rd_addr[1:0]][rd_addr[3:2]];
            end
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            // wr_addr[3:2] <= 0;
            // wr_addr[1:0] <= 0;
            data_out <= 0;
        end else begin
            if (we) begin
                // wr_addr[3:2] <= wr_addr[3:2];
                // wr_addr[1:0] <= wr_addr[1:0];
                case (fault)
                    2'b00: begin // stuck at fault
                        memory[1][1] <= 0;
                        memory[3][2] <= 1;
                        if (~((wr_addr[1:0] == 1 && wr_addr[3:2] == 1) ||
                              (wr_addr[1:0] == 3 && wr_addr[3:2] == 2))) begin
                            memory[wr_addr[1:0]][wr_addr[3:2]] <= data_in;

//                          if (wr_addr[1:0] == 1 && wr_addr[3:2] == 1)
//                              memory[wr_addr[1:0]][wr_addr[3:2]] <= 0; // s-a-0
//                          else if (wr_addr[1:0] == 3 && wr_addr[3:2] == 2)
//                              memory[wr_addr[1:0]][wr_addr[3:2]] <= 1; // s-a-1
//                          else
//                              memory[wr_addr[1:0]][wr_addr[3:2]] <= data_in;
                        end
                    end

                    2'b01: begin
                        if (wr_addr[1:0] == 0 && wr_addr[3:2] == 2) begin
                            memory[wr_addr[1:0]][wr_addr[3:2]] <= memory[wr_addr[1:0]][wr_addr[3:2]] & data_in; // 0->1 transition fault
                            $display("0->1 Transisition fault detected");
                        end else if (wr_addr[1:0] == 2 && wr_addr[3:2] == 0) begin
                            memory[wr_addr[1:0]][wr_addr[3:2]] <= memory[2][0] | data_in; // 1->0 transition fault
                            $display("1->0 Transisition fault detected");
                        end else begin
                            memory[wr_addr[1:0]][wr_addr[3:2]] <= data_in;
                            $display("No transition faults detected");
                        end
                    end

                    2'b10: begin
                        if (wr_addr[1:0] == 3 && wr_addr[3:2] == 1) begin
                            // when (1,3) changes from 0->1 or 1->0, (0,3) toggles
                            memory[wr_addr[1:0]][wr_addr[3:2]-1] <= memory[wr_addr[1:0]][wr_addr[3:2]-1] ^ (memory[wr_addr[1:0]][wr_addr[3:2]] ^ data_in);
                            memory[wr_addr[1:0]][wr_addr[3:2]] <= data_in;
                        end else begin
                            memory[wr_addr[1:0]][wr_addr[3:2]] <= data_in;
                        end
                    end

                    2'b11: begin
                        memory[wr_addr[1:0]][wr_addr[3:2]] <= data_in;
                    end
                endcase
            end
        end
    end

endmodule




module MBIST_Controller#(
				parameter RAWIDTH = 2,
				parameter CAWIDTH = 2
				)
				(
				input clk,
				input rst,
				input Test,
				input [1:0] FAULT,
				output reg status
				);

//internal registers
localparam integer maxsize = 2**RAWIDTH;
localparam integer CELL_COUNT = maxsize * maxsize;

reg [4:0]count;
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
wire [3:0] mem_addr;
integer i,j;

assign mem_addr = {CA, RA};

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

ram u(      // Same memory interface/behavior as maxchx.v
            .clk(clk),
            .reset(rst),
            .wr_addr(mem_addr),
            .rd_addr(mem_addr),
            .data_in(datain),
            .data_out(dataout),
            .we(we),
            .re(re),
            .fault(FAULT)
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
