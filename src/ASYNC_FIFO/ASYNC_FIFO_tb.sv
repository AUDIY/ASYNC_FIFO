/*-----------------------------------------------------------------------------
* ASYNC_FIFO_tb.sv
*
* Testbench for ASYNC_FIFO.v
*
* Version: 0.14
* Author : AUDIY
* Date   : 2026/06/14
*
* License
--------------------------------------------------------------------------------
| Copyright AUDIY 2026.                                                        |
|                                                                              |
| This source describes Open Hardware and is licensed under the CERN-OHL-W v2. |
|                                                                              |
| You may redistribute and modify this source and make products using it under |
| the terms of the CERN-OHL-W v2 (https://cern.ch/cern-ohl).                   |
|                                                                              |
| This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY,          |
| INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A         |
| PARTICULAR PURPOSE. Please see the CERN-OHL-W v2 for applicable conditions.  |
|                                                                              |
| Source location: https://github.com/AUDIY/ASYNC_FIFO                         |
|                                                                              |
| As per CERN-OHL-W v2 section 4.1, should You produce hardware based on these |
| sources, You must maintain the Source Location visible on the external case  |
| of the ASYNC_FIFO or other products you make using this source.              |
--------------------------------------------------------------------------------
*
-----------------------------------------------------------------------------*/
`default_nettype none

module ASYNC_FIFO_tb();

    timeunit 1ns / 1ps;

    parameter WRITE_CLK_HALF_CYCLE = 5;
    parameter READ_CLK_HALF_CYCLE  = 6;

    parameter ADDR_WIDTH                   = 3;
    parameter DATA_WIDTH                   = 8;
    parameter PROGRAMMABLE_FULL_THRESHOLD  = 2;
    parameter PROGRAMMABLE_EMPTY_THRESHOLD = 2;
    parameter WRITE_PROTECT_FULL           = 1'b1;
    parameter READ_PROTECT_EMPTY           = 1'b1;
    parameter DFF_SYNC_STAGE               = 2;

    reg                   WRITE_CLK_I = 1'b0;
    reg                   WRITE_EN_I = 1'b0;
    reg  [DATA_WIDTH-1:0] WRITE_DATA_I= '0;
    wire                  WRITE_ARESETN_I;
    wire                  WRITE_FULL_O;
    wire                  WRITE_ALMOST_FULL_O;
    wire                  WRITE_PROGRAMMABLE_FULL_O;

    reg                   READ_CLK_I = 1'b0;
    reg                   READ_EN_I = 1'b0;
    wire                  READ_ARESETN_I;
    wire [DATA_WIDTH-1:0] READ_DATA_O;
    wire                  READ_EMPTY_O;
    wire                  READ_ALMOST_EMPTY_O;
    wire                  READ_PROGRAMMABLE_EMPTY_O;

    reg RESETN = 1'b0;

    integer w_random = 1'b0;
    reg [DATA_WIDTH-1:0] wdata_q[$];
    reg [DATA_WIDTH-1:0] wdata = {DATA_WIDTH{1'b0}};
    reg [DATA_WIDTH-1:0] w_q   = {DATA_WIDTH{1'b0}};
    int i = 0;
    int j = 0;

    // Asynchronous Reset Synchronizer (Write Clock Domain)
    // Please Refer https://github.com/AUDIY/AUDIY_Verilog_IP/tree/main/ARESETN_SYNC for detail.
    ARESETN_SYNC #(
        .STAGES(2)
    ) write_reset_sync (
        .CLK_I    (WRITE_CLK_I    ),
        .ARESETN_I(RESETN         ),
        .RESETN_O (WRITE_ARESETN_I)
    );

    // Asynchronous Reset Synchronizer (Read Clock Domain)
    // Please Refer https://github.com/AUDIY/AUDIY_Verilog_IP/tree/main/ARESETN_SYNC for detail.
    ARESETN_SYNC #(
        .STAGES(2)
    ) read_reset_sync (
        .CLK_I    (READ_CLK_I    ),
        .ARESETN_I(RESETN        ),
        .RESETN_O (READ_ARESETN_I)
    );

    // DUT
    ASYNC_FIFO #(
        .ADDR_WIDTH                  (ADDR_WIDTH                  ),
        .DATA_WIDTH                  (DATA_WIDTH                  ),
        .PROGRAMMABLE_FULL_THRESHOLD (PROGRAMMABLE_FULL_THRESHOLD ),
        .PROGRAMMABLE_EMPTY_THRESHOLD(PROGRAMMABLE_EMPTY_THRESHOLD),
        .WRITE_PROTECT_FULL          (WRITE_PROTECT_FULL          ),
        .READ_PROTECT_EMPTY          (READ_PROTECT_EMPTY          ),
        .DFF_SYNC_STAGE              (DFF_SYNC_STAGE              )
    ) dut (
        // Write Side
        .WRITE_CLK_I              (WRITE_CLK_I              ),
        .WRITE_EN_I               (WRITE_EN_I               ),
        .WRITE_DATA_I             (WRITE_DATA_I             ),
        .WRITE_ARESETN_I          (WRITE_ARESETN_I          ),
        .WRITE_FULL_O             (WRITE_FULL_O             ),
        .WRITE_ALMOST_FULL_O      (WRITE_ALMOST_FULL_O      ),
        .WRITE_PROGRAMMABLE_FULL_O(WRITE_PROGRAMMABLE_FULL_O),

        // Read Side
        .READ_CLK_I               (READ_CLK_I               ),
        .READ_EN_I                (READ_EN_I                ),
        .READ_ARESETN_I           (READ_ARESETN_I           ),
        .READ_DATA_O              (READ_DATA_O              ),
        .READ_EMPTY_O             (READ_EMPTY_O             ),
        .READ_ALMOST_EMPTY_O      (READ_ALMOST_EMPTY_O      ),
        .READ_PROGRAMMABLE_EMPTY_O(READ_PROGRAMMABLE_EMPTY_O)
    );

    initial begin
        $dumpfile("ASYNC_FIFO.vcd");
        $dumpvars(0, ASYNC_FIFO_tb);

        #1 RESETN = 1'b1;

        #2500 $finish;
    end

    /* Clock Generation */
    // Write Clock
    initial begin
        forever begin
            #(WRITE_CLK_HALF_CYCLE) WRITE_CLK_I = ~WRITE_CLK_I;
        end
    end

    // Read Clock
    initial begin
        forever begin
            #(READ_CLK_HALF_CYCLE) READ_CLK_I = ~READ_CLK_I;
        end
    end

    /* Write Operation */
    always @(posedge WRITE_CLK_I or negedge WRITE_ARESETN_I) begin
        if (!WRITE_ARESETN_I) begin
            WRITE_EN_I <= 1'b0;
            WRITE_DATA_I <= '0;
            i <= '0;
        end else begin
            if ((i >= 21) && !WRITE_FULL_O) begin
                WRITE_EN_I <= (i % 2 == 0) ? 1'b1 : 1'b0;

                if (WRITE_EN_I) begin
                    w_random = $urandom_range(0, 2**DATA_WIDTH-1);
                    WRITE_DATA_I <= w_random[DATA_WIDTH-1:0];
                    wdata_q.push_back(w_random[DATA_WIDTH-1:0]);
                end

                i++;
            end else if (i < 21) begin
                i++;
            end else if (WRITE_FULL_O) begin
                i <= '0;
            end else begin
                WRITE_EN_I <= 1'b0;
            end
        end
    end

    /* Read Operation */
    always @(posedge READ_CLK_I or negedge READ_ARESETN_I) begin
        if (!READ_ARESETN_I) begin
            READ_EN_I <= 1'b0;
            j <= '0;
        end else begin
            if ((j >= 31) && !READ_EMPTY_O) begin
                READ_EN_I <= (j % 2 == 0) ? 1'b1 : 1'b0;

                if (READ_EN_I) begin
                   wdata <= wdata_q.pop_front();
                   w_q <= wdata;

                   if (READ_DATA_O !== w_q) begin
                       $error("Time = %0t: Comparison Failed: expected WRITE_DATA = %h, READ_DATA = %h",
                           $time,
                           w_q,
                           READ_DATA_O
                       );
                   end else begin
                       $display("Time = %0t: Comparison Passed: expected WRITE_DATA = %h, READ_DATA = %h",
                           $time,
                           w_q,
                           READ_DATA_O
                       );
                   end 
                end

                j++;
            end else if (j < 31) begin
                j++;
            end else if (READ_EMPTY_O) begin
                j <= '0;
            end else begin
                READ_EN_I <= 1'b0;
            end
        end
    end

endmodule

`default_nettype wire
