/*-----------------------------------------------------------------------------
* ASYNC_FIFO_ADDR_CTRL_tb.sv
*
* Testbench for ASYNC_FIFO_ADDR_CTRL.v
*
* Version: 0.13
* Author : AUDIY
* Date   : 2026/05/19
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

module ASYNC_FIFO_ADDR_CTRL_tb ();

    timeunit 1ns / 1ps;

    localparam CLK_PERIOD = 10;

    localparam ADDR_WIDTH = 4;

    reg  CLK_I    = 1'b0;
    wire ARESETN_I;
    reg  ENABLE_I = 1'b0;

    wire [(ADDR_WIDTH - 1):0] ADDR_O;
    wire [(ADDR_WIDTH - 1):0] GRAY_O;
    wire [(ADDR_WIDTH - 1):0] NEXT_ADDR_O;
    wire [(ADDR_WIDTH - 1):0] NEXT_GRAY_O;

    reg                             ARESETN    = 1'b0;
    reg unsigned [(ADDR_WIDTH-1):0] addr_count = '0;

    // Asynchronous Reset Synchronizer.
    // Please Refer https://github.com/AUDIY/AUDIY_Verilog_IP/tree/main/ARESETN_SYNC for detail.
    ARESETN_SYNC #(
        .STAGES(2)
    ) ARESETN_SYNC (
        .CLK_I    (CLK_I    ),
        .ARESETN_I(ARESETN  ),
        .RESETN_O (ARESETN_I)
    );

    /* Instantiation */
    ASYNC_FIFO_ADDR_CTRL #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .CLK_I      (CLK_I      ),
        .ARESETN_I  (ARESETN_I  ),
        .ENABLE_I   (ENABLE_I   ),
        .ADDR_O     (ADDR_O     ),
        .GRAY_O     (GRAY_O     ),
        .NEXT_ADDR_O(NEXT_ADDR_O),
        .NEXT_GRAY_O(NEXT_GRAY_O)
    );

    initial begin
        $dumpfile("ASYNC_FIFO_ADDR_CTRL.vcd");
        $dumpvars(0, ASYNC_FIFO_ADDR_CTRL_tb);

        #10240 $finish();
    end

    /* Reset Generation */
    initial begin
        #1 ARESETN = 1'b1;

        #4998 ARESETN = 1'b0;
        #2 ARESETN = 1'b1;
    end

    /* Clock Generation */
    initial begin
        forever begin
            #(CLK_PERIOD / 2) CLK_I = ~CLK_I;
        end
    end

    /* Enable Generation */
    always @(posedge CLK_I) begin
        addr_count <= addr_count + 1;

        if (addr_count == {ADDR_WIDTH{1'b1}}) begin
            ENABLE_I <= ~ENABLE_I;
        end
    end
    
endmodule

`default_nettype wire
