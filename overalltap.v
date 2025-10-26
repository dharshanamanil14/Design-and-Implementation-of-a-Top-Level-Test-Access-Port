`timescale 1ns / 1ps
// Top-Level TAP Architecture (Design)
module top (
    // JTAG TAP Signals
    input wire tck,         // Test Clock
    input wire tms,         // Test Mode Select
    input wire trst_b,      // Test Reset (Active Low)
    input wire tdi,         // Test Data Input
    output wire tdo,        // Test Data Output

    // Core Clock,Reset and temp for DUT
    input wire clk,         // Functional Clock (for DUT)
    input wire rst,          // Functional Reset (Active High for DUT)
    output wire tdo_internal, // TDO from BIST TDR
    output wire shift_dr,
    output wire [3:0] current_state_out,
    output wire [31:0] dr_select_one_hot,
    output wire [3:0] current_state,
    output wire [1:0] bist_tdr_out1,
    output wire [1:0] bist_shift_register,
 
    output wire [7:0] bist_parallel_out,
    input wire temp          // Functional temp input (for DUT)
);
wire f;
wire capture_dr, /*shift_dr, */update_dr;
// --- Unified Test Access Port (TAP) ---
//wire [31:0] dr_select_one_hot;
wire [4:0] ir_shift, ir_update;
//wire tdo_internal;
test_access_port U_TAP (
    .tck(tck),
    .tms(tms),
    .trst_b(trst_b),
    .tdi(tdi),
    .tdo(tdo_internal),

    .dr_select_one_hot(dr_select_one_hot),
    // Connect external register TDOs
    .capture_dr(capture_dr),
    .shift_dr(shift_dr),
    .update_dr(update_dr),
    .tdo_bist_tdr(tdo_bist_tdr),
    .current_state(current_state),
    .current_state_out(current_state_out),
    .tdo_rtdr(tdo_rtdr)
);

assign tdo = tdo_internal;
// --- BIST Test Data Register (outside TAP) ---

//wire [1:0] bist_tdr_out;
wire m_i_faulty_status;


jtag_bist_data_register U_BIST_TDR (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[2]),
    .shift_signal(shift_dr & dr_select_one_hot[2]),
    .update_signal(update_dr & dr_select_one_hot[2]),
    .si(tdi),
    .so(tdo_bist_tdr),
    .shift_register(bist_shift_register),
    .bist_fault_status(f),
    .update_register(bist_tdr_out1[1:0])
);

// RTDR 1
jtag_data_register U_RTDR1 (
    .tck(tck),
    .reset_b(trst_b), 
    .capture_signal(capture_dr & dr_select_one_hot[17]),
    .shift_signal(shift_dr & dr_select_one_hot[17]),
    .update_signal(update_dr & dr_select_one_hot[17]),
    .si(tdi),
    .so(tdo_rtdr[1])
);

// RTDR 2
jtag_data_register U_RTDR2 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[18]), 
    .shift_signal(shift_dr & dr_select_one_hot[18]),
    .update_signal(update_dr & dr_select_one_hot[18]),
    .si(tdi),
    .so(tdo_rtdr[2])
);

// RTDR 3
jtag_data_register U_RTDR3 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[19]),
    .shift_signal(shift_dr & dr_select_one_hot[19]), 
    .update_signal(update_dr & dr_select_one_hot[19]),
    .si(tdi),
    .so(tdo_rtdr[3])
);

// RTDR 4
jtag_data_register U_RTDR4 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[20]),
    .shift_signal(shift_dr & dr_select_one_hot[20]),
    .update_signal(update_dr & dr_select_one_hot[20]),
    .si(tdi),
    .so(tdo_rtdr[4])
);

// RTDR 5
jtag_data_register U_RTDR5 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[21]),
    .shift_signal(shift_dr & dr_select_one_hot[21]),
    .update_signal(update_dr & dr_select_one_hot[21]),
    .si(tdi),
    .so(tdo_rtdr[5])
);

// RTDR 6
jtag_data_register U_RTDR6 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[22]),
    .shift_signal(shift_dr & dr_select_one_hot[22]),
    .update_signal(update_dr & dr_select_one_hot[22]),
    .si(tdi),
    .so(tdo_rtdr[6])
);

// RTDR 7 
jtag_data_register U_RTDR7 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[23]),
    .shift_signal(shift_dr & dr_select_one_hot[23]),
    .update_signal(update_dr & dr_select_one_hot[23]),
    .si(tdi),
    .so(tdo_rtdr[7])
);

// RTDR 8
jtag_data_register U_RTDR8 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[24]),
    .shift_signal(shift_dr & dr_select_one_hot[24]),
    .update_signal(update_dr & dr_select_one_hot[24]),
    .si(tdi),
    .so(tdo_rtdr[8])
);

// RTDR 9
jtag_data_register U_RTDR9 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[25]),
    .shift_signal(shift_dr & dr_select_one_hot[25]),
    .update_signal(update_dr & dr_select_one_hot[25]),
    .si(tdi),
    .so(tdo_rtdr[9])
);

// RTDR 10
jtag_data_register U_RTDR10 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[26]),
    .shift_signal(shift_dr & dr_select_one_hot[26]),
    .update_signal(update_dr & dr_select_one_hot[26]),
    .si(tdi),
    .so(tdo_rtdr[10])
);

// RTDR 11
jtag_data_register U_RTDR11 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[27]),
    .shift_signal(shift_dr & dr_select_one_hot[27]),
    .update_signal(update_dr & dr_select_one_hot[27]),
    .si(tdi),
    .so(tdo_rtdr[11])
);

// RTDR 12
jtag_data_register U_RTDR12 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[28]),
    .shift_signal(shift_dr & dr_select_one_hot[28]),
    .update_signal(update_dr & dr_select_one_hot[28]),
    .si(tdi),
    .so(tdo_rtdr[12])
);

// RTDR 13
jtag_data_register U_RTDR13 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[29]),
    .shift_signal(shift_dr & dr_select_one_hot[29]),
    .update_signal(update_dr & dr_select_one_hot[29]),
    .si(tdi),
    .so(tdo_rtdr[13])
);

// RTDR 14
jtag_data_register U_RTDR14 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[30]),
    .shift_signal(shift_dr & dr_select_one_hot[30]),
    .update_signal(update_dr & dr_select_one_hot[30]),
    .si(tdi),
    .so(tdo_rtdr[14])
);
// --- Remote Test Data Registers (RTDRs) ---
wire [14:1] tdo_rtdr;
//BIST Core Integration ---
uart_bist_core U_UART_BIST (
    .clk(clk),
    .rst(rst), 
    .sel(bist_tdr_out1[0]),
    .parallel_out(bist_parallel_out),     
    .temp(temp),   
    .m_i_faulty(f) 
);


endmodule



//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2025 10:04:56
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_bist_core( input clk,rst,sel,temp,/*serial_in,*/ /*input [7:0] parallel_in,*/ /* output serial_out,*/output m_i_faulty, output [7:0] parallel_out/*, output baudrate_clk,Load*/);
   parameter [15:0] baudrate=9600;
   parameter [4:0] divisions=16;
    
    wire [7:0] parallel_in;
    wire serial_out,baudrate_clk,Load;
    wire [7:0] parallel_out;
	wire Busy,Busy1;
	wire match;
    wire [7:0] out,y,data;
    
   baud_rate_generator brg(clk,rst,baudrate,divisions,baudrate_clk);
   lfsr_excess4 le(baudrate_clk,temp,out);
   mux2to1 mm(baudrate_clk,sel,out,parallel_in,y);
   UART_tx  uarttx(baudrate_clk,rst,y,1'b1,serial_out,Busy);
   UART_rx  uartrx(baudrate_clk,rst,serial_out,parallel_out,Load,Busy1);
   /*demux1to2 demux(baudrate_clk,sel,out,parallel_out);*/
   uart_golden_rom ugr(Load,temp,data);
   comparator comparator(clk, rst,parallel_out,data,match);
   response_analyzer ra(match,clk,sel, m_i_faulty);
endmodule



module mux2to1(input clk, sel, input [7:0] a,b, output reg [7:0] y);
   always @(posedge clk) begin
    y=sel?a:b; end
   endmodule

module demux1to2(input clk,sel, input [7:0] a, output reg [7:0] p,q);
     always @(posedge clk) begin
        p=sel?a:8'bxxxxxxxx;
        q=sel?8'bxxxxxxxx:a; end
endmodule


module response_analyzer(input match,clk,sel,output reg  m_i_faulty=0);
always @(posedge clk) begin
        if(~sel)
        m_i_faulty<=1'bX;
        else if(!match)
        m_i_faulty<=1'b1; 
        else
        m_i_faulty<=1'b0|m_i_faulty;
        /*else
        m_i_faulty<=1'bx;*/
        end
        endmodule

module uart_golden_rom (
    input wire clk,            
    input wire rst,            
    output reg [7:0] data    
);

    reg [3:0] addr=0;            
    reg [3:0] clk_count;      

    
    always @(posedge clk) begin
        if (rst) begin
            clk_count <= 0;
            addr <= 0;
            data <= 8'h00;
        end else begin
            
                addr <= addr + 1; end

                
                case (addr)
                    4'd0:  data <= 8'h00;
                    4'd1:  data <= 8'hfc;
                    4'd2:  data <= 8'h04;
                    4'd3:  data <= 8'h1c;
                    4'd4:  data <= 8'hdf;
                    4'd5:  data <= 8'h41;
                    4'd6:  data <= 8'h46;
                    4'd7:  data <= 8'hc2;
                    4'd8:  data <= 8'h80;
                    4'd9:  data <= 8'h97;
                    4'd10: data <= 8'h95;
                    4'd11: data <= 8'h5f;
                    4'd12: data <= 8'h89;
                    4'd13: data <= 8'h4E;
                    4'd14: data <= 8'h4F;
                    4'd15: data <= 8'h50;
                    default: data <= 8'h00;
                endcase

            end 
   

endmodule


module comparator (
    input clk,              
    input rst,              
    input [7:0] out1,       
    input [7:0] out2,       
    output reg fault_flag=1   
);

    reg [3:0] cycle_count;  

    always @(posedge clk) begin
        
                if (out1 != out2)
                    fault_flag <= 0;
                else
                    fault_flag <= 1;
            
          end

endmodule





module baud_rate_generator(
    input clk,
    input rst, 
    input [15:0] int1,
    input [4:0] int2,
    output reg baudrate
);

    reg [17:0] count;
    
    wire [50:0] count_max = 66000000 / (int1 * int2); 
    
    always @(posedge clk) begin
        if (rst) begin
            count <= 0;
            baudrate <= 0;
        end else if (count == count_max) begin
            count <= 0;  
            baudrate <= 1;  
        end else begin
            count <= count + 1;
            baudrate <= 0;
        end
    end

endmodule


module lfsr_excess4 (
    input clk,
    input rst,
    output reg [7:0] out
);
    reg [7:0] lfsrreg;
    reg [3:0] cycle_count;  

    
    always @(posedge clk ) begin
        if (rst) begin
            lfsrreg <= 8'b00110011;
            cycle_count <= 0;
            out <= 8'd0;
        end else begin
            
            lfsrreg <= {lfsrreg[6:0], lfsrreg[7] ^ lfsrreg[5]};
            
            
            if (cycle_count == 9) begin
                cycle_count <= 0;
                out <= lfsrreg + 8'd4;  
                lfsrreg<=out;
            end else begin
                cycle_count <= cycle_count + 1;
            end
        end
    end

endmodule




module UART_tx(
    input clk,
    input rst,
    input [7:0] Tx_Data,
    input Tx_en,
    output reg serial_out=1,
    output reg Busy=0
    );
    
    parameter IDLE = 2'b00, LOAD = 2'b01, SHIFT=2'b10, WAIT = 2'b11;
    reg [1:0] present_state;
    reg [9:0] shift_reg;
    reg [3:0] counter;
    
    always @(posedge clk)
    begin
    case(present_state)
    IDLE: begin
          if(rst) present_state<=IDLE;
          else if(Tx_en) begin present_state<=LOAD; end end
    LOAD: begin
          shift_reg[0]<=1'b0;
          shift_reg[8:1]<=Tx_Data;
          shift_reg[9]<=1'b1; Busy<=1'b1; present_state<=SHIFT; end
    SHIFT: begin
           /*serial_out<=1'b1;*/
           serial_out <= shift_reg[0];
           shift_reg <= shift_reg >> 1; Busy<=1'b1; counter<=counter+4'b0001; 
           if(counter==4'b1010) begin present_state=WAIT;  end else present_state<=SHIFT; end
    WAIT: begin
          shift_reg[8:0]=10'b0000000000; Busy=1'b1; counter=4'b0001; present_state<=IDLE;
          end 
    default: begin
                    counter=4'b0001; 
                   present_state<=IDLE; end 
          endcase
                    end
          endmodule 




 module UART_rx(
    input clk,
    input rst,
    input serial_in,
    output reg [7:0] parallel_out,
    output reg Load=0,Busy
    );
    wire ndet_output;
    wire q=1;
    assign ndet_output=q&~serial_in;
    parameter IDLE = 2'b00, LOAD = 2'b01, SHIFT=2'b10, WAIT = 2'b11;
    reg [1:0] present_state;
    reg [9:0] shift_reg;
    reg [3:0] counter;
    always @(posedge clk)
    begin
    case(present_state)
    IDLE: begin
          if(rst) begin present_state<=IDLE;Busy<=1'b0; end
          else if(ndet_output) begin present_state<=SHIFT; Busy<=1'b0; end else begin present_state<=IDLE;/*parallel_out=8'b11111111;*/ Busy<=1'b1;Load=1'b0; end end
    SHIFT: begin
          shift_reg = shift_reg>>1; shift_reg[9] = serial_in; counter<=counter+4'b0001; Busy<=1'b0;Load=1'b0;
          if(counter==4'b1001) present_state<=LOAD; end
    LOAD: begin
          parallel_out<=8'b11111111;
          /*parallel_out<=shift_reg[8:1];*/
          present_state<=WAIT; Busy<=1'b1;Load=1'b1; end
    WAIT: begin
          shift_reg[9:0]<=10'b0000000000; Busy<=1'b0; counter<=4'b0001;present_state<=IDLE;Load=1'b0;
          end 
    default: begin
                    present_state<=IDLE; counter<=4'b0001; Busy<=1'b0; end
          endcase
                    end
          endmodule      
          





//////////////////////////////////////////////////////////////////////////////////
// JTAG BIST Data Register (with parallel input/output for BIST control)
//////////////////////////////////////////////////////////////////////////////////
module jtag_bist_data_register (
    // JTAG Interface Signals
    input wire tck,         // Test Clock
    input wire reset_b,     // Test Reset (Active Low)
    input wire capture_signal, // Capture enable (Pulse high in Capture-DR state)
    input wire shift_signal,   // Shift enable (Level high in Shift-DR state)
    input wire update_signal,  // Update enable (Pulse high in Update-DR state)
    input wire si,          // Serial Input (TDI)
    input wire bist_fault_status,
    output wire so,         // Serial Output (TDO)
    output reg [1:0] shift_register,
    output reg [1:0] update_register=01 // Parallel Output (for BIST status)
);
    // Internal Registers
     //   reg [1:0] shift_register;   // The 2-bit Capture/Shift Register

    // --- Capture/Shift Register Logic ---
    always @(posedge tck or negedge reset_b) begin 
        if (!reset_b) begin
            shift_register <= 2'b00;
        end else if (capture_signal) begin
            // CAPTURE: Parallel load from BIST status (parallel_in)
            shift_register <= {bist_fault_status, update_register[0]};
        end else if (shift_signal) begin
            // SHIFT: Serial shift operation (TDI loads into MSB)
                shift_register <= {si, shift_register[1]}; 
        end
        // If neither capture_signal nor shift_signal is asserted, the register holds.
    end
    // --- Update Register Logic ---
    always @(negedge tck or negedge reset_b) begin
        if (!reset_b) begin
            // Initialize with default BIST control value
                update_register[0] <= 2'b00; 
        end else if (update_signal) begin
            // UPDATE: Parallel load from the Shift Register
            update_register[0] <= shift_register[0]; 
        end
        // If update_signal is not asserted, the register holds its current value.
    end
    // --- Serial Output (TDO) ---
    assign so = shift_register[0];

endmodule


// test_access_port.v
// Combines FSM, instruction register, and internal test data registers as a unified Test Access Port (TAP)

module test_access_port (
    // JTAG TAP Signals
    input wire tck,
    input wire tms,
    input wire trst_b,
    input wire tdi,
    input tdo_bist_tdr,
    input wire [14:1] tdo_rtdr,
    output wire tdo,
    output wire [3:0] current_state_out,
    output wire [3:0] current_state,
    output wire [31:0] dr_select_one_hot,
    output wire capture_dr,
    output wire shift_dr,
    output wire update_dr
);
    // --- FSM Controller ---
   
    jtag_tap U_TAP_FSM (
        .tck(tck),
        .tms(tms),
        .trst_b(trst_b),
        .capture_dr(capture_dr),
        .shift_dr(shift_dr),
        .update_dr(update_dr),
        .capture_ir(capture_ir),
        .shift_ir(shift_ir),
        .update_ir(update_ir),
        .current_state(current_state),
        .current_state_out(current_state_out)
    );

    // --- Instruction Register ---
    wire tdo_ir;
    instruction_register U_IR (
        .tck(tck),
        .trst_b(trst_b),
        .capture_ir(capture_ir),
        .shift_ir(shift_ir),
        .update_ir(update_ir),
        .tdi(tdi),
        .tdo_ir(tdo_ir),
        .dr_select_one_hot(dr_select_one_hot)
    );
    assign ir_shift_reg = U_IR.shift_register;
    assign ir_update_reg = U_IR.update_register;
    assign ir_dr_select = dr_select_one_hot;

    // --- Internal Test Data Registers (ITDRs) ---
    wire [15:1] tdo_itdr;
// ITDR 1
jtag_data_register U_ITDR1 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[3]),
    .shift_signal(shift_dr & dr_select_one_hot[3]),
    .update_signal(update_dr & dr_select_one_hot[3]),
    .si(tdi),
    .so(tdo_itdr[1])
);

// ITDR 3
jtag_data_register U_ITDR3 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[4]),
    .shift_signal(shift_dr & dr_select_one_hot[4]),
    .update_signal(update_dr & dr_select_one_hot[4]),
    .si(tdi),
    .so(tdo_itdr[3])
);

// ITDR 4
jtag_data_register U_ITDR4 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[5]),
    .shift_signal(shift_dr & dr_select_one_hot[5]),
    .update_signal(update_dr & dr_select_one_hot[5]),
    .si(tdi),
    .so(tdo_itdr[4])
);

// Continue for ITDR 5-15 (skipping ITDR 2)
// ITDR 5
jtag_data_register U_ITDR5 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[6]),
    .shift_signal(shift_dr & dr_select_one_hot[6]),
    .update_signal(update_dr & dr_select_one_hot[6]),
    .si(tdi),
    .so(tdo_itdr[5])
);

// ITDR 6
jtag_data_register U_ITDR6 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[7]),
    .shift_signal(shift_dr & dr_select_one_hot[7]),
    .update_signal(update_dr & dr_select_one_hot[7]),
    .si(tdi),
    .so(tdo_itdr[6])
);

// ITDR 7
jtag_data_register U_ITDR7 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[8]),
    .shift_signal(shift_dr & dr_select_one_hot[8]),
    .update_signal(update_dr & dr_select_one_hot[8]),
    .si(tdi),
    .so(tdo_itdr[7])
);

// ITDR 8
jtag_data_register U_ITDR8 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[9]),
    .shift_signal(shift_dr & dr_select_one_hot[9]),
    .update_signal(update_dr & dr_select_one_hot[9]),
    .si(tdi),
    .so(tdo_itdr[8])
);

// ITDR 9
jtag_data_register U_ITDR9 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[10]),
    .shift_signal(shift_dr & dr_select_one_hot[10]),
    .update_signal(update_dr & dr_select_one_hot[10]),
    .si(tdi),
    .so(tdo_itdr[9])
);

// ITDR 10
jtag_data_register U_ITDR10 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[11]),
    .shift_signal(shift_dr & dr_select_one_hot[11]),
    .update_signal(update_dr & dr_select_one_hot[11]),
    .si(tdi),
    .so(tdo_itdr[10])
);

// ITDR 11
jtag_data_register U_ITDR11 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[12]),
    .shift_signal(shift_dr & dr_select_one_hot[12]),
    .update_signal(update_dr & dr_select_one_hot[12]),
    .si(tdi),
    .so(tdo_itdr[11])
);

// ITDR 12
jtag_data_register U_ITDR12 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[13]),
    .shift_signal(shift_dr & dr_select_one_hot[13]),
    .update_signal(update_dr & dr_select_one_hot[13]),
    .si(tdi),
    .so(tdo_itdr[12])
);

// ITDR 13
jtag_data_register U_ITDR13 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[14]),
    .shift_signal(shift_dr & dr_select_one_hot[14]),
    .update_signal(update_dr & dr_select_one_hot[14]),
    .si(tdi),
    .so(tdo_itdr[13])
);

// ITDR 14
jtag_data_register U_ITDR14 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[15]),
    .shift_signal(shift_dr & dr_select_one_hot[15]),
    .update_signal(update_dr & dr_select_one_hot[15]),
    .si(tdi),
    .so(tdo_itdr[14])
);

// ITDR 15
jtag_data_register U_ITDR15 (
    .tck(tck),
    .reset_b(trst_b),
    .capture_signal(capture_dr & dr_select_one_hot[16]),
    .shift_signal(shift_dr & dr_select_one_hot[16]),
    .update_signal(update_dr & dr_select_one_hot[16]),
    .si(tdi),
    .so(tdo_itdr[15])
);

     // --- TDO Output Multiplexer (full logic) ---
     // External wires for other registers


     wire [15:1] tdo_itdr_ext;

    
     wire tdo_idcode;
     // These wires should be connected from top.v
     // tdo_idcode, tdo_bist_tdr, tdo_itdr_ext, tdo_rtdr_ext,
// TDO multiplexer logic showing all data register selections
assign tdo = shift_ir ? tdo_ir :  // If in Shift-IR, output from IR
    (shift_dr ? (                 // If in Shift-DR, select based on instruction
        // IDCODE Register
        dr_select_one_hot[1] ? tdo_idcode :
        
        // BIST Data Register
        dr_select_one_hot[2] ? tdo_bist_tdr :
        
        // Internal Test Data Registers (ITDRs)
        dr_select_one_hot[3] ? tdo_itdr[1] :   // ITDR1
        dr_select_one_hot[4] ? tdo_itdr[3] :   // ITDR3 (ITDR2 skipped)
        dr_select_one_hot[5] ? tdo_itdr[4] :   // ITDR4
        dr_select_one_hot[6] ? tdo_itdr[5] :   // ITDR5
        dr_select_one_hot[7] ? tdo_itdr[6] :   // ITDR6
        dr_select_one_hot[8] ? tdo_itdr[7] :   // ITDR7
        dr_select_one_hot[9] ? tdo_itdr[8] :   // ITDR8
        dr_select_one_hot[10] ? tdo_itdr[9] :  // ITDR9
        dr_select_one_hot[11] ? tdo_itdr[10] : // ITDR10
        dr_select_one_hot[12] ? tdo_itdr[11] : // ITDR11
        dr_select_one_hot[13] ? tdo_itdr[12] : // ITDR12
        dr_select_one_hot[14] ? tdo_itdr[13] : // ITDR13
        dr_select_one_hot[15] ? tdo_itdr[14] : // ITDR14
        dr_select_one_hot[16] ? tdo_itdr[15] : // ITDR15

        // Remote Test Data Registers (RTDRs)
        dr_select_one_hot[17] ? tdo_rtdr[1] :  // RTDR1
        dr_select_one_hot[18] ? tdo_rtdr[2] :  // RTDR2
        dr_select_one_hot[19] ? tdo_rtdr[3] :  // RTDR3
        dr_select_one_hot[20] ? tdo_rtdr[4] :  // RTDR4
        dr_select_one_hot[21] ? tdo_rtdr[5] :  // RTDR5
        dr_select_one_hot[22] ? tdo_rtdr[6] :  // RTDR6
        dr_select_one_hot[23] ? tdo_rtdr[7] :  // RTDR7
        dr_select_one_hot[24] ? tdo_rtdr[8] :  // RTDR8
        dr_select_one_hot[25] ? tdo_rtdr[9] :  // RTDR9
        dr_select_one_hot[26] ? tdo_rtdr[10] : // RTDR10
        dr_select_one_hot[27] ? tdo_rtdr[11] : // RTDR11
        dr_select_one_hot[28] ? tdo_rtdr[12] : // RTDR12
        dr_select_one_hot[29] ? tdo_rtdr[13] : // RTDR13
        dr_select_one_hot[30] ? tdo_rtdr[14] : 1'bZ// RTDR14
    ) : 1'bZ);                    // High-impedance when not shifting
endmodule


//////////////////////////////////////////////////////////////////////////////////
// JTAG Instruction Register 
//////////////////////////////////////////////////////////////////////////////////
module instruction_register(   // JTAG Interface Signals (Controlled by TAP Controller)
    input wire tck,         // Test Clock
    input wire trst_b,      // Test Reset (Active Low)
    input wire capture_ir,  // Capture enable 
    input wire shift_ir,    // Shift enable 
    input wire update_ir,   // Update enable
    input wire tdi,         // Serial Input (TDI)
    output wire tdo_ir,     // Serial Output (TDO when IR is selected)
    // Parallel Output (One-Hot Select for DR Multiplexer)
    output wire [31:0] dr_select_one_hot
);
    // Instruction Register Configuration
    parameter IR_WIDTH = 5;
    // --- Internal Registers for Capture/Shift/Update ---
    reg [IR_WIDTH-1:0] shift_register;  // Used for serial operation
    reg [IR_WIDTH-1:0] update_register; // Holds the stable instruction code
    // --- Opcode Definitions (5-bit codes) ---
    parameter OP_IDCODE     = 5'h01;
    parameter OP_BYPASS     = 5'h1F; // Often used as the highest or lowest code (11111)
    // ---------------------------------------------
    // 1. Capture/Shift/Update Logic
    // ---------------------------------------------
    // Shift Register (Controls serial access, sensitive to TCK rising edge)
    always @(posedge tck or negedge trst_b) begin
        if (!trst_b) begin
            // Reset to BYPASS instruction (safe state)
            shift_register <= {IR_WIDTH{1'b1}};
        end else if (capture_ir) begin
            // CAPTURE-IR: Parallel load fixed value '01' into LSBs
            shift_register <= {{(IR_WIDTH-2){1'b0}}, 2'b01}; 
        end else if (shift_ir) begin
            // SHIFT-IR: Shift TDI into MSB
            shift_register <= {tdi, shift_register[IR_WIDTH-1:1]};
        end
    end
    // Update Register (Latches new instruction, sensitive to TCK rising edge)
    always @(posedge tck or negedge trst_b) begin
        if (!trst_b) begin
            update_register <= {IR_WIDTH{1'b1}}; // Reset to BYPASS
        end else if (update_ir) begin
            // UPDATE-IR: Load stable instruction from shift register
            update_register <= shift_register;
        end
    end
    // Serial Output
    assign tdo_ir = shift_register[0];
    // ---------------------------------------------
    // 2. Decode Logic (Combinational)
    // ---------------------------------------------
    reg [31:0] dr_select_reg;
    wire [4:0] instruction = update_register; // Use the stable instruction code
    always @(*) begin
        // Default: No register selected
        dr_select_reg = 32'h0;
        case (instruction)
            // Mandatory Register
            OP_IDCODE: dr_select_reg[1] = 1'b1;  // IDCODE at index 1
            // 15 ITDRs: 0x02 to 0x10 (Indices 2 to 16)
            5'h02: dr_select_reg[2] = 1'b1;
            5'h03: dr_select_reg[3] = 1'b1;
            5'h04: dr_select_reg[4] = 1'b1;
            5'h05: dr_select_reg[5] = 1'b1;
            5'h06: dr_select_reg[6] = 1'b1;
            5'h07: dr_select_reg[7] = 1'b1;
            5'h08: dr_select_reg[8] = 1'b1;
            5'h09: dr_select_reg[9] = 1'b1;
            5'h0A: dr_select_reg[10] = 1'b1; 
            5'h0B: dr_select_reg[11] = 1'b1;
            5'h0C: dr_select_reg[12] = 1'b1;
            5'h0D: dr_select_reg[13] = 1'b1;
            5'h0E: dr_select_reg[14] = 1'b1;
            5'h0F: dr_select_reg[15] = 1'b1;
            5'h10: dr_select_reg[16] = 1'b1; // ITDR 15 Select
            // 14 RTDRs: 0x11 to 0x1E (Indices 17 to 30)
            5'h11: dr_select_reg[17] = 1'b1;
            5'h12: dr_select_reg[18] = 1'b1;
            5'h13: dr_select_reg[19] = 1'b1;
            5'h14: dr_select_reg[20] = 1'b1;
            5'h15: dr_select_reg[21] = 1'b1;
            5'h16: dr_select_reg[22] = 1'b1;
            5'h17: dr_select_reg[23] = 1'b1;
            5'h18: dr_select_reg[24] = 1'b1;
            5'h19: dr_select_reg[25] = 1'b1;
            5'h1A: dr_select_reg[26] = 1'b1; // RTDR 10 Select (Opcode 1A)
            5'h1B: dr_select_reg[27] = 1'b1;
            5'h1C: dr_select_reg[28] = 1'b1;
            5'h1D: dr_select_reg[29] = 1'b1;
            5'h1E: dr_select_reg[30] = 1'b1; // RTDR 14 Select
            // Mandatory/Default Register
            OP_BYPASS: dr_select_reg[31] = 1'b1; // BYPASS Register Select
            // Default: Any unused opcode (like 5'h00) defaults to BYPASS
            default: dr_select_reg[31] = 1'b1; 
        endcase
    end
    assign dr_select_one_hot = dr_select_reg;
endmodule



//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2025 21:04:22
// Design Name: 
// Module Name: tap_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



// jtag_tap.v
// Implements the 16-state JTAG Test Access Port (TAP) Controller FSM
// based on IEEE 1149.1 standard (matching the provided state diagram).

module jtag_tap (
    // Inputs
    input wire tck,    // Test Clock
    input wire tms,    // Test Mode Select
    input wire trst_b, // Test Reset (Active Low)

    // Outputs - Control Enables (Active High pulses or levels)
    output reg capture_dr,
    output reg shift_dr,
    output reg update_dr,
    output reg capture_ir,
    output reg shift_ir,
    output reg update_ir,
    
    // Optional: Current State Output for observation (Debugging/Testbench)
    output reg [3:0] current_state,
    output wire [3:0] current_state_out
);

// JTAG FSM State Definitions (4-bit encoding, consistent with the standard)
parameter T_LOGIC_RESET = 4'h0; // Test-Logic-Reset
parameter RUN_TEST_IDLE = 4'h1; // Run-Test/Idle
parameter SELECT_DR_SCAN = 4'h2; // Select-DR-Scan
parameter CAPTURE_DR  = 4'h3; // Capture-DR
parameter SHIFT_DR    = 4'h4; // Shift-DR
parameter EXIT1_DR    = 4'h5; // Exit1-DR
parameter PAUSE_DR    = 4'h6; // Pause-DR
parameter EXIT2_DR    = 4'h7; // Exit2-DR
parameter UPDATE_DR   = 4'h8; // Update-DR
parameter SELECT_IR_SCAN = 4'h9; // Select-IR-Scan
parameter CAPTURE_IR  = 4'hA; // Capture-IR
parameter SHIFT_IR    = 4'hB; // Shift-IR
parameter EXIT1_IR    = 4'hC; // Exit1-IR
parameter PAUSE_IR    = 4'hD; // Pause-IR
parameter EXIT2_IR    = 4'hE; // Exit2-IR
parameter UPDATE_IR   = 4'hF; // Update-IR

//reg [3:0] current_state;
reg [3:0] next_state;

assign current_state_out = current_state;

// 1. FSM State Register (Synchronous reset)
always @(posedge tck or negedge trst_b) begin
    if (!trst_b) begin
        // Async reset to Test-Logic-Reset
        current_state <= T_LOGIC_RESET;
    end else begin
        current_state <= next_state;
    end
end

// 2. FSM Next State Logic (Combinational)
// Logic based on the provided state diagram (Input TMS = 1 or 0)
always @(*) begin
    next_state = current_state; // Default next state (should not happen in real FSM)
    
    case (current_state)
        // TMS=1 -> T_LOGIC_RESET; TMS=0 -> RUN_TEST_IDLE
        T_LOGIC_RESET: next_state = tms ? T_LOGIC_RESET : RUN_TEST_IDLE;
        
        // TMS=1 -> SELECT_DR_SCAN; TMS=0 -> RUN_TEST_IDLE
        RUN_TEST_IDLE: next_state = tms ? SELECT_DR_SCAN : RUN_TEST_IDLE;
        
        // --- Data Register (DR) Path ---
        // TMS=1 -> SELECT_IR_SCAN; TMS=0 -> CAPTURE_DR
        SELECT_DR_SCAN: next_state = tms ? SELECT_IR_SCAN : CAPTURE_DR;
        
        // TMS=1 -> EXIT1_DR; TMS=0 -> SHIFT_DR
        CAPTURE_DR: next_state = tms ? EXIT1_DR : SHIFT_DR;
        
        // TMS=1 -> EXIT1_DR; TMS=0 -> SHIFT_DR
        SHIFT_DR: next_state = tms ? EXIT1_DR : SHIFT_DR;
        
        // TMS=1 -> UPDATE_DR; TMS=0 -> PAUSE_DR
        EXIT1_DR: next_state = tms ? UPDATE_DR : PAUSE_DR;
        
        // TMS=1 -> EXIT2_DR; TMS=0 -> PAUSE_DR
        PAUSE_DR: next_state = tms ? EXIT2_DR : PAUSE_DR;
        
        // TMS=1 -> UPDATE_DR; TMS=0 -> SHIFT_DR
        EXIT2_DR: next_state = tms ? UPDATE_DR : SHIFT_DR;
        
        // TMS=1 -> T_LOGIC_RESET; TMS=0 -> RUN_TEST_IDLE
        UPDATE_DR: next_state = tms ? T_LOGIC_RESET : RUN_TEST_IDLE;


        // --- Instruction Register (IR) Path ---
        // TMS=1 -> T_LOGIC_RESET; TMS=0 -> CAPTURE_IR
        SELECT_IR_SCAN: next_state = tms ? T_LOGIC_RESET : CAPTURE_IR;
        
        // TMS=1 -> EXIT1_IR; TMS=0 -> SHIFT_IR
        CAPTURE_IR: next_state = tms ? EXIT1_IR : SHIFT_IR;
        
        // TMS=1 -> EXIT1_IR; TMS=0 -> SHIFT_IR
        SHIFT_IR: next_state = tms ? EXIT1_IR : SHIFT_IR;
        
        // TMS=1 -> UPDATE_IR; TMS=0 -> PAUSE_IR
        EXIT1_IR: next_state = tms ? UPDATE_IR : PAUSE_IR;
        
        // TMS=1 -> EXIT2_IR; TMS=0 -> PAUSE_IR
        PAUSE_IR: next_state = tms ? EXIT2_IR : PAUSE_IR;
        
        // TMS=1 -> UPDATE_IR; TMS=0 -> SHIFT_IR
        EXIT2_IR: next_state = tms ? UPDATE_IR : SHIFT_IR;
        
        // TMS=1 -> T_LOGIC_RESET; TMS=0 -> RUN_TEST_IDLE
        UPDATE_IR: next_state = tms ? T_LOGIC_RESET : RUN_TEST_IDLE;
        
        default: next_state = T_LOGIC_RESET;
    endcase
end

// 3. Control Signal Generation (Synchronous)
// Capture and Update signals are active only for one TCK cycle.
// Shift signals are active while in the Shift state.
always @(posedge tck or negedge trst_b) begin
    if (!trst_b) begin
        capture_dr <= 1'b0;
        shift_dr   <= 1'b0;
        update_dr  <= 1'b0;
        capture_ir <= 1'b0;
        shift_ir   <= 1'b0;
        update_ir  <= 1'b0;
    end else begin
        // Default to inactive
        capture_dr <= 1'b0;
        shift_dr   <= 1'b0;
        update_dr  <= 1'b0;
        capture_ir <= 1'b0;
        shift_ir   <= 1'b0;
        update_ir  <= 1'b0;

        // Set control signals based on next state transition
        // The outputs are registered and correspond to the NEXT state transition
        case (next_state)
            // Pulse high on the TCK rising edge that transitions INTO the Capture state
            CAPTURE_DR: capture_dr <= 1'b1;
            // Level high while STAYING in or transitioning INTO the Shift state
            SHIFT_DR: shift_dr <= 1'b1;
            // Pulse high on the TCK rising edge that transitions INTO the Update state
            UPDATE_DR: update_dr <= 1'b1;

            CAPTURE_IR: capture_ir <= 1'b1;
            SHIFT_IR: shift_ir <= 1'b1;
            UPDATE_IR: update_ir <= 1'b1;

            default: begin
                // Keep Shift active if current state IS Shift, and we are staying there
                if (current_state == SHIFT_DR && next_state == SHIFT_DR) shift_dr <= 1'b1;
                if (current_state == SHIFT_IR && next_state == SHIFT_IR) shift_ir <= 1'b1;
            end
        endcase
    end
end

endmodule




//////////////////////////////////////////////////////////////////////////////////
// JTAG Data Register 
//////////////////////////////////////////////////////////////////////////////////
module jtag_data_register (
    // JTAG Interface Signals
    input wire tck,         // Test Clock
    input wire reset_b,     // Test Reset (Active Low)
    input wire capture_signal, // Capture enable (Pulse high in Capture-DR state)
    input wire shift_signal,   // Shift enable (Level high in Shift-DR state)
    input wire update_signal,  // Update enable (Pulse high in Update-DR state)
    input wire si,          // Serial Input (TDI)
    output wire so        // Serial Output (TDO)
    // Test Data Interface (The parallel interface to the core logic)
);
    // Internal Registers
    reg [7:0] shift_register; // The 8-bit Capture/Shift Register
    reg [7:0] update_register; // The 8-bit Update Register (holds the stable value)
    // --- Capture/Shift Register Logic ---
    always @(posedge tck or negedge reset_b) begin 
        if (!reset_b) begin
            // Add reset condition
            shift_register <= 8'h00;
        end else if (capture_signal) begin
            shift_register <= update_register;
        end else if (shift_signal) begin
            shift_register <= {si, shift_register[7:1]}; 
        end
    end
    // --- Update Register Logic ---
    always @(negedge tck or negedge reset_b) begin
        if (!reset_b) begin
            // The Update Register holds the currently active parallel output value.
            // The waveform shows an initial value of 8'h5c.
            update_register <= 8'h5c; 
        end else if (update_signal) begin
            // UPDATE: Parallel load from the Shift Register
            update_register <= shift_register; 
        end
        // If update_signal is not asserted, the register holds its current value.
    end
    // --- Serial Output (TDO) ---
    assign so = shift_register[0];
endmodule
































