`timescale 1ns / 1ps

module MarchA_tb;

parameter CAWIDTH = 2;
parameter RAWIDTH = 2;
localparam ROWS = 2**RAWIDTH;
localparam COLS = 2**CAWIDTH;

integer i, j;

reg clk;
reg rst;
reg start;
reg [1:0] fault;

wire done;
wire fail;
wire [RAWIDTH-1:0] RA;
wire [CAWIDTH-1:0] CA;
wire we;
wire re;
wire datain;
wire dataout;

MarchA #(
	.RAWIDTH(RAWIDTH),
	.CAWIDTH(CAWIDTH)
) dut (
	.clk(clk),
	.rst(rst),
	.start(start),
	.fault(fault),
	.done(done),
	.fail(fail),
	.RA(RA),
	.CA(CA),
	.we(we),
	.re(re),
	.datain(datain),
	.dataout(dataout)
);

initial
begin
	clk = 0;
	forever
		#1 clk = ~clk;
end

initial
begin
	fault = 2'b11;
	start = 0;
	rst = 0;

	run_march_a(2'b11, "Normal Operation");
	run_march_a(2'b00, "Stuck-at faults detection");
	run_march_a(2'b01, "Transition faults detection");
	run_march_a(2'b10, "Inversion coupling fault detection");

	$finish;
end

task run_march_a;
	input [1:0] fault_opcode;
	input [255:0] test_name;
	begin
		$display("%0s", test_name);
		fault = fault_opcode;
		start = 0;
		rst = 1;
		#4;
		rst = 0;
		#2;
		start = 1;

		wait(done);
		#2;
		if(fail)
			$display("Memory Test Failed");
		else
			$display("Memory Test Passed");

		$display("Final memory contents:");
		for(i = 0; i < ROWS; i = i + 1)
		begin
			for(j = 0; j < COLS; j = j + 1)
			begin
				case(fault_opcode)
					2'b00: $write("%b", dut.mem_inst.u_memory_sa.memory[i][j]);
					2'b01: $write("%b", dut.mem_inst.u_memory_t.memory[i][j]);
					2'b10: $write("%b", dut.mem_inst.u_memory_invc.memory[i][j]);
					default: $write("%b", dut.mem_inst.u_memory.memory[i][j]);
				endcase
			end
			$display();
		end
		$display();

		start = 0;
		#4;
	end
endtask

initial
begin
	#10000;
	$display("Timeout: March A test did not complete");
	$finish;
end

endmodule
