`timescale 1ns / 1ps

module MBistController (
    input clk,
    input rst,
    input test_mode,
    input wr_en,
    input rd_en,
    input data_in,
    input [3:0] wraddr,
    input [3:0] rdaddr,
    input [1:0] fault,
    output reg bist_status
);

    reg [3:0] state;
    reg wr_en_test;
    reg rd_en_test;
    reg data_in_test;
    reg [3:0] wraddr_test;
    reg [3:0] rdaddr_test;

    reg wr_en_mux;
    reg rd_en_mux;
    reg data_in_mux;
    reg [3:0] wraddr_mux;
    reg [3:0] rdaddr_mux;

    reg addr_rst;
    wire data_out_mem;

    always @(posedge clk) begin
        if (rst) begin
            wr_en_test <= 0;
            rd_en_test <= 0;
            data_in_mux <= 0;
            wraddr_mux <= 4'b0000;
            rdaddr_mux <= 4'b0000;
        end else begin
            wr_en_mux = test_mode ? wr_en_test : wr_en;
            rd_en_mux = test_mode ? rd_en_test : rd_en;
            data_in_mux = test_mode ? data_in_test : data_in;
            wraddr_mux = test_mode ? wraddr_test : wraddr;
            rdaddr_mux = test_mode ? rdaddr_test : rdaddr;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            state <= 0;
            wr_en_test <= 0;
            rd_en_test <= 0;
            wraddr_test <= 0;
            bist_status <= 0;
            data_in_test <= 0;
            addr_rst <= 0;
        end else begin
            case (state)
                0: begin
                    if (test_mode) begin
                        wr_en_test <= 1;
                        rd_en_test <= 0;
                        data_in_test <= 0;
                        wraddr_test <= 0;
                        rdaddr_test <= 0;
                        state <= 1;
                    end else begin
                        state <= 0;
                    end
                end
//{↕(w0); ↑(r0,w1,r1); ↓(r1,w0,r0); ↕(r0)} 
//↑(w0)                ///////////////////////////////////////////////////////////////
                1: begin // write0
                    wr_en_test <= 1;
                    rd_en_test <= 0;
                    data_in_test <= 1'b0;

                    if (wraddr_test == 15) begin
                        state <= 2;
                        addr_rst <= 0;
                    end
                    wraddr_test <= wraddr_test + 1'b1;
                end
// ↑(r0,w1,r1);




                2: begin // read0
                    if (addr_rst == 0) begin
                        rdaddr_test <= 0;
                        wraddr_test <= 0;
                        wr_en_test <= 0;
                        rd_en_test <= 1;
                        addr_rst <= 1;
                    end else begin
                        wr_en_test <= 0;
                        rd_en_test <= 1;
                        // rdaddr_test <= rdaddr_test + 1'b1;
                        if (data_out_mem == 0) begin
                            $display("No error");
                            state <= 3;
                            wr_en_test <= 1;
                            rd_en_test <= 0;
                            data_in_test <= 1;
                        end else begin
                            $display(" error");
                            state <= 3;
                            wr_en_test <= 1;
                            rd_en_test <= 0;
                            data_in_test <= 1;
                            bist_status <= 1;
                        end
                        rdaddr_test <= rdaddr_test + 1'b1;
                    end
                end

                /////////////////////////////////////////////////////
                3: begin // write 1
                    wr_en_test <= 1;
                    rd_en_test <= 0;
                    data_in_test <= 1'b1;

                    if (wraddr_test == 15) begin
                        state <= 4;
                        rd_en_test <= 1;
                        wr_en_test <= 0;
                        addr_rst <= 0;
                    end else begin
                        state <= 4;
                        rd_en_test <= 1;
                        wr_en_test <= 0;
                    end
                    wraddr_test <= wraddr_test + 1'b1;
                end
                /////////////////////////////////////////////////////
                4: begin // read1
                    if (addr_rst == 0) begin
                        rdaddr_test <= 0;
                        wraddr_test <= 0;
                        wr_en_test <= 0;
                        rd_en_test <= 1;
                        addr_rst <= 1;
                    end else begin
                        wr_en_test <= 0;
                        rd_en_test <= 1;
                        // rdaddr_test <= rdaddr_test + 1'b1;
                            if (rdaddr_test == 15) begin
                                // rdaddr_test <= rdaddr_test + 1'b1;
                                if (data_out_mem == 1) begin
                                    $display("No error");
                                    state <= 5;
                                    wr_en_test <= 0;
                                    rd_en_test <= 1;
                                    //data_in_test <= 0;
                                end else begin
                                    $display(" error");
                                    state <= 5;
                                    wr_en_test <= 0;
                                    rd_en_test <= 1;
                                    //data_in_test <= 0;
                                    bist_status <= 1;
                                end end
                            else begin
                                if (data_out_mem == 1) begin
                                    $display("No error");
                                    state <= 2;
                                    wr_en_test <= 0;
                                    rd_en_test <= 1;
                                    //data_in_test <= 0;
                                end else begin
                                    $display(" error");
                                    state <= 2;
                                    wr_en_test <= 0;
                                    rd_en_test <= 1;
                                    //data_in_test <= 0;
                                    bist_status <= 1;
                                end end
                                
                        rdaddr_test <= rdaddr_test + 1'b1;
                    end
                end
//↓(r1,w0,r0); 

                5: begin // read 1
                    if (addr_rst == 0) begin
                        rdaddr_test <= 4'b1111;
                        wraddr_test <= 4'b1111;
                        wr_en_test <= 0;
                        rd_en_test <= 1;
                        addr_rst <= 1;
                    end else begin
                        wr_en_test <= 0;
                        rd_en_test <= 1;
                        // rdaddr_test<=rdaddr_test+1'b1;
                        if (data_out_mem == 1) begin
                            $display("No error");
                            state <= 6;
                            wr_en_test <= 1;
                            rd_en_test <= 0;
                            data_in_test <= 0;
                        end else begin
                            $display(" error");
                            state <= 6;
                            wr_en_test <= 1;
                            rd_en_test <= 0;
                            data_in_test <= 0;
                            bist_status <= 1;
                        end
                        rdaddr_test <= rdaddr_test - 1'b1;
                    end
                end

                6: begin // write 0
                    wr_en_test <= 1;
                    rd_en_test <= 0;
                    data_in_test <= 1'b0;

                    if (wraddr_test == 0) begin
                        state <= 7;
                        rd_en_test <= 1;
                        wr_en_test <= 0;
                        addr_rst <= 0;
                    end else begin
                        state <= 7;
                        rd_en_test <= 1;
                        wr_en_test <= 0;
                    end
                    wraddr_test <= wraddr_test - 1'b1;
                end

                7: begin // read 0
                    if (addr_rst == 0) begin
                        rdaddr_test <= 4'b1111;
                        wraddr_test <= 4'b1111;
                        wr_en_test <= 0;
                        rd_en_test <= 1;
                        addr_rst <= 1;
                    end else begin
                        wr_en_test <= 0;
                        rd_en_test <= 1;
                        // rdaddr_test<=rdaddr_test+1'b1;
                            if (rdaddr_test == 0) begin
                                if (data_out_mem == 0) begin
                                    $display("No error");
                                    state <= 8;
                                    wr_en_test <= 0;
                                    rd_en_test <= 1;
                                    //data_in_test <= 0;
                                end else begin
                                    $display(" error");
                                    state <= 8;
                                    wr_en_test <= 0;
                                    rd_en_test <= 1;
                                    //data_in_test <= 0;
                                    bist_status <= 1;
                                end end
                            else begin
                                if (data_out_mem == 0) begin
                                    $display("No error");
                                    state <= 5;
                                    wr_en_test <= 0;
                                    rd_en_test <= 1;
                                    //data_in_test <= 0;
                                end else begin
                                    $display(" error");
                                    state <= 5;
                                    wr_en_test <= 0;
                                    rd_en_test <= 1;
                                    //data_in_test <= 0;
                                    bist_status <= 1;
                                end end
                        rdaddr_test <= rdaddr_test - 1'b1;
                    end
                end
//↓(r0)
               8: begin // read 0
                    if (addr_rst == 0) begin
                        rdaddr_test <= 4'b1111;
                        wraddr_test <= 4'b1111;
                        wr_en_test <= 0;
                        rd_en_test <= 1;
                        addr_rst <= 1;
                    end else begin
                        wr_en_test <= 0;
                        rd_en_test <= 1;
                        // rdaddr_test<=rdaddr_test+1'b1;
                        if (data_out_mem == 0) begin
                            $display("No error");
//                          state<=0;
//                          wr_en_test<=1;
//                          rd_en_test<=0;
//                          data_in_test<=1;
                        end else begin
                            $display(" error");
                            bist_status <= 1;
//                          state<=3;
//                          wr_en_test<=1;
//                          rd_en_test<=0;
//                          data_in_test<=1;
                        end
                        rdaddr_test <= rdaddr_test - 1'b1;
                        if (rdaddr_test == 0) begin
                            state <= 0;
                        end
                    end
                end
            endcase
        end
    end

    ram #(
        .AWIDTH(4)
    ) ram_model_inst (
        .clk(clk),
        .reset(rst),
        .we(wr_en_mux),
        .wr_addr(wraddr_mux),
        .data_in(data_in_mux),
        .re(rd_en_mux),
        .rd_addr(rdaddr_mux),
        .data_out(data_out_mem),
        .fault(fault)
    );

endmodule

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
                            // when (1,3) changes from 0->1, (0,3) toggles
                            memory[wr_addr[1:0]][wr_addr[3:2]-1] <= memory[wr_addr[1:0]][wr_addr[3:2]-1] ^
                                                                    ~memory[wr_addr[1:0]][wr_addr[3:2]] & data_in;
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
