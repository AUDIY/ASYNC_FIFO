/*-----------------------------------------------------------------------------
* ASYNC_FIFO_ADDR_CTRL.v
*
* Address Controller for Asynchronous FIFO
*
* Version: 0.10
* Author : AUDIY
* Date   : 2026/05/01
*
* Port
*   Input
*       CLK_I    : Clock
*       ARESETN_I: Asynchronous Reset (Active LOW)
*       ENABLE_I : Write/Read Enable
*
*   Output
*       ADDR_O             : Write/Read Address
*       GRAY_O             : Write/Read Address in Gray Code
*       NEXT_ADDR_O        : Next Write/Read Address for Full/Empty detection.
*       NEXT_GRAY_O        : Next Write/Read Address in Gray Code for Full/Empty detection.
*
* Parameter
*   ADDR_WIDTH: Address Width
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
| of the FIR_x2 or other products you make using this source.                  |
--------------------------------------------------------------------------------
*
-----------------------------------------------------------------------------*/
`default_nettype none

module ASYNC_FIFO_ADDR_CTRL #(
    parameter ADDR_WIDTH = 6
) (
    input  wire                      CLK_I,
    input  wire                      ARESETN_I,
    input  wire                      ENABLE_I,
    output wire [(ADDR_WIDTH - 1):0] ADDR_O,
    output wire [(ADDR_WIDTH - 1):0] GRAY_O,
    output wire [(ADDR_WIDTH - 1):0] NEXT_ADDR_O,
    output wire [(ADDR_WIDTH - 1):0] NEXT_GRAY_O
);

    reg [(ADDR_WIDTH - 1):0] ADDR_REG = {(ADDR_WIDTH){1'b0}};
    reg [(ADDR_WIDTH - 1):0] GRAY_REG = {(ADDR_WIDTH){1'b0}};

    always @(posedge CLK_I or negedge ARESETN_I) begin
        if (ARESETN_I == 1'b0) begin
            ADDR_REG <= {(ADDR_WIDTH){1'b0}};
            GRAY_REG <= {(ADDR_WIDTH){1'b0}};
        end else begin
            if (ENABLE_I == 1'b1) begin
                /* Increment the address */
                ADDR_REG <= NEXT_ADDR_O;
                GRAY_REG <= NEXT_GRAY_O;
            end else begin
                /* Hold */
                ADDR_REG <= ADDR_REG;
                GRAY_REG <= GRAY_REG;
            end
        end
    end

    assign ADDR_O      = ADDR_REG;
    assign GRAY_O      = GRAY_REG;
    assign NEXT_ADDR_O = ADDR_REG + {{(ADDR_WIDTH - 1){1'b0}}, ENABLE_I};

    // Binary to Gray encoder.
    // Please Refer https://github.com/AUDIY/AUDIY_Verilog_IP/tree/main/BIN2GRAY
    BIN2GRAY #(
        .BIN_WIDTH(ADDR_WIDTH)
    ) u_bin2gray (
        .BIN_I (NEXT_ADDR_O),
        .GRAY_O(NEXT_GRAY_O)
    );

endmodule

`default_nettype wire
