`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_jtag_bist_integration
// Description: Testbench for the top-level JTAG TAP with integrated BIST/UART module.
// Note: Requires the 'top' module defined in the accompanying design file.
//////////////////////////////////////////////////////////////////////////////////

module tb_jtag_bist_integration;

    // --- 1. JTAG/DUT Interface Signals ---
    // Inputs to DUT (Controlled by Testbench)
    reg tck;        // Test Clock
    reg tms;        // Test Mode Select
    reg trst_b;     // Test Reset (Active Low, Async TAP reset)
    reg tdi;        // Test Data Input
    reg clk;        // Functional Clock (for DUT/BIST)
    reg rst;        // Functional Reset (Active High, for DUT/BIST)
    reg temp;       // Temporary input signal for DUT/BIST
    // (manual sequence storage removed) use helper tasks below to drive TMS/TDI

    // Outputs from DUT (Monitored by Testbench)
    wire tdo;       // Test Data Output
    wire tdo_internal; // TDO from BIST TDR
    wire shift_dr;
    wire [3:0] current_state;
    wire [3:0] current_state_out;
    wire [31:0] dr_select_one_hot;
    wire [1:0] bist_tdr_out1;
    wire [7:0] bist_parallel_out;
    wire [1:0] bist_shift_register;


    localparam [4:0] BIST_OPCODE = 5'h02;




    top UUT (
        .tck(tck),
        .tms(tms),
        .trst_b(trst_b),
        .tdi(tdi),
        .tdo(tdo),
        .clk(clk),
        .rst(rst),
        .tdo_internal(tdo_internal),
        .shift_dr(shift_dr),
        .current_state_out(current_state_out),
        .current_state(current_state),
        .dr_select_one_hot(dr_select_one_hot),
        .bist_tdr_out1(bist_tdr_out1),
        .bist_shift_register(bist_shift_register),
        .bist_parallel_out(bist_parallel_out),
        .temp(temp)
    );



    // Slower JTAG Test Clock (10 MHz, 100ns period)
    always #1000 tck = ~tck;

    // --- 6. Main Test Sequence ---
   parameter [50:0] weight=(66000000*15)/(16*9600);
   always #7.5 clk = ~clk;

    initial begin

        // initialize clocks and signals
        tck  = 1'b0;
        tms  = 1'b0;
        tdi  = 1'b0;
        trst_b = 1'b1;

        
        #100 trst_b = 0;
        #200 trst_b = 1;
       

        // short TAP reset to ensure known state
        @(negedge tck);
        trst_b = 1'b0; #100; trst_b = 1'b1;

        // 1) Load IR with BIST opcode (LSB-first)
        load_ir(BIST_OPCODE);

        // 2) Shift BIST data register (2-bit example value '10')
        shift_bist(2'b10);

        clk = 1'b1;
        rst = 1; temp = 1;
        #weight rst = 0; 
        #(2*weight) temp = 0; 
        #(100*weight) clock_tck(0, 1'b0);
         clock_tck(1, 1'b0);
         clock_tck(0, 1'b0);
         clock_tck(0, 1'b0);
         clock_tck(0, 1'b0);
         clock_tck(0, 1'b0);
         clock_tck(1, 1'b0);
        clock_tck(0, 1'b0);
        clock_tck(1, 1'b0);
        clock_tck(0, 1'b0);
        clock_tck(0, 1'b0);
        #900000 $finish;
    end

    // ------------------------------------------------------------------
    // Helper tasks: low-level clocking and simple IR/DR sequences
    // ------------------------------------------------------------------
    task clock_tck;
        input tms_bit;
        input tdi_bit;
        begin
            @(negedge tck);
            tms = tms_bit;
            tdi = tdi_bit;
            @(posedge tck);
        end
    endtask

    task load_ir;
        input [4:0] instr;
        integer ii;
        begin
            // Go to Shift-IR: Select-DR-Scan(1) -> Select-IR-Scan(1) -> Capture-IR(0) -> Shift-IR(0)
            clock_tck(1, 1'b0);
            clock_tck(1, 1'b0);
            clock_tck(0, 1'b0);
            // Shift bits LSB-first; last bit sets TMS=1 to exit
            for (ii = 0; ii < 5; ii = ii + 1) begin
                if (ii == 4)
                    clock_tck(1, instr[ii]);
                else
                    clock_tck(0, instr[ii]);
            end
            // Update-IR and return to Run-Test/Idle
            clock_tck(1, 1'b0);
            clock_tck(0, 1'b0);
        end
    endtask

    task shift_bist;
        input [1:0] bist_in;
        integer jj;
        begin
            // Go to Shift-DR: Select-DR-Scan(1) -> Capture-DR(0) -> Shift-DR(0)
            clock_tck(1, 1'b0);
            clock_tck(0, 1'b0);
            // Shift 2 bits LSB-first; last bit sets TMS=1 to exit
            for (jj = 0; jj < 2; jj = jj + 1) begin
                if (jj == 1)
                    clock_tck(0, bist_in[jj]);
                else
                    clock_tck(0, bist_in[jj]);
            end
            // Update-DR and return to Run-Test/Idle
            clock_tck(1, 1'b0);
            clock_tck(1, 1'b0);
            clock_tck(0, 1'b0);
        end
    endtask

endmodule

