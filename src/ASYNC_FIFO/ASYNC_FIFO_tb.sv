/*-----------------------------------------------------------------------------
* ASYNC_FIFO_tb.sv
*
* Testbench for ASYNC_FIFO.v
*
* Version: 0.11
* Author : AUDIY
* Date   : 2026/05/06
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

module ASYNC_FIFO_tb ();

    timeunit 1ns / 1ps;

    // Clock Cycle
    localparam write_clk_half_cycle = 5;
    localparam read_clk_half_cycle  = 6;

    // FIFO settings
    localparam ADDR_WIDTH                   = 3;
    localparam DATA_WIDTH                   = 8;
    localparam PROGRAMMABLE_FULL_THRESHOLD  = 2;
    localparam PROGRAMMABLE_EMPTY_THRESHOLD = 2;
    localparam WRITE_PROTECT_FULL           = 1'b1;
    localparam READ_PROTECT_EMPTY           = 1'b1;
    localparam FWFT                         = 1'b0; // NOT working in FWFT mode (1'b1).
    localparam DFF_SYNC_STAGE               = 2;

    // Write port
    reg                       WRITE_CLK_I     = 1'b0;
    reg                       WRITE_EN_I      = 1'b0;
    reg  [(DATA_WIDTH - 1):0] WRITE_DATA_I    = '0;
    wire                      WRITE_ARESETN_I;
    wire                      WRITE_FULL_O;
    wire                      WRITE_ALMOST_FULL_O;
    wire                      WRITE_PROGRAMMABLE_FULL_O;

    // Read port
    reg                       READ_CLK_I = 1'b0;
    reg                       READ_EN_I  = 1'b0;
    wire                      READ_ARESETN_I;
    wire [(DATA_WIDTH - 1):0] READ_DATA_O;
    wire                      READ_EMPTY_O;
    wire                      READ_ALMOST_EMPTY_O;
    wire                      READ_PROGRAMMABLE_EMPTY_O;

    reg              RESETN   = 1'b0;
    integer unsigned w_random = '0;

    reg [(DATA_WIDTH - 1):0] data_queue[$], data_expected;

    integer i, j;

    // Asynchronous Reset Synchronizer (Write Clock Domain)
    // Please refer https://github.com/AUDIY/AUDIY_Verilog_IP/tree/main/ARESETN_SYNC for more detail.
    ARESETN_SYNC #(
        .STAGES(2)
    ) write_reset_sync (
        .CLK_I    (WRITE_CLK_I    ),
        .ARESETN_I(RESETN         ),
        .RESETN_O (WRITE_ARESETN_I)
    );

    // Asynchronous Reset Synchronizer (Read Clock Domain)
    // Please refer https://github.com/AUDIY/AUDIY_Verilog_IP/tree/main/ARESETN_SYNC for more detail.
    ARESETN_SYNC #(
        .STAGES(2)
    ) read_reset_sync (
        .CLK_I    (READ_CLK_I    ),
        .ARESETN_I(RESETN        ),
        .RESETN_O (READ_ARESETN_I)
    );

    ASYNC_FIFO #(
        .ADDR_WIDTH                  (ADDR_WIDTH                  ),
        .DATA_WIDTH                  (DATA_WIDTH                  ),
        .PROGRAMMABLE_FULL_THRESHOLD (PROGRAMMABLE_FULL_THRESHOLD ),
        .PROGRAMMABLE_EMPTY_THRESHOLD(PROGRAMMABLE_EMPTY_THRESHOLD),
        .WRITE_PROTECT_FULL          (WRITE_PROTECT_FULL          ),
        .READ_PROTECT_EMPTY          (READ_PROTECT_EMPTY          ),
        .FWFT                        (FWFT                        ),
        .DFF_SYNC_STAGE              (DFF_SYNC_STAGE              )
    ) dut (
        .WRITE_CLK_I              (WRITE_CLK_I              ),
        .WRITE_EN_I               (WRITE_EN_I               ),
        .WRITE_DATA_I             (WRITE_DATA_I             ),
        .WRITE_ARESETN_I          (WRITE_ARESETN_I          ),
        .WRITE_FULL_O             (WRITE_FULL_O             ),
        .WRITE_ALMOST_FULL_O      (WRITE_ALMOST_FULL_O      ),
        .WRITE_PROGRAMMABLE_FULL_O(WRITE_PROGRAMMABLE_FULL_O),
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
    end

    // Write Clock Generation
    initial begin
        forever begin
            #write_clk_half_cycle WRITE_CLK_I = ~WRITE_CLK_I;
        end
    end

    // Read Clock Generation
    initial begin
        forever begin
            #read_clk_half_cycle READ_CLK_I = ~READ_CLK_I;
        end
    end

    // Write Operation
    initial begin
        repeat(10) @(posedge WRITE_CLK_I);

        repeat(2) begin
            for (i = 0; i < 2 ** (ADDR_WIDTH); i++) begin
                @(posedge WRITE_CLK_I);
                WRITE_EN_I = (i % 2 == 0) ? 1'b1 : 1'b0; // Write enable is asserted every other cycle.
                if (WRITE_EN_I) begin
                    WRITE_DATA_I = $urandom_range(0, 2 ** (DATA_WIDTH) - 1); // Random data generation.
                    data_queue.push_back(WRITE_DATA_I); // Store the written data in the queue for later verification.
                end
            end

            #50;
        end
    end

    // Read Operation
    initial begin
        repeat(20) @(posedge READ_CLK_I);

        repeat(2) begin
            for (j = 0; j < 2 ** (ADDR_WIDTH); j++) begin
                @(posedge READ_CLK_I);
                READ_EN_I = (j % 2 == 0) ? 1'b1 : 1'b0; // Read enable is asserted every other cycle.
                if (READ_EN_I) begin
                    data_expected = data_queue.pop_front(); // Get the expected data from the queue.
                    if (READ_DATA_O !== data_expected) begin
                        $error("Data Mismatch at time %t: Expected %h, Got %h", $time, data_expected, READ_DATA_O);
                    end else begin
                        $display("Data Match at time %t: Expected %h, Got %h", $time, data_expected, READ_DATA_O);
                    end
                end
            end

            #50;
        end

        $finish;
    end

endmodule

`default_nettype wire
